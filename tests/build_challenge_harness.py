"""Validate real challenge rules, server transitions and isolated durable storage."""
from pathlib import Path
import runpy
root=Path(__file__).resolve().parents[1]
runpy.run_path(str(root/'tests/build_room_harness.py'))
s=(root/'tests/generated-room-validation.luau').read_text()
marker='return { passed = #reports, checks = reports, idleBakeQuality = idleQuality, controlledBakeQuality = controlledQuality }'
checks=r'''
check(Challenges.Code(' abcd-1234-5678 ' )=='ABCD12345678','Manual codes normalize case, spaces and separators')
check(not Challenges.Code({}) and not Challenges.Code('https://example.com') and not Challenges.Code(string.rep('A',33)),'Malformed and oversized codes are rejected')
check(Challenges.LaunchCode('pc1:ABCD12345678')=='ABCD12345678' and not Challenges.LaunchCode('other:ABCD12345678'),'Launch data accepts only the challenge prefix')
check(Challenges.LaunchData('ABCD12345678')=='pc1:ABCD12345678','Invites carry an identifier only')
check(Challenges.Outcome(94.04,94)=='tied' and Challenges.Outcome(94.06,94)=='won' and Challenges.Outcome(93.94,94)=='lost','Comparisons use displayed tenths, including near-rounding ties')
local author=fakePlayer(8001)
handleAction(author,'StartTutorial');handleAction(author,'CreateChallenge')
check(not sessions[author].shareChallenge,'Tutorial or unfinished pizzas cannot become challenges')
handleAction(author,'StartShift');prepare(author);handleAction(author,'Bake');advance(25,author);handleAction(author,'Serve');handleAction(author,'NextOrder')
local original=sessions[author]
local duration=original.contract.duration
local heat=original.contract.heatMultiplier
local band=original.contract.temperatureBand
prepare(author);advance(32);handleAction(author,'Bake');advance(9,author);handleAction(author,'Turn');advance(20,author);handleAction(author,'Serve')
local result=original.result
check(result and result.total>=50,'Author completes a real wild-oven order')
check(Challenges.CanShareResult(result,'shift') and not Challenges.CanShareResult(result,'tutorial'),
 'Client and server share the same challenge eligibility for completed orders and tutorials')
handleAction(author,'CreateChallenge',{score=100,recipeId='bianca',duration=1})
local saved=original.shareChallenge
check(saved and saved.score==Challenges.Score(result.total) and saved.recipeId==original.recipeId,'Challenge ignores forged client scores and recipes')
check(saved.duration==duration and saved.heatMultiplier==heat and saved.temperatureBand==band,'Challenge freezes the actual deadline and oven modifiers')
local code=saved.id;handleAction(author,'CreateChallenge')
check(original.shareChallenge.id==code,'Repeated share requests reuse the same saved result')
local reader=fakePlayer(8002)
handleAction(reader,'LookupChallenge',code)
check(sessions[reader].pendingChallenge.id==code and sessions[reader].phase=='menu','Lookup previews a challenge without starting an order')
handleAction(reader,'LookupChallenge','FFFFFFFFFFFF')
check(sessions[reader].challengeStatus=='@challenge.wait','Rapid lookup reports cooldown instead of a stale successful response')
handleAction(reader,'AcceptChallenge','FFFFFFFFFFFF')
check(sessions[reader].phase=='menu','Accept rejects a code that was not previewed')
handleAction(reader,'AcceptChallenge',code)
check(snapshot(reader).pendingChallenge==nil,'Accept consumes the pending preview while retaining the active challenge')
local trial=sessions[reader]
check(trial.mode=='challenge' and trial.recipeId==saved.recipeId and trial.deadline-trial.startedAt==duration and trial.contract.heatMultiplier==heat and trial.contract.temperatureBand==band,'Acceptance replays the saved recipe, oven and time limit')
prepare(reader);handleAction(reader,'Bake');advance(9,reader);handleAction(reader,'Turn');advance(20,reader);handleAction(reader,'Serve')
check(trial.result.challenge.id==code and trial.result.challenge.outcome=='won','A real faster attempt beats the original result')
check(trial.result.reward.contractBonus==nil and trial.result.reward.dailyBonus==nil and trial.profile.data.battleWins==0,'Friend challenges do not farm contract, daily or Battle rewards')
local xp=trial.profile.data.xp;handleAction(reader,'Serve')
check(trial.profile.data.xp==xp,'Repeated Serve cannot duplicate challenge rewards')
handleAction(reader,'CreateChallenge');local response=trial.shareChallenge
check(response and response.id~=code and response.creatorId==reader.UserId,'The response creates an independent challenge owned by the responding chef')
handleAction(reader,'RetryChallenge')
check(trial.phase=='prep' and trial.activeChallenge.id==code and trial.shareChallenge==nil,'Retry resets cooking and sharing while keeping the original opponent')
advance(duration+.1)
check(trial.phase=='result' and trial.result.total==0 and trial.result.challenge.outcome=='lost','Unfinished timed challenge expires with a losing result')
handleAction(reader,'CreateChallenge')
check(not trial.shareChallenge,'Timed-out pizzas are not shareable')
local loaded=challengeStore:Load(code)
result.ingredients.tomato=99
check(loaded.ingredients.tomato~=99,'Saved ingredients are detached from mutable session results')
TestPlayers.PlayerRemoving.callback(author)
check(challengeStore:Load(code).creatorId==8001,'Challenge remains readable after its author leaves')
local newcomer=fakePlayer(8003)
function newcomer:GetJoinData()return {LaunchData='pc1:'..code}end
readChallengeInvite(newcomer)
check(sessions[newcomer].pendingChallenge.id==code and sessions[newcomer].phase=='menu','Join data loads a preview without bypassing player consent')
local blocked=fakePlayer(8004);sessions[blocked].profile.status='loading'
handleAction(blocked,'LookupChallenge',code)
check(sessions[blocked].challengeStatus=='@server.loading' and sessions[blocked].challengeRevision==1,'Loading profile returns a completed request generation rather than hanging the UI')
local invalid=table.clone(loaded);invalid.rulesVersion='future'
check(select(2,Challenges.Validate(invalid,Recipes,TestEpoch))=='@challenge.outdated','Changed scoring versions cannot silently accept old targets')
invalid=table.clone(loaded);invalid.recipeSignature='changed'
check(select(2,Challenges.Validate(invalid,Recipes,TestEpoch))=='@challenge.outdated','Changed recipe contents invalidate the stored target')
invalid=table.clone(loaded);invalid.score=0/0
check(not Challenges.Validate(invalid,Recipes,TestEpoch),'Nonfinite stored scores are rejected')
invalid=table.clone(loaded);invalid.ingredients={tomato=99}
check(not Challenges.Validate(invalid,Recipes,TestEpoch),'Invalid stored topping counts are rejected')
local expiring=fakePlayer(8005);handleAction(expiring,'LookupChallenge',code)
local epochBefore=TestEpoch;TestEpoch=loaded.expiresAt
check(snapshot(expiring).pendingChallenge==nil,'An expired preview is hidden from the menu')
handleAction(expiring,'AcceptChallenge',code)
check(sessions[expiring].phase=='menu' and sessions[expiring].message=='@challenge.expired','Expiry is rechecked at acceptance, not only lookup')
check(select(2,challengeStore:Load(code))=='@challenge.expired','Cached records also honor their expiry')
TestEpoch=epochBefore
-- New Store instances model independent servers with one durable backing store.
local backing,calls,fail={},0,false
local function clone(v)if type(v)~='table'then return v end;local r={};for k,x in pairs(v)do r[k]=clone(x)end;return r end
local db={}
function db:UpdateAsync(key,callback)
 calls+=1;if fail then error('offline')end
 local result=callback(clone(backing[key]))
 result=callback(clone(backing[key])) -- Roblox may retry a transform.
 if result~=nil then backing[key]=clone(result)end
 return clone(result)
end
function db:GetAsync(key)calls+=1;if fail then error('offline')end;return clone(backing[key])end
local seq=100
local deps={localOnly=false,now=function()return TestEpoch end,newId=function()seq+=1;return string.format('%012X',seq)end,getStore=function()return db end}
local storeA=rawChallengeNew(deps)
local durable=assert(storeA:Create(loaded))
local storeB=rawChallengeNew(deps)
check(storeB:Load(durable.id).score==loaded.score,'A fresh server can load a durable challenge after the author server is gone')
local before=calls
check(storeB:Load(durable.id)~=nil and calls==before,'Valid cached reads avoid repeated DataStore requests')
local damaged=storeB:Load(durable.id);damaged.ingredients.tomato=99
check(storeB:Load(durable.id).ingredients.tomato~=99,'Read results cannot mutate the storage cache')
local collisionDeps=table.clone(deps);local attempts=0
collisionDeps.newId=function()attempts+=1;return attempts==1 and durable.id or '111111111111'end
local colliding=rawChallengeNew(collisionDeps)
check(colliding:Create(loaded).id=='111111111111' and backing['challenge_'..durable.id].creatorId==loaded.creatorId,'A code collision retries without overwriting an existing challenge')
fail=true
local outage=rawChallengeNew(deps)
check(select(2,outage:Load(durable.id))=='@challenge.unavailable' and select(2,outage:Create(loaded))=='@challenge.unavailable','Store outages return recoverable errors without fictional success')
fail=false
check(outage:Load(durable.id)~=nil,'A failed read can recover on retry')
local wrongKey='222222222222';backing['challenge_'..wrongKey]=clone(durable)
check(not rawChallengeNew(deps):Load(wrongKey),'Storage records must match the requested code')
local offlineCalls=calls
local localStore=rawChallengeNew({localOnly=true,now=deps.now,newId=deps.newId,getStore=function()error('cloud accessed')end})
local localRecord=assert(localStore:Create(loaded));assert(localStore:Load(localRecord.id))
check(calls==offlineCalls,'Studio create and lookup never contact a cloud DataStore')
-- Yielded writes cannot attach one pizza's challenge to a newer result.
local race=fakePlayer(8006);handleAction(race,'StartPractice','margherita');prepare(race);handleAction(race,'Bake');advance(20,race);handleAction(race,'Serve')
local originalCreate=challengeStore.Create
challengeStore.Create=function(self,source)coroutine.yield();return originalCreate(self,source)end
local co=coroutine.create(function()handleAction(race,'CreateChallenge')end)
assert(coroutine.resume(co));check(sessions[race].challengeBusy,'In-flight challenge writes are serialized')
handleAction(race,'StartPractice','pepperoni')
assert(coroutine.resume(co));challengeStore.Create=originalCreate
check(sessions[race].phase=='prep' and sessions[race].shareChallenge==nil and not sessions[race].challengeBusy,'Late save cannot attach a previous pizza to a new run')
return {passed=#reports,checks=reports,liveDataStoreAccess=false}
'''
assert marker in s
(root/'tests/generated-challenge-validation.luau').write_text(s.replace(marker,checks))
print(root/'tests/generated-challenge-validation.luau')
