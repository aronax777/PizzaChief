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
