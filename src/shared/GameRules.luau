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
