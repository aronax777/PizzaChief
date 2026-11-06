-- Server-only progression. Studio is deliberately session-only.
-- Published servers acquire a short lease before touching saved progress.
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Store = {}
local LEASE_SECONDS = 150
local LOAD_RETRY_SECONDS = 20
local dataStore
local numericFields = { "xp", "completed", "perfects", "battleWins", "bestCombo", "shiftFinishes", "dailyClears", "bestShift", "lastDailyDay" }
local function number(value, maximum)
	if type(value) ~= "number" or value ~= value or math.abs(value) == math.huge then return 0 end
	return math.clamp(value, 0, maximum or 100000000)
end
function Store.NewProfile()
	return { version = 2, xp = 0, completed = 0, perfects = 0, battleWins = 0, bestCombo = 0,
		shiftFinishes = 0, dailyClears = 0, bestShift = 0, lastDailyDay = 0, recipeBest = {}, dailyBest = { day = 0, score = 0 }, totalStars = 0 }
end
local function sanitize(raw)
	local result = Store.NewProfile()
	if type(raw) ~= "table" then return result end
	for _, field in ipairs(numericFields) do result[field] = number(raw[field]) end
	result.bestCombo = math.min(5, result.bestCombo)
	result.bestShift = math.min(300, result.bestShift)
	if type(raw.dailyBest) == "table" then
		result.dailyBest = { day = math.floor(number(raw.dailyBest.day)), score = number(raw.dailyBest.score, 100) }
	end
	local n = 0
	if type(raw.recipeBest) == "table" then
		for id, best in pairs(raw.recipeBest) do
			if type(id) == "string" and #id <= 64 and type(best) == "table" and n < 100 then
				local stars = math.floor(number(best.stars, 3))
				result.recipeBest[id] = { score = number(best.score, 100), stars = stars }
				result.totalStars += stars
				n += 1
			end
		end
	end
	return result
end
function Store.Create(userId)
	local localOnly = RunService:IsStudio() or game.GameId == 0
	return { userId = userId, data = Store.NewProfile(), status = localOnly and "session" or "loading",
		owner = HttpService:GenerateGUID(false), writable = false, saving = false }
end
function Store.Load(holder)
	if holder.status ~= "loading" then return end
	-- Keep gameplay gated while a departing server finishes its release save.
	local deadline = os.clock() + LOAD_RETRY_SECONDS
	repeat
		if holder.closing then holder.status = "unavailable" return end
		local ok, result = pcall(function()
			dataStore = dataStore or game:GetService("DataStoreService"):GetDataStore("PizzaChiefProfiles_v2")
			return dataStore:UpdateAsync("player_" .. holder.userId, function(old)
				local lease = type(old) == "table" and old._lease
				if type(lease) == "table" and lease.owner ~= holder.owner and number(lease.expires, 1000000000000) > os.time() then return nil end
				local clean = sanitize(old)
				clean._lease = { owner = holder.owner, expires = os.time() + LEASE_SECONDS }
				return clean
			end)
		end)
		if ok and type(result) == "table" and type(result._lease) == "table" and result._lease.owner == holder.owner then
			holder.data, holder.status, holder.writable = sanitize(result), "saved", true
			-- A join can finish loading after PlayerRemoving already requested release.
			if holder.closing or holder.releaseRequested then Store.Save(holder, true) end
			return
		end
		if holder.closing or os.clock() >= deadline then break end
		task.wait(math.min(2, math.max(0, deadline - os.clock())))
	until os.clock() >= deadline
	-- A failed/contended load must never turn a blank session into an overwrite.
	holder.status, holder.writable = "unavailable", false
end
function Store.Save(holder, release)
	if release then holder.releaseRequested, holder.closing = true, true end
	if not holder.writable then return false end
	if holder.saving then return false end
	holder.saving = true
	local finalSave = holder.releaseRequested == true
	local saved = sanitize(holder.data)
	local owned = false
	local ok = pcall(function()
		dataStore:UpdateAsync("player_" .. holder.userId, function(old)
			owned = false
			local lease = type(old) == "table" and old._lease
			if type(lease) ~= "table" or lease.owner ~= holder.owner then return nil end
			owned = true
			saved._lease = not finalSave and { owner = holder.owner, expires = os.time() + LEASE_SECONDS } or nil
			return saved
		end)
	end)
	holder.saving = false
	if ok and owned then
		holder.status = "saved"
		if finalSave then
			holder.writable = false
		elseif holder.releaseRequested then
			-- Snapshot again: rewards may have arrived while the autosave yielded.
			return Store.Save(holder, true)
		end
		return true
	end
	holder.status = "unavailable"
	if ok and not owned then holder.writable = false end
	return false
end
return Store
