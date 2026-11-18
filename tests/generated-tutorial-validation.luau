local TestRecipes = (function()
-- Pizza Chief: deliberately simplified game recipes, not food-safety guidance.
-- Colors use RGB bytes; portions are game units. Dough is supplied automatically.
local Recipes = {}

Recipes.Ingredients = {
	{id="tomato", name="@ingredient.tomato", color={197,54,40}, category="Sauce"},
	{id="mozzarella", name="@ingredient.mozzarella", color={255,241,195}, category="Cheese"},
	{id="basil", name="@ingredient.basil", color={67,151,77}, category="Herbs"},
	{id="garlic", name="@ingredient.garlic", color={249,232,195}, category="Herbs"},
	{id="oregano", name="@ingredient.oregano", color={111,133,62}, category="Herbs"},
	{id="olive_oil", name="@ingredient.olive_oil", color={218,182,54}, category="Herbs"},
	{id="parmesan", name="@ingredient.parmesan", color={239,208,126}, category="Cheese"},
	{id="gorgonzola", name="@ingredient.gorgonzola", color={185,210,178}, category="Cheese"},
	{id="ricotta", name="@ingredient.ricotta", color={252,247,230}, category="Cheese"},
	{id="pepperoni", name="@ingredient.pepperoni", color={164,44,36}, category="Protein"},
	{id="ham", name="@ingredient.ham", color={227,135,130}, category="Protein"},
	{id="mushroom", name="@ingredient.mushroom", color={181,153,120}, category="Vegetables"},
	{id="olive", name="@ingredient.olive", color={57,53,46}, category="Vegetables"},
	{id="artichoke", name="@ingredient.artichoke", color={151,168,83}, category="Vegetables"},
	{id="anchovy", name="@ingredient.anchovy", color={143,119,106}, category="Protein"},
	{id="caper", name="@ingredient.caper", color={109,133,62}, category="Vegetables"},
	{id="tuna", name="@ingredient.tuna", color={202,159,142}, category="Protein"},
	{id="onion", name="@ingredient.onion", color={172,102,159}, category="Vegetables"},
	{id="pepper", name="@ingredient.pepper", color={240,176,43}, category="Vegetables"},
	{id="pineapple", name="@ingredient.pineapple", color={250,211,78}, category="Vegetables"},
	{id="chicken", name="@ingredient.chicken", color={221,176,122}, category="Protein"},
	{id="bbq", name="@ingredient.bbq", color={111,51,31}, category="Sauce"},
	{id="bacon", name="@ingredient.bacon", color={177,82,63}, category="Protein"},
	{id="egg", name="@ingredient.egg", color={255,198,54}, category="Protein"},
	{id="black_pepper", name="@ingredient.black_pepper", color={74,62,51}, category="Herbs"},
	{id="pesto", name="@ingredient.pesto", color={82,123,51}, category="Sauce"},
	{id="rocket", name="@ingredient.rocket", color={69,135,58}, category="Herbs"},
	{id="sausage", name="@ingredient.sausage", color={137,77,52}, category="Protein"},
}

Recipes.List = {
	{id="margherita",name="Margherita",description="@recipe.margherita",ingredients={tomato=2,mozzarella=2,basil=1,olive_oil=1},temperature=430,bakeTime=18},
	{id="marinara",name="Marinara",description="@recipe.marinara",ingredients={tomato=2,garlic=1,oregano=1,olive_oil=1},temperature=440,bakeTime=18},
	{id="pepperoni",name="Pepperoni",description="@recipe.pepperoni",ingredients={tomato=2,mozzarella=2,pepperoni=2},temperature=410,bakeTime=20},
	{id="diavola",name="Diavola",description="@recipe.diavola",ingredients={tomato=2,mozzarella=2,pepperoni=2,olive=1,black_pepper=1},temperature=420,bakeTime=20},
	{id="funghi",name="Funghi",description="@recipe.funghi",ingredients={tomato=2,mozzarella=2,mushroom=2,oregano=1},temperature=410,bakeTime=20},
	{id="prosciutto",name="Prosciutto",description="@recipe.prosciutto",ingredients={tomato=2,mozzarella=2,ham=2},temperature=400,bakeTime=20},
	{id="capricciosa",name="Capricciosa",description="@recipe.capricciosa",ingredients={tomato=2,mozzarella=2,ham=1,mushroom=1,artichoke=1,olive=1},temperature=400,bakeTime=23},
	{id="quattro_formaggi",name="Quattro Formaggi",description="@recipe.quattro_formaggi",ingredients={mozzarella=2,ricotta=1,parmesan=1,gorgonzola=1},temperature=390,bakeTime=21},
	{id="carbonara",name="Carbonara",description="@recipe.carbonara",ingredients={mozzarella=2,bacon=2,egg=1,parmesan=1,black_pepper=1},temperature=380,bakeTime=22},
	{id="hawaiian",name="Hawaiian",description="@recipe.hawaiian",ingredients={tomato=2,mozzarella=2,ham=2,pineapple=2},temperature=390,bakeTime=22},
	{id="bbq_chicken",name="BBQ Chicken",description="@recipe.bbq_chicken",ingredients={bbq=2,mozzarella=2,chicken=2,onion=1},temperature=390,bakeTime=22},
	{id="vegetarian",name="Vegetarian",description="@recipe.vegetarian",ingredients={tomato=2,mozzarella=2,mushroom=1,pepper=1,onion=1,olive=1},temperature=400,bakeTime=23},
	{id="tonno_cipolla",name="Tonno e Cipolla",description="@recipe.tonno_cipolla",ingredients={tomato=2,mozzarella=2,tuna=2,onion=1},temperature=400,bakeTime=21},
	{id="napoli",name="Napoli",description="@recipe.napoli",ingredients={tomato=2,mozzarella=2,anchovy=1,caper=1,oregano=1},temperature=430,bakeTime=19},
	{id="pesto_chicken",name="Pesto Chicken",description="@recipe.pesto_chicken",ingredients={pesto=2,mozzarella=2,chicken=2,parmesan=1},temperature=390,bakeTime=22},
	{id="meat_feast",name="Meat Feast",description="@recipe.meat_feast",ingredients={tomato=2,mozzarella=2,pepperoni=1,sausage=1,bacon=1},temperature=390,bakeTime=24},
	{id="prosciutto_funghi",name="Prosciutto e Funghi",description="@recipe.prosciutto_funghi",ingredients={tomato=2,mozzarella=2,ham=2,mushroom=2},temperature=400,bakeTime=22},
	{id="boscaiola",name="Boscaiola",description="@recipe.boscaiola",ingredients={mozzarella=2,sausage=2,mushroom=2,olive_oil=1},temperature=390,bakeTime=23},
	{id="rucola",name="Rucola",description="@recipe.rucola",ingredients={tomato=2,mozzarella=2,ham=1,rocket=1,parmesan=1},temperature=410,bakeTime=20},
	{id="bianca",name="Bianca",description="@recipe.bianca",ingredients={mozzarella=2,ricotta=2,garlic=1,olive_oil=1},temperature=400,bakeTime=20},
}

Recipes.ById = {}
Recipes.IngredientById = {}
for _, ingredient in ipairs(Recipes.Ingredients) do
	Recipes.IngredientById[ingredient.id] = ingredient
end
for _, recipe in ipairs(Recipes.List) do
	Recipes.ById[recipe.id] = recipe
end

local categoryWeight = {Sauce=2, Cheese=1.5, Protein=2, Vegetables=1.25, Herbs=1}
local function finite(value)
	return type(value) == "number" and value == value and math.abs(value) < math.huge
end
local function count(value)
	if not finite(value) then return 0 end
	return math.clamp(math.floor(value), 0, 100)
end
local function weight(id)
	local ingredient = Recipes.IngredientById[id]
	return ingredient and categoryWeight[ingredient.category] or 2
end
local function displayName(id)
	local ingredient = Recipes.IngredientById[id]
	return ingredient and ingredient.name or "@ingredient.unknown"
end

-- Weighted intersection-over-union: omissions and excessive portions both hurt.
local function compare(recipe, selected)
	local intersection, union = 0, 0
	local missing, extra = {}, {}
	for id, expected in pairs(recipe.ingredients) do
		local actual = count(selected[id])
		local w = weight(id)
		intersection += math.min(actual, expected) * w
		union += math.max(actual, expected) * w
		if actual < expected then table.insert(missing, displayName(id)) end
		if actual > expected then table.insert(extra, displayName(id)) end
	end
	for id, value in pairs(selected) do
		local actual = count(value)
		if not recipe.ingredients[id] and actual > 0 then
			union += actual * weight(id)
			table.insert(extra, displayName(id))
		end
	end
	table.sort(missing)
	table.sort(extra)
	return {id=recipe.id,name=recipe.name,score=union > 0 and 100*intersection/union or 0,missing=missing,extra=extra}
end

function Recipes.Match(selected)
	selected = type(selected) == "table" and selected or {}
	local best = nil
	for _, recipe in ipairs(Recipes.List) do
		local candidate = compare(recipe, selected)
		if not best or candidate.score > best.score then best = candidate end
	end
	return best
end

function Recipes.Score(recipeId, selected, bakeQuality, elapsed)
	selected = type(selected) == "table" and selected or {}
	local recipe = Recipes.ById[recipeId]
	local match = recipe and compare(recipe, selected) or Recipes.Match(selected)
	local bake = finite(bakeQuality) and math.clamp(bakeQuality, 0, 100) or 0
	-- Recipe-specific par rewards faster prep instead of a flat first 45 seconds.
	local portions = 0
	for _, amount in pairs((recipe or Recipes.ById[match.id]).ingredients) do portions += amount end
	local par = (recipe or Recipes.ById[match.id]).bakeTime + 6 + portions * 0.5
	local speed = finite(elapsed) and elapsed >= 0 and math.clamp(100 - (elapsed - par) * 0.85, 0, 100) or 0
	-- No topping overlap means an unfinished/unrecognizable pizza, never free points.
	if match.score <= 0 then bake, speed = 0, 0 end
	local quality = match.score*0.65 + bake*0.35
	local total = quality*0.8 + speed*0.2
	local feedback
	if match.score <= 0 then
		feedback = "@feedback.empty"
	elseif #match.missing > 0 then
		feedback = {key="feedback.missing",params={ingredient=match.missing[1]}}
	elseif #match.extra > 0 then
		feedback = {key="feedback.extra",params={ingredient=match.extra[1]}}
	elseif bake < 55 then
		feedback = "@feedback.cold"
	elseif bake < 85 then
		feedback = "@feedback.warm"
	elseif speed < 60 then
		feedback = "@feedback.slow"
	else
		feedback = "@feedback.perfect"
	end
	return {
		recipeName=match.name, recipeScore=match.score, bakeScore=bake,
		quality=quality, speed=speed, total=total, feedback=feedback,
	}
end

return Recipes

end)()
local TestRules = (function()
-- Pure, deterministic replay rules. The server alone grants rewards and owns clocks.
local Rules = {}
Rules.Version = 2
Rules.StarterRecipes = 6
Rules.ShiftLength = 3
Rules.MaxCombo = 5

local ranks = {
	{xp=0, title="@rank.1", recipes=6},
	{xp=100, title="@rank.2", recipes=8},
	{xp=260, title="@rank.3", recipes=10},
	{xp=500, title="@rank.4", recipes=12},
	{xp=850, title="@rank.5", recipes=14},
	{xp=1300, title="@rank.6", recipes=16},
	{xp=1900, title="@rank.7", recipes=18},
	{xp=2700, title="@rank.8", recipes=20},
}
local function finite(value)
	return type(value)=="number" and value==value and math.abs(value)<math.huge
end
local function number(value, fallback)
	return finite(value) and value or (fallback or 0)
end
local function score(value)
	return math.clamp(number(value),0,100)
end

function Rules.Rank(xp)
	xp=math.max(0,number(xp))
	local level=1
	for index,rank in ipairs(ranks) do if xp>=rank.xp then level=index end end
	local current,nextRank=ranks[level],ranks[level+1]
	return {
		level=level, title=current.title, nextXP=nextRank and nextRank.xp or nil,
		progress=nextRank and math.clamp((xp-current.xp)/(nextRank.xp-current.xp),0,1) or 1,
		unlockedRecipes=current.recipes,
	}
end

function Rules.RecipeStars(recipeScore,bakeScore,total)
	local recipe,bake,overall=score(recipeScore),score(bakeScore),score(total)
	if recipe>=95 and bake>=90 and overall>=90 then return 3 end
	if recipe>=85 and bake>=75 and overall>=80 then return 2 end
	if overall>=50 and recipe>=50 then return 1 end
	return 0
end

local contracts={
	{id="classic",name="@contract.classic",description="@contract.classic.description",duration=90,heatMultiplier=1,temperatureBand=25,bonusXP=10,goal=70},
	{id="wild_oven",name="@contract.wild_oven",description="@contract.wild_oven.description",duration=80,heatMultiplier=1.35,temperatureBand=22,bonusXP=15,goal=75},
	{id="rush",name="@contract.rush",description="@contract.rush.description",duration=65,heatMultiplier=1.15,temperatureBand=23,bonusXP=25,goal=80},
}
local function hash(seed)
	local normalized=math.floor(math.abs(number(seed)))%2147483647
	return (normalized*48271+104729)%2147483647
end
local function copyContract(template,recipeId)
	return {
		id=template.id,name=template.name,description=template.description,
		recipeId=recipeId,duration=template.duration,heatMultiplier=template.heatMultiplier,
		temperatureBand=template.temperatureBand,bonusXP=template.bonusXP,goal=template.goal,
	}
end

function Rules.Contract(seed,stage,unlockedCount,Recipes)
	assert(type(Recipes)=="table" and type(Recipes.List)=="table" and #Recipes.List>0,"Recipe catalog required")
	stage=math.clamp(math.floor(number(stage,1)),1,Rules.ShiftLength)
	local count=math.clamp(math.floor(number(unlockedCount,Rules.StarterRecipes)),1,#Recipes.List)
	-- Consecutive recipes ensure a three-order shift has no repeats when 3+ are unlocked.
	local index=((hash(seed)+stage-1)%count)+1
	return copyContract(contracts[stage],Recipes.List[index].id)
end

function Rules.Daily(dayKey,Recipes)
	assert(type(Recipes)=="table" and type(Recipes.List)=="table" and #Recipes.List>0,"Recipe catalog required")
	local day=math.floor(number(dayKey))
	local choice=hash(day)
	local template=contracts[(choice%#contracts)+1]
	local result=copyContract(template,Recipes.List[(hash(day+7919)%#Recipes.List)+1].id)
	result.id="daily_"..tostring(day)
	result.name={key="contract.daily",params={name=template.name}}
	result.description={key="contract.daily.description",params={description=template.description}}
	result.duration=90
	result.bonusXP=60
	result.goal=85
	return result
end

function Rules.Reward(result,mode,combo,isPB)
	result=type(result)=="table" and result or {}
	local total,recipe,bake=score(result.total),score(result.recipeScore),score(result.bakeScore)
	if total<50 or recipe<50 then
		return {xp=0,combo=0,nextCombo=0,stars=0,headline="@reward.retry"}
	end
	local previous=math.clamp(math.floor(number(combo)),0,Rules.MaxCombo)
	local nextCombo=total>=80 and math.min(previous+1,Rules.MaxCombo) or 0
	local stars=Rules.RecipeStars(recipe,bake,total)
	local xp=12+stars*6+math.floor(total/10)+nextCombo*2+(isPB==true and 4 or 0)
	xp=math.clamp(xp,12,45)
	if mode=="practice" then xp=math.max(6,math.floor(xp*.55)) end
	local headline
	if isPB then headline="@reward.pb"
	elseif stars==3 then headline="@reward.three"
	elseif nextCombo>=3 then headline={key="reward.combo",params={count=nextCombo}}
	elseif stars==2 then headline="@reward.two"
	else headline="@reward.one" end
	return {xp=xp,combo=nextCombo,nextCombo=nextCombo,stars=stars,headline=headline}
end

function Rules.Badges(profile)
	profile=type(profile)=="table" and profile or {}
	local checks={
		{id="first_service",name="@badge.first_service",description="@badge.first_service.description",field="completed",target=1},
		{id="busy_kitchen",name="@badge.busy_kitchen",description="@badge.busy_kitchen.description",field="completed",target=10},
		{id="star_collector",name="@badge.star_collector",description="@badge.star_collector.description",field="totalStars",target=12},
		{id="recipe_atlas",name="@badge.recipe_atlas",description="@badge.recipe_atlas.description",field="totalStars",target=45},
		{id="golden_touch",name="@badge.golden_touch",description="@badge.golden_touch.description",field="perfects",target=1},
		{id="on_fire",name="@badge.on_fire",description="@badge.on_fire.description",field="bestCombo",target=5},
		{id="shift_leader",name="@badge.shift_leader",description="@badge.shift_leader.description",field="shiftFinishes",target=1},
		{id="battle_champion",name="@badge.battle_champion",description="@badge.battle_champion.description",field="battleWins",target=1},
		{id="daily_special",name="@badge.daily_special",description="@badge.daily_special.description",field="dailyClears",target=1},
	}
	local earned={}
	for _,badge in ipairs(checks) do
		if number(profile[badge.field])>=badge.target then
			table.insert(earned,{id=badge.id,name=badge.name,description=badge.description})
		end
	end
	return earned
end

return Rules

end)()
local TestChallenges = (function()
-- Challenge codes carry identity only. Conditions and scores come from server storage.
local Challenges = {}
Challenges.Version = 1
Challenges.OutcomeMessage = {won='@challenge.won', tied='@challenge.tied', lost='@challenge.lost'}
-- Bump when scoring, turn windows, or oven simulation change incompatibly.
Challenges.RulesVersion = 'oven-turn-speed-v1'
Challenges.Lifetime = 7 * 86400

local function finite(n) return type(n)=='number' and n==n and math.abs(n)<math.huge end
local function range(n,low,high) return finite(n) and n>=low and n<=high end
function Challenges.Code(value)
 if type(value)~='string' or #value>32 then return nil end
 local code=value:upper():gsub('[%s%-]','')
 return #code==12 and code:match('^[0-9A-F]+$') and code or nil
end
function Challenges.LaunchCode(value)
 if type(value)~='string' or #value>32 or value:sub(1,4)~='pc1:' then return nil end
 return Challenges.Code(value:sub(5))
end
function Challenges.LaunchData(code)
 local clean=Challenges.Code(code)
 return clean and ('pc1:'..clean) or nil
end
function Challenges.Score(value) return math.floor(math.clamp(value,0,100)*10+.5)/10 end
function Challenges.Outcome(value,target)
 local score=Challenges.Score(value)
 return score>target and 'won' or (score==target and 'tied' or 'lost'),score
end
function Challenges.RecipeSignature(recipe)
 local parts={recipe.id,tostring(recipe.temperature),tostring(recipe.bakeTime)}
 local ids={};for id in pairs(recipe.ingredients) do table.insert(ids,id) end;table.sort(ids)
 for _,id in ipairs(ids) do table.insert(parts,id..'='..recipe.ingredients[id]) end
 return table.concat(parts,'|')
end
function Challenges.Validate(raw,Recipes,epoch)
 if type(raw)~='table' then return nil,'@challenge.not_found' end
 if raw.version~=Challenges.Version or raw.rulesVersion~=Challenges.RulesVersion then return nil,'@challenge.outdated' end
 local recipe=Recipes.ById[raw.recipeId]
 if not recipe or raw.recipeSignature~=Challenges.RecipeSignature(recipe) then return nil,'@challenge.outdated' end
 if not Challenges.Code(raw.id) or raw.id~=Challenges.Code(raw.id)
  or not range(raw.createdAt,1,epoch+60) or not range(raw.expiresAt,raw.createdAt+1,raw.createdAt+Challenges.Lifetime)
  or not finite(raw.creatorId) or raw.creatorId%1~=0 or raw.creatorId==0 or math.abs(raw.creatorId)>9007199254740991
  or type(raw.creatorName)~='string' or #raw.creatorName<1 or #raw.creatorName>100 or not utf8.len(raw.creatorName)
  or not range(raw.score,0,100) or not range(raw.quality,0,100) or not range(raw.bakeScore,0,100)
  or not range(raw.recipeScore,50,100) or not range(raw.elapsed,0,86400)
  or not range(raw.stars,0,3) or raw.stars%1~=0
  or not range(raw.duration,0,600) or not range(raw.heatMultiplier,.5,3) or not range(raw.temperatureBand,5,60)
  or type(raw.ingredients)~='table' then return nil,'@challenge.not_found' end
 if raw.expiresAt<=epoch then return nil,'@challenge.expired' end
 local ingredients={};local portions=0
 for id,n in pairs(raw.ingredients) do
  if not Recipes.IngredientById[id] or not range(n,1,3) or n%1~=0 then return nil,'@challenge.not_found' end
  ingredients[id]=n;portions+=n
 end
 if portions<1 or portions>20 then return nil,'@challenge.not_found' end
 return {version=raw.version,rulesVersion=raw.rulesVersion,id=raw.id,recipeId=raw.recipeId,recipeSignature=raw.recipeSignature,
  createdAt=raw.createdAt,expiresAt=raw.expiresAt,creatorId=raw.creatorId,creatorName=raw.creatorName,
  score=Challenges.Score(raw.score),quality=raw.quality,recipeScore=raw.recipeScore,bakeScore=raw.bakeScore,
  elapsed=raw.elapsed,stars=raw.stars,ingredients=ingredients,turned=raw.turned==true,
  duration=raw.duration,heatMultiplier=raw.heatMultiplier,temperatureBand=raw.temperatureBand}
end
return Challenges

end)()
local TestTutorial = (function()
-- Shared presentation rules; completion and ingredient gates are enforced by the server.
local Tutorial = {}
Tutorial.RecipeId = 'margherita'
Tutorial.Ingredients = {'tomato', 'mozzarella', 'basil', 'olive_oil'}

function Tutorial.NeedsIntroduction(profile)
	return (profile.completed or 0) == 0 and not profile.tutorialCompleted and not profile.tutorialDismissed
end

function Tutorial.NextIngredient(selected, required)
	for index, id in ipairs(Tutorial.Ingredients) do
		if (selected[id] or 0) < required[id] then return id, index end
	end
	return nil, #Tutorial.Ingredients + 1
end

return Tutorial

end)()
local TestCooking = (function()
-- Pure rules shared by server, HUD and isolated gameplay tests.
local Cooking = {}
Cooking.TurnCenter = .5
Cooking.TurnWindow = .14
Cooking.PerfectWindow = .055
Cooking.MaxTurnBonus = 6

function Cooking.Turn(elapsed, duration, alreadyTurned)
 if alreadyTurned or type(elapsed)~='number' or type(duration)~='number'
  or elapsed~=elapsed or duration~=duration or duration<=0 or duration==math.huge then return nil end
 local distance=math.abs(elapsed/duration-Cooking.TurnCenter)
 if distance>Cooking.TurnWindow then return nil end
 local perfect=distance<=Cooking.PerfectWindow
 return {perfect=perfect,bonus=perfect and Cooking.MaxTurnBonus or 3,label=perfect and "@turn.perfect" or "@turn.good"}
end

function Cooking.Checklist(required, selected)
 local needed,placed,complete,total,extra=0,0,0,0,0
 for id,n in pairs(required) do
  needed+=n;placed+=math.min(n,selected[id] or 0);total+=1
  if (selected[id] or 0)==n then complete+=1 end
 end
 for id,n in pairs(selected) do extra+=math.max(0,n-(required[id] or 0)) end
 return {needed=needed,placed=placed,complete=complete,total=total,extra=extra,ready=placed==needed and extra==0}
end
return Cooking

end)()

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
local TestChallengeStore = (function()
-- Immutable seven-day challenges. Studio stays in memory; published servers use DataStore.
local Challenges = TestChallenges
local Recipes = TestRecipes
local Store = {}
function Store.New(deps)
 deps=deps or {}
 local epoch=deps.now or os.time
 local localOnly=deps.localOnly
 if localOnly==nil then localOnly=game:GetService('RunService'):IsStudio() or game.GameId==0 end
 local newId=deps.newId or function()return game:GetService('HttpService'):GenerateGUID(false):gsub('%-',''):sub(1,12):upper()end
 local getStore=deps.getStore or function()return game:GetService('DataStoreService'):GetDataStore('PizzaChiefChallenges_v1')end
 local records,order={},{}
 local dataStore
 local api={localOnly=localOnly}
 local function cache(record)
  if not records[record.id] then table.insert(order,record.id) end
  records[record.id]=record
  while #order>128 do records[table.remove(order,1)]=nil end
 end
 function api:Create(source)
  for _=1,3 do
   local raw=table.clone(source)
   raw.id=newId();raw.createdAt=epoch();raw.expiresAt=raw.createdAt+Challenges.Lifetime
   raw.version=Challenges.Version;raw.rulesVersion=Challenges.RulesVersion
   local clean,err=Challenges.Validate(raw,Recipes,epoch())
   if not clean then return nil,err end
   local stored
   if localOnly then
    if not records[clean.id] then stored=clean end
   else
    local wrote=false
    local ok,value=pcall(function()
     dataStore=dataStore or getStore()
     return dataStore:UpdateAsync('challenge_'..clean.id,function(old)
      wrote=false
      if old~=nil then return nil end
      wrote=true;return clean
     end)
    end)
    if not ok then return nil,'@challenge.unavailable' end
    if wrote and type(value)=='table' and value.id==clean.id then stored=value end
   end
   if stored then cache(clean);return Challenges.Validate(clean,Recipes,epoch()) end
  end
  return nil,'@challenge.unavailable'
 end
 function api:Load(code)
  local id=Challenges.Code(code)
  if not id then return nil,'@challenge.invalid_code' end
  local raw=records[id]
  if not raw and not localOnly then
   local ok,value=pcall(function()dataStore=dataStore or getStore();return dataStore:GetAsync('challenge_'..id)end)
   if not ok then return nil,'@challenge.unavailable' end
   raw=value
  end
  local clean,err=Challenges.Validate(raw,Recipes,epoch())
  if not clean then records[id]=nil;return nil,err end
  if clean.id~=id then return nil,'@challenge.not_found' end
  cache(clean)
  return Challenges.Validate(clean,Recipes,epoch())
 end
 return api
end
return Store

end)()

local rawChallengeNew = TestChallengeStore.New
local challengeGuid = 0
TestChallengeStore.New = function()
 return rawChallengeNew({localOnly=true, now=function()return TestEpoch end,
  newId=function()challengeGuid+=1;return string.format('%012X',challengeGuid)end})
end

local TestProfileStore = (function()
    local guid = 0
    local game = {GameId=0,GetService=function(_,name)
        if name=='RunService' then return TestRunService end
        if name=='HttpService' then return {GenerateGUID=function() guid+=1;return 'test-'..guid end} end
        error('Unexpected service access: '..name)
    end}
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
	return { version = 2, tutorialCompleted = false, tutorialDismissed = false, xp = 0, completed = 0, perfects = 0, battleWins = 0, bestCombo = 0,
		shiftFinishes = 0, dailyClears = 0, bestShift = 0, lastDailyDay = 0, recipeBest = {}, dailyBest = { day = 0, score = 0 }, totalStars = 0 }
end
local function sanitize(raw)
	local result = Store.NewProfile()
	if type(raw) ~= "table" then return result end
	result.tutorialCompleted = raw.tutorialCompleted == true
	result.tutorialDismissed = raw.tutorialDismissed == true
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

end)()
-- Pizza Chief: the server owns ingredients, cooking, clocks and competition scores.
local Players = TestPlayers
local ReplicatedStorage = nil
local RunService = TestRunService

local shared = TestShared
local Recipes = TestRecipes
local Rules = TestRules
local Cooking = TestCooking
local Tutorial = TestTutorial
local Challenges = TestChallenges
local ChallengeStore = TestChallengeStore
local challengeStore = ChallengeStore.New()
local ProfileStore = TestProfileStore

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

local function now() return TestClock end
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
		turned = false, turnBonus = 0, perfectTurn = false,
		result = nil, completedRoom = nil, message = "", roomMember = false, queued = false,
		tokens = 25, tokenAt = now(),
		challengeBusy = false, challengeStatus = "", nextChallengeRead = 0, nextChallengeWrite = 0,
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
		turned = s.turned, turnBonus = s.turnBonus, perfectTurn = s.perfectTurn,
		queued = s.queued, serverNow = now(),
		pendingChallenge = s.pendingChallenge, activeChallenge = s.activeChallenge,
		challengeRevision = s.challengeRevision or 0, shareChallenge = s.shareChallenge, challengeStatus = s.challengeStatus, challengeLocalOnly = challengeStore.localOnly,
		profile = profileSnapshot(s), shift = s.shift, contract = s.contract, combo = s.combo,
		dailyChallenge = Rules.Daily(math.floor(TestEpoch / 86400), Recipes),
		daily = Rules.Daily(math.floor(TestEpoch / 86400), Recipes),
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
	s.activeChallenge, s.shareChallenge, s.challengeStatus = nil, nil, ""
	s.ingredients, s.result, s.completedRoom, s.message = {}, nil, nil, ""
	s.startedAt, s.deadline = startedAt, deadline or 0
	s.temperature, s.heat = 20, 0.5
	s.bakeElapsed, s.bakeDuration, s.bakeIntegral, s.bakeQuality = 0, 0, 0, 0
	s.turned, s.turnBonus, s.perfectTurn = false, 0, false
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
	result.ingredients, result.recipeId = copyIngredients(s.ingredients), s.recipeId
	result.conditions = { duration = s.deadline > 0 and (s.deadline - s.startedAt) or 0,
		heatMultiplier = s.contract and s.contract.heatMultiplier or 1,
		temperatureBand = s.contract and s.contract.temperatureBand or 25 }
	if s.activeChallenge then
		local outcome,score = Challenges.Outcome(result.total, s.activeChallenge.score)
		result.challenge = { id = s.activeChallenge.id, creatorId = s.activeChallenge.creatorId,
			creatorName = s.activeChallenge.creatorName, target = s.activeChallenge.score, score = score, outcome = outcome }
	end
	local p = s.profile.data
	if s.mode == "tutorial" then
		-- Guided practice never overwrites career records or grants farmable rewards.
		p.tutorialCompleted = true
		-- Reading guidance has no speed penalty in the untimed lesson.
		result.speed, result.total = 100, result.quality
		result.previousBest, result.delta, result.personalBest = 0, 0, false
		result.reward = { xp = 0, stars = Rules.RecipeStars(result.recipeScore, result.bakeScore, result.total), headline = "@tutorial.done", combo = s.combo }
		s.result, s.phase, s.message = result, "result", ""
		return
	end
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
	local reward = Rules.Reward(result, s.mode == "challenge" and "practice" or s.mode, combo, result.personalBest)
	result.reward = reward
	s.combo = reward.nextCombo or 0
	p.bestCombo = math.max(p.bestCombo, s.combo)
	if reward.xp > 0 then
		p.completed += 1
		if reward.stars == 3 then p.perfects += 1 end
		local newStars = math.max(best.stars, reward.stars)
		p.totalStars += newStars - best.stars
		p.recipeBest[s.recipeId] = { score = math.max(best.score, result.total), stars = newStars }
		if s.contract and s.mode ~= "daily" and s.mode ~= "challenge" and result.total >= (s.contract.goal or 80) then
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
		local result = Recipes.Score(s.recipeId, s.ingredients, math.min(100, s.bakeQuality + s.turnBonus), elapsed)
		result.turnBonus, result.perfectTurn = s.turnBonus, s.perfectTurn
		rememberResult(player, s, result, elapsed)
	elseif timedOut then
		rememberResult(player, s, zeroResult(s, "@server.timeout"), elapsed)
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
			s.phase, s.mode, s.message = "menu", "competition", "@server.waiting"
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
			entry.result = s and zeroResult(s, "@server.forfeit") or nil
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
		if count(room.queue) >= Settings.MaxPlayers then s.message = "@server.queue_full" return end
		room.queue[player.UserId] = player
		s.shift, s.contract = nil, nil
		s.queued, s.phase, s.mode, s.message = true, "menu", "competition", "@server.queued"
		return
	end
	if count(room.members) >= Settings.MaxPlayers then s.message = "@server.room_full" return end
	room.members[player.UserId] = { player = player, name = player.DisplayName, done = false }
	s.shift, s.contract = nil, nil
	s.roomMember, s.queued = true, false
	s.phase, s.mode, s.result, s.message = "menu", "competition", nil, "@server.waiting"
end

local function startShiftOrder(s)
	local contract = Rules.Contract(s.shift.seed, s.shift.stage, s.shift.unlockedRecipes, Recipes)
	beginPizza(s, "shift", contract.recipeId, now(), now() + contract.duration, contract)
end
local function isCompeting(s) return s.roomMember and room.phase == "active" end
local function loadChallenge(player, code)
	local s = sessions[player]
	if not s or shuttingDown then return end
	if s.challengeBusy then s.challengeStatus = "@challenge.wait" return end
	if now() < s.nextChallengeRead then s.challengeStatus = "@challenge.wait" return end
	local id = Challenges.Code(code)
	if not id then s.challengeStatus = "@challenge.invalid_code" return end
	s.nextChallengeRead, s.challengeBusy, s.challengeStatus = now() + 2, true, "@challenge.loading"
	local ok, record, err = pcall(function() return challengeStore:Load(id) end)
	if sessions[player] ~= s then return end
	s.challengeBusy = false
	if shuttingDown then return end
	if ok and record then s.pendingChallenge, s.challengeStatus = record, "@challenge.ready"
	else s.challengeStatus = ok and err or "@challenge.unavailable" end
end

local function createChallenge(player)
	local s = sessions[player]
	if not s or s.challengeBusy or s.phase ~= "result" or s.mode == "tutorial" then return end
	local result = s.result
	if not result or result.total < 50 or result.recipeScore < 50 or result.elapsed > 86400 then s.challengeStatus = "@challenge.ineligible" return end
	if s.shareChallenge and s.shareChallenge.expiresAt > TestEpoch then return end
	if now() < s.nextChallengeWrite then s.challengeStatus = "@challenge.wait" return end
	s.nextChallengeWrite, s.challengeBusy, s.challengeStatus = now() + 10, true, "@challenge.saving"
	local conditions = result.conditions
	local source = { recipeId = result.recipeId, recipeSignature = Challenges.RecipeSignature(Recipes.ById[result.recipeId]),
		creatorId = player.UserId, creatorName = player.DisplayName, score = result.total, quality = result.quality,
		recipeScore = result.recipeScore, bakeScore = result.bakeScore, stars = result.reward.stars,
		elapsed = result.elapsed, ingredients = copyIngredients(result.ingredients), turned = s.turned,
		duration = conditions.duration, heatMultiplier = conditions.heatMultiplier, temperatureBand = conditions.temperatureBand }
	local ok, record, err = pcall(function() return challengeStore:Create(source) end)
	if sessions[player] ~= s then return end
	s.challengeBusy = false
	-- An asynchronous save cannot attach an old score to a newer pizza.
	if shuttingDown or s.result ~= result then return end
	if ok and record then s.shareChallenge, s.challengeStatus = record, "@challenge.saved"
	else s.challengeStatus = ok and err or "@challenge.unavailable" end
end

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
		s.message = "@server.loading"
		if action == "CreateChallenge" or action == "LookupChallenge" then
			s.challengeRevision = (s.challengeRevision or 0) + 1
			s.challengeStatus = "@server.loading"
		end
		return
	end
	if action == "CreateChallenge" then
		s.challengeRevision = (s.challengeRevision or 0) + 1
		createChallenge(player)
	elseif action == "LookupChallenge" then
		s.challengeRevision = (s.challengeRevision or 0) + 1
		loadChallenge(player, argument)
	elseif action == "AcceptChallenge" then
		if isCompeting(s) then s.message = "@server.in_round" return end
		local candidate = s.pendingChallenge
		if not candidate or argument ~= candidate.id then s.message = "@challenge.not_found" return end
		local record, err = Challenges.Validate(candidate, Recipes, TestEpoch)
		if not record then s.pendingChallenge, s.message = nil, err return end
		leaveRoom(player, false)
		local contract = { id = "friend_challenge", name = "@challenge.title", description = "@challenge.same_rules",
			duration = record.duration, heatMultiplier = record.heatMultiplier, temperatureBand = record.temperatureBand,
			goal = record.score, bonusXP = 0 }
		beginPizza(s, "challenge", record.recipeId, time, record.duration > 0 and time + record.duration or 0, contract)
		s.activeChallenge = record
	elseif action == "RetryChallenge" then
		if s.mode ~= "challenge" or s.phase ~= "result" or not s.activeChallenge then return end
		local record = s.activeChallenge
		local contract = s.contract
		-- A started challenge can be retried only while its invitation is still valid.
		if record.expiresAt <= TestEpoch then s.message = "@challenge.expired" return end
		beginPizza(s, "challenge", record.recipeId, time, record.duration > 0 and time + record.duration or 0, contract)
		s.activeChallenge = record
	elseif action == "LeaveRoom" then
		leaveRoom(player, false)
	elseif action == "JoinRoom" then
		joinRoom(player)
	elseif action == "Menu" or action == "StartPractice" or action == "StartShift" or action == "StartDaily" or action == "StartTutorial" or action == "SkipTutorial" then
		if isCompeting(s) then s.message = "@server.in_round" return end
		if action == "StartPractice" and argument ~= nil and not validRecipe(argument) then return end
		if action == "SkipTutorial" then
			s.profile.data.tutorialDismissed = true
			action = "StartShift"
		elseif action == "StartShift" and Tutorial.NeedsIntroduction(s.profile.data) then
			action = "StartTutorial"
		end
		leaveRoom(player, false)
		if action == "StartTutorial" then
			beginPizza(s, "tutorial", Tutorial.RecipeId, time, 0)
		elseif action == "StartPractice" then
			beginPizza(s, "practice", argument or s.recipeId, time, 0)
		elseif action == "StartShift" then
			s.shiftSerial += 1
			s.shift = { stage = 1, total = 3, score = 0, combo = s.combo, finished = false, completed = 0,
				unlockedRecipes = Rules.Rank(s.profile.data.xp).unlockedRecipes,
				seed = player.UserId + s.shiftSerial * 7919 + math.floor(time) }
			startShiftOrder(s)
		elseif action == "StartDaily" then
			local contract = Rules.Daily(math.floor(TestEpoch / 86400), Recipes)
			contract.dayKey = math.floor(TestEpoch / 86400)
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
		if s.mode == "tutorial" and argument ~= Tutorial.NextIngredient(s.ingredients, Recipes.ById[s.recipeId].ingredients) then return end
		local total = 0
		for _, amount in pairs(s.ingredients) do total += amount end
		if total >= Settings.MaxIngredients then s.message = "@server.toppings_full" return end
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
		if s.mode == "tutorial" and not Cooking.Checklist(Recipes.ById[s.recipeId].ingredients, s.ingredients).ready then
			s.message = "@tutorial.finish_recipe"
			return
		end
		if next(s.ingredients) == nil then s.message = "@server.empty" return end
		local recipe = Recipes.ById[s.recipeId]
		s.phase, s.bakeElapsed, s.bakeIntegral, s.bakeQuality = "bake", 0, 0, 0
		s.bakeDuration = recipe.bakeTime
		s.temperature = recipe.temperature - 50
		s.heat = math.clamp((recipe.temperature - Settings.MinTemperature) / (Settings.MaxTemperature - Settings.MinTemperature), 0, 1)
	elseif action == "Heat" then
		if s.phase == "bake" and finite(argument) then s.heat = math.clamp(argument, 0, 1) end
	elseif action == "Turn" then
		if s.phase ~= "bake" then return end
		local turn = Cooking.Turn(s.bakeElapsed, s.bakeDuration, s.turned)
		if turn then
			s.turned, s.turnBonus, s.perfectTurn = true, turn.bonus, turn.perfect
			s.message = turn.label
		elseif not s.turned then
			s.message = s.bakeElapsed < s.bakeDuration * Cooking.TurnCenter and "@server.turn_early" or "@server.turn_late"
		end
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
local function readChallengeInvite(player)
	local s = sessions[player]
	for attempt = 1, 6 do
		if sessions[player] ~= s or shuttingDown then return end
		local ok, joined = pcall(function() return player:GetJoinData() end)
		local code = ok and type(joined) == "table" and Challenges.LaunchCode(joined.LaunchData)
		if code then
			loadChallenge(player, code)
			if sessions[player] == s then State:FireClient(player, snapshot(player)) end
			return
		end
		if not ok then return end
		task.wait(1)
	end
end
local function joinedPlayer(player)
	playerAdded(player)
	task.spawn(readChallengeInvite, player)
end
Players.PlayerAdded:Connect(joinedPlayer)
Players.PlayerRemoving:Connect(function(player)
	leaveRoom(player, true)
	local s = sessions[player]
	sessions[player] = nil
	if s then retireProfile(s.profile) end
	publishAll()
end)
for _, player in ipairs(Players:GetPlayers()) do joinedPlayer(player) end

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
				s.phase, s.message = "ready", "@server.ready"
			end
		end
		if (s.mode == "shift" or s.mode == "daily" or s.mode == "challenge") and s.deadline > 0 and time >= s.deadline and s.phase ~= "result" then
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

TestBindToClose(function()
	shuttingDown = true
	for _, s in pairs(sessions) do retireProfile(s.profile) end
	local deadline = os.clock() + 25
	while next(retiringProfiles) and os.clock() < deadline do task.wait(0.1) end
end)

print("Pizza Chief server ready: " .. #Recipes.List .. " recipes, server-authoritative cooking and six-chef rooms.")


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
    sessions[p].profile.data.tutorialDismissed = true
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

local novice=fakePlayer(9001)
local p=sessions[novice].profile.data
p.tutorialDismissed=false
handleAction(novice,'StartShift')
check(sessions[novice].mode=='tutorial' and sessions[novice].recipeId=='margherita' and sessions[novice].deadline==0,'First shift offers an untimed Margherita lesson')
handleAction(novice,'Add','mozzarella');handleAction(novice,'Bake');handleAction(novice,'Serve')
check(next(sessions[novice].ingredients)==nil and not p.tutorialCompleted and sessions[novice].phase=='prep','Out-of-order ingredients and premature completion are rejected')
handleAction(novice,'Add','tomato');handleAction(novice,'Bake')
check(sessions[novice].phase=='prep','Partial tutorial recipe cannot enter the oven')
handleAction(novice,'Menu');handleAction(novice,'StartShift')
check(sessions[novice].mode=='tutorial' and not p.tutorialCompleted,'Leaving an unfinished lesson never marks completion')
for _,id in ipairs(TestTutorial.Ingredients) do
 local n=Recipes.ById.margherita.ingredients[id]
 for _=1,n do handleAction(novice,'Add',id) end
 handleAction(novice,'Add',id)
 check(sessions[novice].ingredients[id]==n,'Tutorial caps recipe portions: '..id)
end
handleAction(novice,'Remove','tomato')
check(TestTutorial.NextIngredient(sessions[novice].ingredients,Recipes.ById.margherita.ingredients)=='tomato','Removing an earlier ingredient restores its teaching step')
handleAction(novice,'Add','tomato')
advance(400)
check(sessions[novice].phase=='prep','Reading the lesson has no timeout')
handleAction(novice,'Bake');advance(9,novice);handleAction(novice,'Turn');advance(10,novice);handleAction(novice,'Serve')
check(p.tutorialCompleted and sessions[novice].phase=='result' and sessions[novice].result.turnBonus==6,'Server marks lesson complete only after a real bake and serve')
check(p.xp==0 and p.completed==0 and p.totalStars==0 and next(p.recipeBest)==nil and p.bestCombo==0,'Guided lesson cannot alter career XP, records, stars or combo')
handleAction(novice,'Serve');handleAction(novice,'StartShift')
check(sessions[novice].mode=='shift','Completed lesson continues to a normal shift')
handleAction(novice,'StartTutorial')
check(sessions[novice].mode=='tutorial','Completed lesson can be replayed')
handleAction(novice,'SkipTutorial')
check(p.tutorialDismissed and sessions[novice].mode=='shift','Skip immediately starts a normal shift')
local skip=fakePlayer(9002);sessions[skip].profile.data.tutorialDismissed=false
handleAction(skip,'SkipTutorial');handleAction(skip,'Menu');handleAction(skip,'StartShift')
check(not sessions[skip].profile.data.tutorialCompleted and sessions[skip].mode=='shift','Skipping is distinct from completing and suppresses repeat onboarding')
local veteran=fakePlayer(9003);sessions[veteran].profile.data.tutorialDismissed=false;sessions[veteran].profile.data.completed=1
handleAction(veteran,'StartShift')
check(sessions[veteran].mode=='shift','Existing players are not forced into onboarding')
local loading=fakePlayer(9004);sessions[loading].profile.status='loading';sessions[loading].profile.data.tutorialDismissed=false
handleAction(loading,'StartTutorial');handleAction(loading,'SkipTutorial')
check(sessions[loading].phase=='menu' and not sessions[loading].profile.data.tutorialDismissed,'Loading profile gates lesson and skip writes')
return {passed=#reports,checks=reports,liveDataStoreAccess=false}



