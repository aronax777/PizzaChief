"""Validate actual server departure/shutdown coordination with a deterministic scheduler.
No real players, scene changes, or DataStore calls occur in the generated chunk.
"""
from pathlib import Path
root = Path(__file__).resolve().parents[1]
source = (root/'src/server/GameServer.server.luau').read_text()
retire = source[source.index('local function retireProfile(holder)'):source.index('local function playerAdded(player)')]
removal = source[source.index('Players.PlayerRemoving:Connect(function(player)'):source.index('for _, player in ipairs(Players:GetPlayers())')]
shutdown = source[source.index('game:BindToClose(function()'):source.index('\nprint("Pizza Chief server ready:')]
prefix = r'''
local clock = 0
local queue, scheduled = {}, {}
local sessions, retiringProfiles = {}, {}
local shuttingDown = false
local os = {clock=function()return clock end}
local task = {}
function task.spawn(callback)table.insert(queue,callback)end
function task.wait(seconds)
    clock += seconds
    for i=#scheduled,1,-1 do
        if scheduled[i].at<=clock then local event=table.remove(scheduled,i);event.callback()end
    end
    if #queue>0 then local job=table.remove(queue,1);job()end
    return seconds
end
local removeCallback, closeCallback
local Players = {PlayerRemoving={Connect=function(_,callback)removeCallback=callback end}}
local game = {BindToClose=function(_,callback)closeCallback=callback end}
local function leaveRoom()end
local function publishAll()end
local attempts, savedXP, failNext = 0, nil, false
local ProfileStore = {}
function ProfileStore.Save(holder,release)
    if not holder.writable or holder.saving or holder.status=='loading' then return false end
    attempts+=1
    if failNext then failNext=false;holder.status='unavailable';return false end
    holder.saving=true
    local xp=holder.data.xp
    task.wait(3)
    savedXP=xp;holder.saving=false;holder.writable=not release;holder.status='saved'
    return true
end
'''
suffix = r'''
local checks={}
local function check(ok,detail)assert(ok,detail);table.insert(checks,detail)end
local p={};local holder={writable=true,status='saved',saving=false,data={xp=99}}
sessions[p]={profile=holder}
removeCallback(p)
check(sessions[p]==nil and retiringProfiles[holder],
    'PlayerRemoving removes gameplay state but retains a pending final-save registry entry')
local before=clock
closeCallback()
check(savedXP==99 and not holder.writable and next(retiringProfiles)==nil and clock-before>=3,
    'Last-player shutdown waits for an already-departing profile final save')
shuttingDown=false
local p2={};local h2={writable=true,status='saved',saving=true,data={xp=100}}
sessions[p2]={profile=h2}
table.insert(scheduled,{at=clock+1.2,callback=function()h2.saving=false;h2.data.xp=111 end})
removeCallback(p2);closeCallback()
check(savedXP==111 and not h2.writable and next(retiringProfiles)==nil,
    'Shutdown waits through an in-flight autosave then persists the latest final progress')
shuttingDown=false
local p3={};local h3={writable=true,status='saved',saving=false,data={xp=222}}
sessions[p3]={profile=h3};failNext=true;local oldAttempts=attempts
removeCallback(p3);closeCallback()
check(attempts==oldAttempts+2 and savedXP==222 and not h3.writable,
    'A transient final-save failure is retried while shutdown is waiting')
return {passed=#checks,checks=checks,liveDataStoreAccess=false,sceneModified=false}
'''
output=root/'tests/generated-shutdown-validation.luau'
output.write_text(prefix+retire+removal+shutdown+suffix)
print(output)
