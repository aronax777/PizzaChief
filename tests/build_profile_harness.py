"""Generate isolated validation for the actual ProfileStore module.
Uses an in-memory UpdateAsync substitute. No live DataStore calls occur.
"""
from pathlib import Path
root = Path(__file__).resolve().parents[1]
source = (root / 'src/server/ProfileStore.luau').read_text()
prefix = r'''
local TestEpoch = 1793990000
local TestClock = 0
local onWait, onUpdate
local testTask = { wait = function(seconds)
    TestClock += seconds; TestEpoch += seconds
    if onWait then onWait() end
    return seconds
end }
local TestStudio = false
local guid = 0
local failures, retries, calls = false, false, 0
local records = {}
local function copy(value)
    if type(value) ~= 'table' then return value end
    local result = {}; for k,v in pairs(value) do result[k] = copy(v) end;return result
end
local memoryStore = {}
function memoryStore:UpdateAsync(key, transform)
    calls += 1
    if failures then error('simulated store outage') end
    if onUpdate then local hook=onUpdate;onUpdate=nil;hook() end
    local prior = copy(records[key])
    local result = transform(copy(prior))
    if retries then result = transform(copy(prior)) end
    if result ~= nil then records[key] = copy(result) end
    return copy(result)
end
local fakeGame = {GameId=12345,GetService=function(_,name)
    if name=='RunService' then return {IsStudio=function()return TestStudio end} end
    if name=='HttpService' then return {GenerateGUID=function()guid+=1;return 'test-owner-'..guid end} end
    if name=='DataStoreService' then return {GetDataStore=function(_,name)assert(name=='PizzaChiefProfiles_v2');return memoryStore end} end
    error('Unexpected service: '..name)
end}
local Store = (function()
    local game = fakeGame
    local os = {time=function()return TestEpoch end,clock=function()return TestClock end}
    local task = testTask
'''
suffix = r'''
end)()
local checks = {}
local function check(ok, detail)assert(ok,detail);table.insert(checks,detail)end
check(not Store.NewProfile().tutorialCompleted and not Store.NewProfile().tutorialDismissed, 'New profile offers tutorial')
TestStudio=true
local localProfile=Store.Create(1);local before=calls
Store.Load(localProfile);localProfile.data.xp=500;Store.Save(localProfile,true)
check(localProfile.status=='session' and calls==before, 'Studio progression never contacts a DataStore')
TestStudio=false
records.player_2={dailyBest={day=20000,score=math.huge},xp=-4,bestCombo=99,bestShift=900,completed='bad',recipeBest={margherita={score=0/0,stars=9},pepperoni={score=123,stars=-3}}}
local a=Store.Create(2);Store.Load(a)
check(a.status=='saved' and a.writable and records.player_2._lease.owner==a.owner,
    'Published profile acquires an exclusive owner lease')
check(a.data.xp==0 and a.data.completed==0 and a.data.bestCombo==5 and a.data.bestShift==300 and a.data.recipeBest.margherita.score==0 and a.data.recipeBest.margherita.stars==3 and a.data.totalStars==3,
    'Malformed stored numbers are sanitized and star totals are recomputed')
check(a.data.dailyBest.day==20000 and a.data.dailyBest.score==0, 'Malformed daily records cannot introduce non-finite scores')
local b=Store.Create(2);Store.Load(b)
check(b.status=='unavailable' and not b.writable and records.player_2._lease.owner==a.owner,
    'A second live session cannot steal an unexpired real-epoch lease')
local callCount=calls;b.data.xp=99999;Store.Save(b,true)
check(calls==callCount and records.player_2.xp==0,
    'A contended blank profile cannot overwrite durable progress')
a.data.dailyBest={day=20001,score=92};a.data.xp=100;a.data.completed=1;a.data.recipeBest.margherita={score=95,stars=3};retries=true
check(Store.Save(a,false) and records.player_2.xp==100 and records.player_2.completed==1,
    'UpdateAsync callback retries do not duplicate XP or completions')
check(Store.Save(a,false) and records.player_2.xp==100 and records.player_2.dailyBest.score==92,
    'Repeated autosaves are idempotent')
failures=true;a.data.xp=150
check(not Store.Save(a,false) and a.status=='unavailable' and records.player_2.xp==100,
    'A failed save preserves the last durable profile')
failures=false
check(Store.Save(a,false) and a.status=='saved' and records.player_2.xp==150,
    'A later autosave recovers from a transient failure')
TestEpoch+=151
local c=Store.Create(2);Store.Load(c)
check(c.writable and c.data.xp==150 and records.player_2._lease.owner==c.owner,
    'An expired abandoned lease can be safely acquired without losing progress')
a.data.xp=999
check(not Store.Save(a,false) and not a.writable and records.player_2.xp==150,
    'A stale owner cannot overwrite a newly acquired session')
c.data.xp=180;check(Store.Save(c,true) and not c.writable and records.player_2._lease==nil,
    'Release saves the final profile and removes ownership')
local d=Store.Create(2);Store.Load(d)
check(d.writable and d.data.xp==180, 'A released profile loads immediately into another session')
d.data.tutorialCompleted=true;d.data.tutorialDismissed=true
check(Store.Save(d,true), 'Tutorial flags save through the existing lease')
local tutorialReload=Store.Create(2);Store.Load(tutorialReload)
check(tutorialReload.data.tutorialCompleted and tutorialReload.data.tutorialDismissed, 'Tutorial completion and skip survive profile reload')
records.player_45={tutorialCompleted='true',tutorialDismissed=1}
local invalidTutorial=Store.Create(45);Store.Load(invalidTutorial)
check(not invalidTutorial.data.tutorialCompleted and not invalidTutorial.data.tutorialDismissed, 'Malformed tutorial flags do not suppress onboarding')
records.player_3={xp=800}
failures=true;local outage=Store.Create(3);Store.Load(outage);failures=false
outage.data.xp=1;local n=calls;Store.Save(outage,true)
check(outage.status=='unavailable' and calls==n and records.player_3.xp==800,
    'A failed initial load never writes a default profile over saved data')
-- A departing server releases during the new session's bounded retry window.
records.player_10={xp=320,_lease={owner='departing',expires=TestEpoch+150}}
local fastRejoin=Store.Create(10);local attempts=calls;local began=TestClock
onWait=function() if TestClock-began>=2 then records.player_10._lease=nil;onWait=nil end end
Store.Load(fastRejoin)
check(fastRejoin.writable and fastRejoin.data.xp==320 and calls>=attempts+2,
    'Fast rejoin retries a departing lease and loads the durable profile')
local locked=Store.Create(10);local started=TestClock;Store.Load(locked)
check(locked.status=='unavailable' and TestClock-started<=20 and records.player_10._lease.owner==fastRejoin.owner,
    'Persistent contention has a bounded retry budget and never steals ownership')
-- The real Save function sees a release request while its earlier snapshot is in flight.
fastRejoin.data.xp=350
onUpdate=function()
    fastRejoin.data.xp=390
    Store.Save(fastRejoin,true)
end
check(Store.Save(fastRejoin,false) and records.player_10.xp==390 and records.player_10._lease==nil and not fastRejoin.writable,
    'Release arriving during autosave writes a fresh final snapshot and releases the lease')
local late=Store.Create(11)
onUpdate=function()Store.Save(late,true)end
Store.Load(late)
check(records.player_11._lease==nil and not late.writable and late.closing,
    'Departure during an in-flight load releases a newly acquired lease immediately')
local departed=Store.Create(12);Store.Save(departed,true);local priorCalls=calls;Store.Load(departed)
check(calls==priorCalls and departed.status=='unavailable',
    'A departed player never starts a new profile claim')
records.player_13={xp=720}
failures=true;local recover=Store.Create(13);local once=true
onWait=function()if once then failures=false;once=false;onWait=nil end end
Store.Load(recover)
check(recover.writable and recover.data.xp==720,
    'A transient load outage recovers within the bounded loading window')
return {passed=#checks,checks=checks,liveDataStoreAccess=false}
'''
output=root/'tests/generated-profile-validation.luau'
output.write_text(prefix+source+suffix)
print(output)
