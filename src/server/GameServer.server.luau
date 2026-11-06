-- Pizza Chief: the server owns ingredients, cooking, clocks and competition scores.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local shared = ReplicatedStorage:WaitForChild("PizzaChief")
local Recipes = require(shared:WaitForChild("Recipes"))
local Rules = require(shared:WaitForChild("GameRules"))
local ProfileStore = require(script.Parent:WaitForChild("ProfileStore"))

local function remote(name, className)
	local existing = shared:FindFirstChild(name)
	if existing then
		assert(existing:IsA(className), name .. " has the wrong class")
		return existing
	end
	local instance = Instance.new(className)
	instance.Name = name
	instance.Parent = shared
	return instance
end
local Action = remote("Action", "RemoteEvent")
local State = remote("State", "RemoteEvent")
local GetState = remote("GetState", "RemoteFunction")

-- Local prototype defaults. ConfigService can supply live balance in a published game.
local Settings = {
	MinPlayers = 2, MaxPlayers = 6, Countdown = 10, RoundDuration = 90,
	ResultsDuration = 12, MaxPerIngredient = 3, MaxIngredients = 20,
	MinTemperature = 260, MaxTemperature = 520, BroadcastInterval = 0.2,
}
local ingredientIds = {}
for _, ingredient in ipairs(Recipes.Ingredients) do ingredientIds[ingredient.id] = true end
assert(#Recipes.List > 0, "At least one recipe is required")
local defaultRecipe = Recipes.List[1].id
local sessions = {}
local retiringProfiles = {}
local shuttingDown = false
local room = { phase = "waiting", members = {}, queue = {}, startsAt = 0, endsAt = 0, finishedAt = 0, recipeId = defaultRecipe, winner = nil }
local roundNumber = 0
local publishAll

local function now() return workspace:GetServerTimeNow() end
local function count(dictionary)
	local n = 0
	for _ in pairs(dictionary) do n += 1 end
	return n
end
local function copyIngredients(ingredients)
	local copy = {}
	for id, amount in pairs(ingredients) do copy[id] = amount end
	return copy
end
local function validRecipe(id) return type(id) == "string" and Recipes.ById[id] ~= nil end
local function finite(value) return type(value) == "number" and value == value and math.abs(value) < math.huge end

local function newSession(player)
	return {
		phase = "menu", mode = "practice", recipeId = defaultRecipe, ingredients = {},
		startedAt = 0, deadline = 0, temperature = 20, heat = 0.5,
		bakeElapsed = 0, bakeDuration = 0, bakeQuality = 0, bakeIntegral = 0,
		result = nil, completedRoom = nil, message = "", roomMember = false, queued = false,
		tokens = 25, tokenAt = now(),
		profile = ProfileStore.Create(player.UserId), shift = nil, contract = nil, shiftSerial = 0, combo = 0,
	}
end

local function roomSnapshot(player)
	local rows = {}
	for userId, entry in pairs(room.members) do
		local result = entry.result
		table.insert(rows, {
			userId = userId, name = entry.name, done = entry.done == true,
			total = result and result.total or nil,
			quality = result and result.quality or nil,
			speed = result and result.speed or nil,
			elapsed = entry.elapsed, forfeited = entry.forfeited == true,
		})
	end
	table.sort(rows, function(a, b)
		if (a.total or -1) ~= (b.total or -1) then return (a.total or -1) > (b.total or -1) end
		if (a.quality or -1) ~= (b.quality or -1) then return (a.quality or -1) > (b.quality or -1) end
		if (a.elapsed or math.huge) ~= (b.elapsed or math.huge) then return (a.elapsed or math.huge) < (b.elapsed or math.huge) end
		return a.userId < b.userId
	end)
	return {
		phase = room.phase, players = rows, startsAt = room.startsAt, endsAt = room.endsAt,
		recipeId = room.recipeId, winner = room.winner, minPlayers = Settings.MinPlayers,
		maxPlayers = Settings.MaxPlayers, queuedCount = count(room.queue),
		member = sessions[player] ~= nil and sessions[player].roomMember == true,
		queued = room.queue[player.UserId] ~= nil,
	}
end

local function profileSnapshot(s)
	local p = s.profile.data
	local result = {}
	for key, value in pairs(p) do result[key] = value end
	for key, value in pairs(Rules.Rank(p.xp)) do result[key] = value end
	result.badges = Rules.Badges(p)
	result.persistence = s.profile.status
	return result
end

local function snapshot(player)
	local s = sessions[player]
	if not s then return nil end
	return {
		phase = s.phase, mode = s.mode, recipeId = s.recipeId,
		ingredients = copyIngredients(s.ingredients), startedAt = s.startedAt,
		deadline = s.deadline, temperature = s.temperature, heat = s.heat,
		bakeElapsed = s.bakeElapsed, bakeDuration = s.bakeDuration,
		bakeQuality = s.bakeQuality, result = s.result, message = s.message,
		queued = s.queued, serverNow = now(),
		profile = profileSnapshot(s), shift = s.shift, contract = s.contract, combo = s.combo,
		dailyChallenge = Rules.Daily(math.floor(os.time() / 86400), Recipes),
		daily = Rules.Daily(math.floor(os.time() / 86400), Recipes),
		room = (s.mode == "competition" and s.phase == "result" and not s.roomMember and s.completedRoom) or roomSnapshot(player),
	}
end

publishAll = function()
	for player in pairs(sessions) do
		if player.Parent == Players then State:FireClient(player, snapshot(player)) end
	end
end

local function beginPizza(s, mode, recipeId, startedAt, deadline, contract)
	s.phase, s.mode, s.recipeId = "prep", mode, recipeId
	s.contract = contract
	s.ingredients, s.result, s.completedRoom, s.message = {}, nil, nil, ""
	s.startedAt, s.deadline = startedAt, deadline or 0
	s.temperature, s.heat = 20, 0.5
	s.bakeElapsed, s.bakeDuration, s.bakeIntegral, s.bakeQuality = 0, 0, 0, 0
end

local function zeroResult(s, feedback)
	return {
		recipeName = Recipes.ById[s.recipeId].name, recipeScore = 0, bakeScore = 0,
		quality = 0, speed = 0, total = 0, feedback = feedback,
	}
end

local function rememberResult(player, s, result, elapsed)
	-- This function is entered once per server-owned pizza, never from client scores.
	if s.phase == "result" then return end
	result.elapsed = math.floor(elapsed * 10 + 0.5) / 10
	local p = s.profile.data
	local oldRank = Rules.Rank(p.xp)
	local best = p.recipeBest[s.recipeId] or { score = 0, stars = 0 }
	local previous = best.score
	if s.mode == "daily" then
		local daily = p.dailyBest or { day = 0, score = 0 }
		previous = daily.day == s.contract.dayKey and daily.score or 0
	end
	result.previousBest = previous
	result.delta = result.total - previous
	result.personalBest = result.total > previous + 0.001
	if s.mode == "daily" and result.total > 0 then
		p.dailyBest = { day = s.contract.dayKey, score = math.max(previous, result.total) }
	end
	local combo = s.combo or 0
	local reward = Rules.Reward(result, s.mode, combo, result.personalBest)
	result.reward = reward
	s.combo = reward.nextCombo or 0
	p.bestCombo = math.max(p.bestCombo, s.combo)
	if reward.xp > 0 then
		p.completed += 1
		if reward.stars == 3 then p.perfects += 1 end
		local newStars = math.max(best.stars, reward.stars)
		p.totalStars += newStars - best.stars
		p.recipeBest[s.recipeId] = { score = math.max(best.score, result.total), stars = newStars }
		if s.contract and s.mode ~= "daily" and result.total >= (s.contract.goal or 80) then
			reward.contractBonus = s.contract.bonusXP or 0
			reward.xp += reward.contractBonus
		end
		if s.mode == "daily" and result.total >= (s.contract.goal or 85) then
			local day = s.contract.dayKey
			if p.lastDailyDay ~= day then
				p.lastDailyDay, p.dailyClears = day, p.dailyClears + 1
				reward.dailyBonus = s.contract.bonusXP or 60
				reward.xp += reward.dailyBonus
			end
		end
	end
	if s.shift then
		local shift = s.shift
		shift.score += result.total
		shift.completed += 1
		shift.combo = reward.nextCombo or 0
		p.bestCombo = math.max(p.bestCombo, shift.combo)
		if shift.stage >= shift.total then
			shift.finished = true
			p.bestShift = math.max(p.bestShift, shift.score)
			if shift.score >= 150 then
				p.shiftFinishes += 1
				reward.shiftBonus = 30
				reward.xp += 30
			end
		end
	end
	p.xp += reward.xp
	local rank = Rules.Rank(p.xp)
	reward.leveledUp = rank.level > oldRank.level
	reward.newRank = rank.title
	reward.unlocked = math.max(0, rank.unlockedRecipes - oldRank.unlockedRecipes)
	s.result, s.phase, s.message = result, "result", ""
	local entry = room.members[player.UserId]
	if s.mode == "competition" and s.roomMember and entry then
		entry.done, entry.result, entry.elapsed = true, result, elapsed
	end
	local stats = player:FindFirstChild("leaderstats")
	if stats then
		local value = stats:FindFirstChild("Best")
		if value then value.Value = math.max(value.Value, math.floor(result.total + 0.5)) end
		local level = stats:FindFirstChild("Level")
		if level then level.Value = rank.level end
	end
end

local function serve(player, timedOut)
	local s = sessions[player]
	if not s or s.phase == "result" then return end
	local elapsed = math.max(0, now() - s.startedAt)
	if s.phase == "ready" then
		local result = Recipes.Score(s.recipeId, s.ingredients, s.bakeQuality, elapsed)
		rememberResult(player, s, result, elapsed)
	elseif timedOut then
		rememberResult(player, s, zeroResult(s, "Час вичерпано! Потрібно завершити випікання й подати піцу до кінця раунду."), elapsed)
	end
end

local function finishRoom()
	if room.phase ~= "active" then return end
	room.phase, room.finishedAt = "finished", now()
	local ranked = {}
	for userId, entry in pairs(room.members) do
		if entry.result and not entry.forfeited then
			table.insert(ranked, { userId = userId, entry = entry })
		end
	end
	table.sort(ranked, function(a, b)
		local ar, br = a.entry.result, b.entry.result
		if ar.total ~= br.total then return ar.total > br.total end
		if ar.quality ~= br.quality then return ar.quality > br.quality end
		if a.entry.elapsed ~= b.entry.elapsed then return a.entry.elapsed < b.entry.elapsed end
		return a.userId < b.userId
	end)
	if ranked[1] and ranked[1].entry.result.total > 0 then
		local first = ranked[1]
		room.winner = { userId = first.userId, name = first.entry.name, total = first.entry.result.total }
		local player = Players:GetPlayerByUserId(first.userId)
		if player and sessions[player] then
			sessions[player].profile.data.battleWins += 1
			if player:FindFirstChild("leaderstats") then player.leaderstats.Wins.Value = sessions[player].profile.data.battleWins end
		end
	end
	for _, entry in pairs(room.members) do
		if entry.player and sessions[entry.player] then
			local s = sessions[entry.player]
			s.roomMember = false
			s.completedRoom = roomSnapshot(entry.player)
		end
	end
end

local function checkFinished()
	if room.phase ~= "active" then return end
	for _, entry in pairs(room.members) do if not entry.done then return end end
	finishRoom()
end

local function resetRoom()
	local queued = room.queue
	room.members, room.queue = {}, {}
	room.phase, room.startsAt, room.endsAt, room.winner = "waiting", 0, 0, nil
	for userId, player in pairs(queued) do
		local s = sessions[player]
		if s and player.Parent == Players then
			room.members[userId] = { player = player, name = player.DisplayName, done = false }
			s.queued, s.roomMember = false, true
			s.phase, s.mode, s.message = "menu", "competition", "Очікуємо другого кухаря…"
		end
	end
end

local function leaveRoom(player, disconnected)
	local s = sessions[player]
	room.queue[player.UserId] = nil
	local entry = room.members[player.UserId]
	if entry then
		if room.phase == "active" and not entry.done then
			entry.forfeited, entry.done = true, true
			entry.elapsed = s and math.max(0, now() - s.startedAt) or 0
			entry.result = s and zeroResult(s, "Ти залишив змагання. За цей раунд зараховано поразку.") or nil
		elseif room.phase == "waiting" or room.phase == "countdown" then
			room.members[player.UserId] = nil
		end
	end
	if s then
		s.roomMember, s.queued = false, false
		if not disconnected then s.phase, s.mode, s.result, s.completedRoom, s.message = "menu", "practice", nil, nil, ""; s.shift, s.contract = nil, nil end
	end
	if room.phase == "countdown" and count(room.members) < Settings.MinPlayers then
		room.phase, room.startsAt = "waiting", 0
	end
	checkFinished()
end

local function joinRoom(player)
	local s = sessions[player]
	if s.roomMember or s.queued then return end
	-- A forfeited player cannot rejoin the same round or replace their result.
	if room.phase == "active" or room.phase == "finished" then
		if count(room.queue) >= Settings.MaxPlayers then s.message = "Наступна кімната вже повна. Спробуй трохи пізніше." return end
		room.queue[player.UserId] = player
		s.shift, s.contract = nil, nil
		s.queued, s.phase, s.mode, s.message = true, "menu", "competition", "Ти в черзі на наступний раунд. Поточне змагання ще триває."
		return
	end
	if count(room.members) >= Settings.MaxPlayers then s.message = "Кімната вже повна: 6 кухарів." return end
	room.members[player.UserId] = { player = player, name = player.DisplayName, done = false }
	s.shift, s.contract = nil, nil
	s.roomMember, s.queued = true, false
	s.phase, s.mode, s.result, s.message = "menu", "competition", nil, "Очікуємо другого кухаря…"
end

local function startShiftOrder(s)
	local contract = Rules.Contract(s.shift.seed, s.shift.stage, s.shift.unlockedRecipes, Recipes)
	beginPizza(s, "shift", contract.recipeId, now(), now() + contract.duration, contract)
end
local function isCompeting(s) return s.roomMember and room.phase == "active" end
local function handleAction(player, action, argument)
	local s = sessions[player]
	if not s or shuttingDown or type(action) ~= "string" then return end
	local time = now()
	s.tokens = math.min(25, s.tokens + math.max(0, time - s.tokenAt) * 15)
	s.tokenAt = time
	if s.tokens < 1 then return end
	s.tokens -= 1
	if s.deadline > 0 and time >= s.deadline and s.phase ~= "result" and s.phase ~= "menu" then
		serve(player, true)
		checkFinished()
	end
	s.message = ""
	if s.profile.status == "loading" and action ~= "Menu" and action ~= "LeaveRoom" then
		s.message = "Завантажуємо твою книгу майстерності…"
		return
	end
	if action == "LeaveRoom" then
		leaveRoom(player, false)
	elseif action == "JoinRoom" then
		joinRoom(player)
	elseif action == "Menu" or action == "StartPractice" or action == "StartShift" or action == "StartDaily" then
		if isCompeting(s) then s.message = "Дочекайся кінця раунду або вийди зі змагання." return end
		if action == "StartPractice" and argument ~= nil and not validRecipe(argument) then return end
		leaveRoom(player, false)
		if action == "StartPractice" then
			beginPizza(s, "practice", argument or s.recipeId, time, 0)
		elseif action == "StartShift" then
			s.shiftSerial += 1
			s.shift = { stage = 1, total = 3, score = 0, combo = s.combo, finished = false, completed = 0,
				unlockedRecipes = Rules.Rank(s.profile.data.xp).unlockedRecipes,
				seed = player.UserId + s.shiftSerial * 7919 + math.floor(time) }
			startShiftOrder(s)
		elseif action == "StartDaily" then
			local contract = Rules.Daily(math.floor(os.time() / 86400), Recipes)
			contract.dayKey = math.floor(os.time() / 86400)
			beginPizza(s, "daily", contract.recipeId, time, time + contract.duration, contract)
		end
	elseif action == "NextOrder" then
		if s.mode ~= "shift" or s.phase ~= "result" or not s.shift or s.shift.finished then return end
		s.shift.stage += 1
		startShiftOrder(s)
	elseif action == "SelectRecipe" then
		if not validRecipe(argument) or s.roomMember or s.queued then return end
		if s.phase == "menu" or (s.mode == "practice" and s.phase == "prep") then s.recipeId = argument end
	elseif action == "Add" then
		if s.phase ~= "prep" or type(argument) ~= "string" or not ingredientIds[argument] then return end
		local total = 0
		for _, amount in pairs(s.ingredients) do total += amount end
		if total >= Settings.MaxIngredients then s.message = "На піці забагато начинки! Спочатку прибери один інгредієнт." return end
		local amount = s.ingredients[argument] or 0
		if amount < Settings.MaxPerIngredient then s.ingredients[argument] = amount + 1 end
	elseif action == "Remove" then
		if s.phase ~= "prep" or type(argument) ~= "string" or not ingredientIds[argument] then return end
		local amount = s.ingredients[argument] or 0
		s.ingredients[argument] = amount > 1 and amount - 1 or nil
	elseif action == "Clear" then
		if s.phase == "prep" then s.ingredients = {} end
	elseif action == "Bake" then
		if s.phase ~= "prep" then return end
		if next(s.ingredients) == nil then s.message = "Спочатку додай інгредієнти, а потім відправляй піцу в піч." return end
		local recipe = Recipes.ById[s.recipeId]
		s.phase, s.bakeElapsed, s.bakeIntegral, s.bakeQuality = "bake", 0, 0, 0
		s.bakeDuration = recipe.bakeTime
		s.temperature = recipe.temperature - 50
		s.heat = math.clamp((recipe.temperature - Settings.MinTemperature) / (Settings.MaxTemperature - Settings.MinTemperature), 0, 1)
	elseif action == "Heat" then
		if s.phase == "bake" and finite(argument) then s.heat = math.clamp(argument, 0, 1) end
	elseif action == "Serve" then
		if s.phase == "ready" then serve(player, false) checkFinished() end
	end
end

Action.OnServerEvent:Connect(function(player, action, argument)
	handleAction(player, action, argument)
	if sessions[player] then State:FireClient(player, snapshot(player)) end
end)
GetState.OnServerInvoke = function(player) return snapshot(player) end

-- Departures remain tracked after their gameplay session has been removed.
-- BindToClose waits for this same registry, including the last player's save.
local function retireProfile(holder)
	if retiringProfiles[holder] then return end
	retiringProfiles[holder] = true
	holder.closing = true
	task.spawn(function()
		local deadline = os.clock() + 25
		repeat
			ProfileStore.Save(holder, true)
			if not holder.saving and holder.status ~= "loading" and not holder.writable then break end
			if os.clock() >= deadline then break end
			task.wait(holder.saving and 0.1 or 2)
		until os.clock() >= deadline
		retiringProfiles[holder] = nil
	end)
end

local function playerAdded(player)
	if sessions[player] then return end
	sessions[player] = newSession(player)
	local s = sessions[player]
	if s.profile.status == "loading" then task.spawn(function()
		ProfileStore.Load(s.profile)
		if sessions[player] ~= s or player.Parent ~= Players then retireProfile(s.profile) return end
		local loadedStats = player:FindFirstChild("leaderstats")
		if loadedStats then
			loadedStats.Wins.Value = s.profile.data.battleWins
			loadedStats.Level.Value = Rules.Rank(s.profile.data.xp).level
			local best = 0
			for _, entry in pairs(s.profile.data.recipeBest) do best = math.max(best, entry.score) end
			loadedStats.Best.Value = math.floor(best + 0.5)
		end
	end) end
	local stats = player:FindFirstChild("leaderstats") or Instance.new("Folder")
	stats.Name, stats.Parent = "leaderstats", player
	for _, name in ipairs({ "Wins", "Best", "Level" }) do
		if not stats:FindFirstChild(name) then
			local value = Instance.new("IntValue")
			value.Name, value.Parent = name, stats
			if name == "Level" then value.Value = 1 end
		end
	end
end
Players.PlayerAdded:Connect(playerAdded)
Players.PlayerRemoving:Connect(function(player)
	leaveRoom(player, true)
	local s = sessions[player]
	sessions[player] = nil
	if s then retireProfile(s.profile) end
	publishAll()
end)
for _, player in ipairs(Players:GetPlayers()) do playerAdded(player) end

local broadcastElapsed, saveElapsed = 0, 0
RunService.Heartbeat:Connect(function(dt)
	if shuttingDown then return end
	local time = now()
	-- A capped simulation step prevents a stalled frame from awarding a full bake.
	local step = math.min(dt, 0.25)
	for player, s in pairs(sessions) do
		if s.phase == "bake" then
			local recipe = Recipes.ById[s.recipeId]
			local multiplier = s.contract and s.contract.heatMultiplier or 1
			local drift = (math.sin(s.bakeElapsed * 0.72) * 55 + math.sin(s.bakeElapsed * 1.63) * 25) * multiplier
			local target = Settings.MinTemperature + s.heat * (Settings.MaxTemperature - Settings.MinTemperature) + drift
			s.temperature += (target - s.temperature) * (1 - math.exp(-step * 1.8))
			local used = math.min(step, s.bakeDuration - s.bakeElapsed)
			local distance = math.abs(s.temperature - recipe.temperature)
			local band = s.contract and s.contract.temperatureBand or 25
			local quality = math.clamp(1 - math.max(0, distance - band) / 90, 0, 1)
			s.bakeIntegral += quality * used
			s.bakeElapsed += used
			s.bakeQuality = s.bakeElapsed > 0 and (s.bakeIntegral / s.bakeElapsed * 100) or 0
			if s.bakeElapsed >= s.bakeDuration then
				s.phase, s.message = "ready", "Щойно з печі! Подавай піцу шефу Луці."
			end
		end
		if (s.mode == "shift" or s.mode == "daily") and s.deadline > 0 and time >= s.deadline and s.phase ~= "result" then
			serve(player, true)
		end
	end
	if room.phase == "waiting" and count(room.members) >= Settings.MinPlayers then
		room.phase, room.startsAt = "countdown", time + Settings.Countdown
	elseif room.phase == "countdown" and time >= room.startsAt then
		roundNumber += 1
		room.recipeId = Recipes.List[((roundNumber - 1) % #Recipes.List) + 1].id
		room.phase, room.startsAt, room.endsAt = "active", time, time + Settings.RoundDuration
		for _, entry in pairs(room.members) do
			local s = sessions[entry.player]
			if s then beginPizza(s, "competition", room.recipeId, time, room.endsAt) end
		end
	elseif room.phase == "active" and time >= room.endsAt then
		for _, entry in pairs(room.members) do
			if not entry.done and entry.player and sessions[entry.player] then serve(entry.player, true) end
		end
		finishRoom()
	elseif room.phase == "finished" and time - room.finishedAt >= Settings.ResultsDuration then
		resetRoom()
	end
	saveElapsed += dt
	if saveElapsed >= 45 then
		saveElapsed = 0
		for _, s in pairs(sessions) do task.spawn(function() ProfileStore.Save(s.profile, false) end) end
	end
	broadcastElapsed += dt
	if broadcastElapsed >= Settings.BroadcastInterval then
		broadcastElapsed = 0
		publishAll()
	end
end)

game:BindToClose(function()
	shuttingDown = true
	for _, s in pairs(sessions) do retireProfile(s.profile) end
	local deadline = os.clock() + 25
	while next(retiringProfiles) and os.clock() < deadline do task.wait(0.1) end
end)

print("Pizza Chief server ready: " .. #Recipes.List .. " recipes, server-authoritative cooking and six-chef rooms.")
