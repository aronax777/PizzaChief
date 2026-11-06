"""Generate an isolated Studio Luau validation chunk from the actual server source.

The generated chunk mocks Players, remotes, clocks, and Heartbeat; it only reads
ReplicatedStorage.PizzaChief.Recipes. It does not install scripts or touch live
players. Execute the generated text with Studio execute_luau in Server or Edit.
"""
from pathlib import Path

root = Path(__file__).resolve().parents[1]
source = (root / 'src/server/GameServer.server.luau').read_text()
recipes = (root / 'src/shared/Recipes.luau').read_text()
rules = (root / 'src/shared/GameRules.luau').read_text()
profile_store = (root / 'src/server/ProfileStore.luau').read_text()
replacements = {
    'local Players = game:GetService("Players")': 'local Players = TestPlayers',
    'local ReplicatedStorage = game:GetService("ReplicatedStorage")': 'local ReplicatedStorage = nil',
    'local RunService = game:GetService("RunService")': 'local RunService = TestRunService',
    'local shared = ReplicatedStorage:WaitForChild("PizzaChief")': 'local shared = TestShared',
    'local Recipes = require(shared:WaitForChild("Recipes"))': 'local Recipes = TestRecipes',
    'workspace:GetServerTimeNow()': 'TestClock',
    'local Rules = require(shared:WaitForChild("GameRules"))': 'local Rules = TestRules',
    'local ProfileStore = require(script.Parent:WaitForChild("ProfileStore"))': 'local ProfileStore = TestProfileStore',
    'game:BindToClose(': 'TestBindToClose(',
    'os.time()': 'TestEpoch',
}
for before, after in replacements.items():
    assert before in source, before
    source = source.replace(before, after)

prefix = r'''
-- ISOLATED VALIDATION ONLY: no fake-player hooks are installed in the game.
local TestClock = 1000
local TestEpoch = 1793990000
local function TestBindToClose(_) end
local function signal()
    return { Connect = function(self, callback) self.callback = callback; return { Disconnect = function() end } end }
end
local TestPlayers = { PlayerAdded = signal(), PlayerRemoving = signal(), list = {} }
function TestPlayers:GetPlayers() return {} end
function TestPlayers:GetPlayerByUserId(userId) return self.list[userId] end
local TestRunService = { Heartbeat = signal(), IsStudio = function() return true end }
local testRemotes = {}
for _, pair in ipairs({ {"Action", "RemoteEvent"}, {"State", "RemoteEvent"}, {"GetState", "RemoteFunction"} }) do
    testRemotes[pair[1]] = { ClassName = pair[2], OnServerEvent = signal(), FireClient = function() end,
        IsA = function(self, kind) return self.ClassName == kind end }
end
local TestShared = { FindFirstChild = function(_, name) return testRemotes[name] end }
'''
suffix = r'''
local reports = {}
local function check(condition, detail) assert(condition, detail); table.insert(reports, detail) end
local function fakePlayer(id)
    local stats = { Wins = { Value = 0 }, Best = { Value = 0 }, Level = { Value = 1 } }
    function stats:FindFirstChild(name) return self[name] end
    local p = { UserId = id, DisplayName = "TestChef" .. id, Name = "TestChef" .. id,
        Parent = TestPlayers, leaderstats = stats }
    function p:FindFirstChild(name) return name == "leaderstats" and stats or nil end
    TestPlayers.list[id] = p
    playerAdded(p)
    return p
end
local function advance(seconds, controlPlayer)
    local remaining = seconds
    while remaining > 0.00001 do
        local dt = math.min(0.1, remaining)
        if controlPlayer and sessions[controlPlayer].phase == "bake" then
            local s = sessions[controlPlayer]
            local drift = (math.sin(s.bakeElapsed * 0.72) * 55 + math.sin(s.bakeElapsed * 1.63) * 25) * (s.contract and s.contract.heatMultiplier or 1)
            local recipe = Recipes.ById[s.recipeId]
            handleAction(controlPlayer, "Heat", (recipe.temperature - drift - 260) / 260)
        end
        TestClock += dt
        TestRunService.Heartbeat.callback(dt)
        remaining -= dt
    end
end
local function prepare(p)
    local recipe = Recipes.ById[sessions[p].recipeId]
    for id, portions in pairs(recipe.ingredients) do
        for _ = 1, portions do handleAction(p, "Add", id) end
    end
end
local p1, p2, p3, p4 = fakePlayer(101), fakePlayer(102), fakePlayer(103), fakePlayer(104)
sessions[p4].profile.status = "loading"
for _, action in ipairs({"StartPractice", "StartShift", "StartDaily", "JoinRoom", "NextOrder", "Add", "Bake", "Serve"}) do
    handleAction(p4, action, "margherita")
end
check(sessions[p4].phase == "menu" and sessions[p4].profile.data.xp == 0 and not sessions[p4].roomMember,
    "Async profile loading blocks every progression start and reward path")
sessions[p4].profile.status = "session"
handleAction(p1, "StartPractice", defaultRecipe)
handleAction(p1, "Serve")
handleAction(p1, "Add", "not_an_ingredient")
handleAction(p1, "Bake")
check(sessions[p1].phase == "prep" and next(sessions[p1].ingredients) == nil, "Invalid ingredients, premature serve and empty bake rejected")
prepare(p1)
handleAction(p1, "Bake")
local beforeHeat = sessions[p1].heat
handleAction(p1, "Heat", 0 / 0)
handleAction(p1, "Heat", math.huge)
check(sessions[p1].heat == beforeHeat, "Non-finite oven input rejected")
advance(Recipes.ById[defaultRecipe].bakeTime + 0.2)
local idleQuality = sessions[p1].bakeQuality
handleAction(p1, "Serve")
check(sessions[p1].phase == "result" and sessions[p1].result.total > 0, "Practice completes through real scoring module")
handleAction(p1, "StartPractice", defaultRecipe)
prepare(p1)
handleAction(p1, "Bake")
advance(Recipes.ById[defaultRecipe].bakeTime + 0.2, p1)
local controlledQuality = sessions[p1].bakeQuality
check(controlledQuality > idleQuality and idleQuality < 95, "Active oven control improves baking over idle power")
handleAction(p1, "Menu")
handleAction(p1, "JoinRoom")
advance(0.1)
check(room.phase == "waiting", "One chef waits without starting")
handleAction(p2, "JoinRoom")
advance(0.1)
check(room.phase == "countdown", "Second chef starts countdown")
handleAction(p2, "LeaveRoom")
check(room.phase == "waiting", "Leaving countdown cancels it")
handleAction(p2, "JoinRoom")
advance(10.3)
check(room.phase == "active" and sessions[p1].recipeId == sessions[p2].recipeId and sessions[p1].deadline == sessions[p2].deadline, "Two chefs share recipe, start and deadline")
handleAction(p3, "JoinRoom")
check(sessions[p3].queued and not sessions[p3].roomMember and sessions[p3].phase == "menu", "Late arrival queues without entering current round")
handleAction(p1, "StartPractice", defaultRecipe)
check(sessions[p1].mode == "competition", "Active participant cannot switch modes to evade round")
prepare(p1)
handleAction(p1, "Bake")
advance(Recipes.ById[sessions[p1].recipeId].bakeTime + 0.2, p1)
handleAction(p1, "Serve")
check(room.members[p1.UserId].done and room.phase == "active", "Serving locks result while another chef remains active")
advance(math.max(0, room.endsAt - TestClock) + 0.1)
check(room.phase == "finished" and sessions[p2].result.total == 0 and room.winner.userId == p1.UserId, "Deadline scores unfinished pizza zero and declares correct winner")
local finalTotal = sessions[p1].result.total
advance(12.2)
check(room.phase == "waiting" and sessions[p3].roomMember, "Queued chef enters fresh room after results interval")
local saved = snapshot(p1)
check(saved.phase == "result" and #saved.room.players == 2 and saved.room.winner.userId == p1.UserId and saved.result.total == finalTotal, "Completed standings persist after live room resets")
handleAction(p4, "JoinRoom")
advance(10.3)
check(room.phase == "active", "Next competition starts independently")
leaveRoom(p3, true)
sessions[p3] = nil
check(room.members[p3.UserId].forfeited and room.members[p3.UserId].done, "Disconnect forfeits without blocking remaining chef")
prepare(p4)
handleAction(p4, "Bake")
advance(Recipes.ById[sessions[p4].recipeId].bakeTime + 0.2, p4)
-- Do not serve: ready pizza is automatically judged at the deadline.
advance(math.max(0, room.endsAt - TestClock) + 0.1)
check(room.phase == "finished" and sessions[p4].result.total > 0 and room.winner.userId == p4.UserId, "Deadline auto-serves ready pizza and excludes forfeited chef")
handleAction(p4, "JoinRoom")
check(sessions[p4].queued and sessions[p4].phase == "menu" and not snapshot(p4).room.member, "Battle replay queues with accurate membership")
handleAction(p4, "LeaveRoom")
check(not sessions[p4].queued and not snapshot(p4).room.member, "Queued chef can cancel cleanly")

-- Replay and progression integration, still using actual server code.
local p5 = fakePlayer(105)
local fresh = snapshot(p5)
check(fresh.profile.level == 1 and fresh.profile.xp == 0 and fresh.profile.persistence == "session", "New profile is playable and honestly session-only in Studio")
handleAction(p5, "StartShift")
local shift = sessions[p5].shift
check(sessions[p5].mode == "shift" and shift.stage == 1 and shift.total == 3 and sessions[p5].deadline > TestClock,
    "Career shift starts with one timed server-selected order")
local firstRecipe = sessions[p5].recipeId
handleAction(p5, "NextOrder")
check(shift.stage == 1 and sessions[p5].phase == "prep", "NextOrder cannot skip an unfinished order")
prepare(p5); handleAction(p5, "Bake"); advance(sessions[p5].bakeDuration + .2, p5); handleAction(p5, "Serve")
local firstResult = sessions[p5].result
local earnedXP = sessions[p5].profile.data.xp
check(firstResult.reward.xp > 0 and firstResult.personalBest and firstResult.reward.stars == 3 and shift.completed == 1,
    "Successful career pizza earns stars XP personal best and one completed order")
handleAction(p5, "Serve"); handleAction(p5, "Serve")
check(sessions[p5].profile.data.xp == earnedXP and shift.completed == 1, "Repeated Serve cannot duplicate XP or shift credit")
handleAction(p5, "NextOrder"); handleAction(p5, "NextOrder")
check(shift.stage == 2 and sessions[p5].phase == "prep" and sessions[p5].contract.heatMultiplier > 1,
    "NextOrder advances once and introduces the stronger oven challenge")
advance(sessions[p5].deadline - TestClock + .1)
check(sessions[p5].phase == "result" and sessions[p5].result.total == 0 and sessions[p5].profile.data.xp == earnedXP and shift.combo == 0,
    "Unfinished career order times out without XP and resets only the shift combo")
handleAction(p5, "NextOrder")
check(shift.stage == 3 and sessions[p5].contract.duration == 65, "Final shift order has a clear shorter deadline")
prepare(p5); handleAction(p5, "Bake"); advance(sessions[p5].bakeDuration + .2, p5); handleAction(p5, "Serve")
check(shift.finished and shift.completed == 3 and sessions[p5].profile.data.bestShift > 150,
    "Three orders finish the shift and preserve the aggregate personal best")
local finishedXP, finishedScore = sessions[p5].profile.data.xp, shift.score
handleAction(p5, "NextOrder");handleAction(p5, "Serve")
check(shift.stage == 3 and shift.score == finishedScore and sessions[p5].profile.data.xp == finishedXP,
    "A finished shift cannot advance or grant its completion reward twice")
local personal = sessions[p5].profile.data.recipeBest[firstRecipe]
handleAction(p5, "StartPractice", firstRecipe)
handleAction(p5, "Add", "garlic"); handleAction(p5, "Bake"); advance(sessions[p5].bakeDuration + .2); handleAction(p5, "Serve")
check(sessions[p5].profile.data.recipeBest[firstRecipe].score == personal.score and sessions[p5].profile.data.recipeBest[firstRecipe].stars == personal.stars,
    "A worse replay never erases earned stars or personal records")
local p6 = fakePlayer(106)
local dailyRecipeId=Rules.Daily(math.floor(TestEpoch/86400),Recipes).recipeId
sessions[p5].profile.data.recipeBest[dailyRecipeId]={score=100,stars=3}
handleAction(p5, "StartDaily");handleAction(p6, "StartDaily")
check(sessions[p5].recipeId == sessions[p6].recipeId and sessions[p5].contract.id == sessions[p6].contract.id,
    "Different players receive the same daily challenge")
local dailyDay = sessions[p5].contract.dayKey
prepare(p5);handleAction(p5, "Bake");advance(sessions[p5].bakeDuration + .2,p5);handleAction(p5, "Serve")
local dailyResult = sessions[p5].result
check(dailyResult.previousBest == 0 and dailyResult.personalBest and sessions[p5].profile.data.dailyBest.score == dailyResult.total,
    "Daily personal best is independent of a perfect practice recipe record")
check(sessions[p5].profile.data.lastDailyDay == dailyDay and sessions[p5].profile.data.dailyClears == 1 and (dailyResult.reward.dailyBonus or 0) == 60,
    "First daily target clear grants the documented bonus once")
handleAction(p5, "StartDaily")
prepare(p5);handleAction(p5, "Bake");advance(sessions[p5].bakeDuration + .2,p5);handleAction(p5, "Serve")
check(math.abs(sessions[p5].result.previousBest-dailyResult.total)<0.001,
    "Repeated daily challenge compares against its own earlier daily score")
check(sessions[p5].profile.data.dailyClears == 1 and (sessions[p5].result.reward.dailyBonus or 0) == 0 and (sessions[p5].result.reward.contractBonus or 0) == 0 and sessions[p5].result.reward.xp > 0,
    "Daily replays keep normal XP without farming the daily or contract bonus")
TestEpoch += 86400
handleAction(p5, "StartDaily")
prepare(p5);handleAction(p5, "Bake");advance(sessions[p5].bakeDuration + .2,p5);handleAction(p5, "Serve")
check(sessions[p5].profile.data.dailyClears == 2 and sessions[p5].result.reward.dailyBonus == 60 and sessions[p5].result.previousBest == 0,
    "A new UTC day enables one new daily bonus")
handleAction(p6, "Menu")
advance(15)
handleAction(p5, "JoinRoom"); handleAction(p6, "JoinRoom"); advance(10.3)
check(sessions[p5].mode == "competition" and sessions[p6].mode == "competition", "Career chefs can return to a fair battle room")
handleAction(p5, "StartShift");handleAction(p5, "StartDaily")
check(sessions[p5].mode == "competition" and sessions[p5].shift == nil, "New career modes cannot evade an active battle")
local xpBeforeForfeit = sessions[p5].profile.data.xp
handleAction(p5, "LeaveRoom")
check(sessions[p5].profile.data.xp == xpBeforeForfeit and room.members[p5.UserId].forfeited,
    "Forfeiting a battle grants no progression reward")

local p7=fakePlayer(107)
handleAction(p7,"StartShift")
local frozenPool=sessions[p7].shift.unlockedRecipes
for stage=1,3 do
    local s=sessions[p7]
    check(s.shift.unlockedRecipes==frozenPool and s.recipeId==Rules.Contract(s.shift.seed,stage,frozenPool,Recipes).recipeId,
        "Career recipe pool remains fixed through shift order "..stage)
    prepare(p7);handleAction(p7,"Bake");advance(s.bakeDuration+.2,p7);handleAction(p7,"Serve")
    if stage<3 then handleAction(p7,"NextOrder") end
end
check(Rules.Rank(sessions[p7].profile.data.xp).unlockedRecipes>frozenPool,
    "A mid-shift rank increase does not change the current shift pool")
check(sessions[p7].combo==3,"Three excellent career orders form a three-pizza session combo")
handleAction(p7,"Menu")
check(sessions[p7].combo==3,"Returning to the menu preserves the earned session combo")
handleAction(p7,"StartShift")
check(sessions[p7].shift.combo==3,"A new shift continues the session combo")
for stage=1,2 do
    local s=sessions[p7]
    prepare(p7);handleAction(p7,"Bake");advance(s.bakeDuration+.2,p7);handleAction(p7,"Serve")
    if stage<2 then handleAction(p7,"NextOrder") end
end
local hasFire=false
for _,badge in ipairs(snapshot(p7).profile.badges) do if badge.id=="on_fire" then hasFire=true end end
check(sessions[p7].combo==5 and sessions[p7].profile.data.bestCombo==5 and hasFire,
    "Five-pizza combo achievement is reachable across successive shifts")
local closingChef = fakePlayer(1200)
handleAction(closingChef, "StartShift")
local closingState = sessions[closingChef]
shuttingDown = true
TestClock = closingState.deadline + 1
TestRunService.Heartbeat.callback(0.1)
handleAction(closingChef, "StartPractice", defaultRecipe)
check(closingState.phase == "prep" and closingState.mode == "shift" and closingState.result == nil and closingState.profile.data.xp == 0,
    "Shutdown freezes both automatic deadline rewards and remote gameplay before final snapshots")
shuttingDown = false
return { passed = #reports, checks = reports, idleBakeQuality = idleQuality, controlledBakeQuality = controlledQuality }


'''
output = root / 'tests/generated-room-validation.luau'
embedded = 'local TestRecipes = (function()\n' + recipes + '\nend)()\nlocal TestRules = (function()\n' + rules + '\nend)()\n'
profile_prefix = '''
local TestProfileStore = (function()
    local guid = 0
    local game = {GameId=0,GetService=function(_,name)
        if name=='RunService' then return TestRunService end
        if name=='HttpService' then return {GenerateGUID=function() guid+=1;return 'test-'..guid end} end
        error('Unexpected service access: '..name)
    end}
'''
output.write_text(embedded + prefix + profile_prefix + profile_store + '\nend)()\n' + source + '\n' + suffix)
print(output)
