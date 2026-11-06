-- Pizza Chief: deliberately simplified game recipes, not food-safety guidance.
-- Colors use RGB bytes; portions are game units. Dough is supplied automatically.
local Recipes = {}

Recipes.Ingredients = {
	{id="tomato", name="Томатний соус", color={197,54,40}, category="Sauce"},
	{id="mozzarella", name="Моцарела", color={255,241,195}, category="Cheese"},
	{id="basil", name="Базилік", color={67,151,77}, category="Herbs"},
	{id="garlic", name="Часник", color={249,232,195}, category="Herbs"},
	{id="oregano", name="Орегано", color={111,133,62}, category="Herbs"},
	{id="olive_oil", name="Оливкова олія", color={218,182,54}, category="Herbs"},
	{id="parmesan", name="Пармезан", color={239,208,126}, category="Cheese"},
	{id="gorgonzola", name="Горгонзола", color={185,210,178}, category="Cheese"},
	{id="ricotta", name="Рикота", color={252,247,230}, category="Cheese"},
	{id="pepperoni", name="Пепероні", color={164,44,36}, category="Protein"},
	{id="ham", name="Шинка", color={227,135,130}, category="Protein"},
	{id="mushroom", name="Гриби", color={181,153,120}, category="Vegetables"},
	{id="olive", name="Маслини", color={57,53,46}, category="Vegetables"},
	{id="artichoke", name="Артишок", color={151,168,83}, category="Vegetables"},
	{id="anchovy", name="Анчоуси", color={143,119,106}, category="Protein"},
	{id="caper", name="Каперси", color={109,133,62}, category="Vegetables"},
	{id="tuna", name="Тунець", color={202,159,142}, category="Protein"},
	{id="onion", name="Червона цибуля", color={172,102,159}, category="Vegetables"},
	{id="pepper", name="Солодкий перець", color={240,176,43}, category="Vegetables"},
	{id="pineapple", name="Ананас", color={250,211,78}, category="Vegetables"},
	{id="chicken", name="Курятина", color={221,176,122}, category="Protein"},
	{id="bbq", name="Соус барбекю", color={111,51,31}, category="Sauce"},
	{id="bacon", name="Бекон", color={177,82,63}, category="Protein"},
	{id="egg", name="Яйце", color={255,198,54}, category="Protein"},
	{id="black_pepper", name="Чорний перець", color={74,62,51}, category="Herbs"},
	{id="pesto", name="Песто", color={82,123,51}, category="Sauce"},
	{id="rocket", name="Рукола", color={69,135,58}, category="Herbs"},
	{id="sausage", name="Ковбаски", color={137,77,52}, category="Protein"},
}

Recipes.List = {
	{id="margherita",name="Margherita",description="Томати, ніжна моцарела та свіжий базилік.",ingredients={tomato=2,mozzarella=2,basil=1,olive_oil=1},temperature=430,bakeTime=18},
	{id="marinara",name="Marinara",description="Класика: томати, часник, орегано й оливкова олія.",ingredients={tomato=2,garlic=1,oregano=1,olive_oil=1},temperature=440,bakeTime=18},
	{id="pepperoni",name="Pepperoni",description="Щедрий шар пікантної пепероні.",ingredients={tomato=2,mozzarella=2,pepperoni=2},temperature=410,bakeTime=20},
	{id="diavola",name="Diavola",description="Наша версія з пепероні, маслинами та чорним перцем.",ingredients={tomato=2,mozzarella=2,pepperoni=2,olive=1,black_pepper=1},temperature=420,bakeTime=20},
	{id="funghi",name="Funghi",description="Ароматні гриби на томатній основі з моцарелою.",ingredients={tomato=2,mozzarella=2,mushroom=2,oregano=1},temperature=410,bakeTime=20},
	{id="prosciutto",name="Prosciutto",description="Ніжна шинка, томати та розплавлена моцарела.",ingredients={tomato=2,mozzarella=2,ham=2},temperature=400,bakeTime=20},
	{id="capricciosa",name="Capricciosa",description="Шинка, гриби, артишоки та маслини.",ingredients={tomato=2,mozzarella=2,ham=1,mushroom=1,artichoke=1,olive=1},temperature=400,bakeTime=23},
	{id="quattro_formaggi",name="Quattro Formaggi",description="Наша суміш моцарели, рикоти, пармезану й горгонзоли.",ingredients={mozzarella=2,ricotta=1,parmesan=1,gorgonzola=1},temperature=390,bakeTime=21},
	{id="carbonara",name="Carbonara",description="Наша біла піца: бекон, яйце, пармезан і чорний перець.",ingredients={mozzarella=2,bacon=2,egg=1,parmesan=1,black_pepper=1},temperature=380,bakeTime=22},
	{id="hawaiian",name="Hawaiian",description="Солодкий ананас і соковита шинка.",ingredients={tomato=2,mozzarella=2,ham=2,pineapple=2},temperature=390,bakeTime=22},
	{id="bbq_chicken",name="BBQ Chicken",description="Димний соус барбекю, курятина та червона цибуля.",ingredients={bbq=2,mozzarella=2,chicken=2,onion=1},temperature=390,bakeTime=22},
	{id="vegetarian",name="Vegetarian",description="Гриби, солодкий перець, цибуля та маслини.",ingredients={tomato=2,mozzarella=2,mushroom=1,pepper=1,onion=1,olive=1},temperature=400,bakeTime=23},
	{id="tonno_cipolla",name="Tonno e Cipolla",description="Класичне поєднання тунця та червоної цибулі.",ingredients={tomato=2,mozzarella=2,tuna=2,onion=1},temperature=400,bakeTime=21},
	{id="napoli",name="Napoli",description="Анчоуси, каперси й орегано на томатній основі.",ingredients={tomato=2,mozzarella=2,anchovy=1,caper=1,oregano=1},temperature=430,bakeTime=19},
	{id="pesto_chicken",name="Pesto Chicken",description="Зелений песто, курятина та пармезан.",ingredients={pesto=2,mozzarella=2,chicken=2,parmesan=1},temperature=390,bakeTime=22},
	{id="meat_feast",name="Meat Feast",description="Ситна піца з пепероні, ковбасками й беконом.",ingredients={tomato=2,mozzarella=2,pepperoni=1,sausage=1,bacon=1},temperature=390,bakeTime=24},
	{id="prosciutto_funghi",name="Prosciutto e Funghi",description="Улюблене поєднання шинки та грибів.",ingredients={tomato=2,mozzarella=2,ham=2,mushroom=2},temperature=400,bakeTime=22},
	{id="boscaiola",name="Boscaiola",description="Біла піца з ковбасками й ароматними грибами.",ingredients={mozzarella=2,sausage=2,mushroom=2,olive_oil=1},temperature=390,bakeTime=23},
	{id="rucola",name="Rucola",description="Рукола, шинка та пармезан на томатній основі.",ingredients={tomato=2,mozzarella=2,ham=1,rocket=1,parmesan=1},temperature=410,bakeTime=20},
	{id="bianca",name="Bianca",description="Наша біла сирна піца з часником і оливковою олією.",ingredients={mozzarella=2,ricotta=2,garlic=1,olive_oil=1},temperature=400,bakeTime=20},
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
	return ingredient and ingredient.name or "Невідомий інгредієнт"
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
		feedback = "Почни з інгредієнтів, указаних у рецепті."
	elseif #match.missing > 0 then
		feedback = "Додай за рецептом: " .. match.missing[1] .. "."
	elseif #match.extra > 0 then
		feedback = "Зменш кількість інгредієнта: " .. match.extra[1] .. "."
	elseif bake < 55 then
		feedback = "Гарні інгредієнти. Тримай бігунок печі в зеленій зоні."
	elseif bake < 85 then
		feedback = "Чудовий рецепт! Рівномірний жар зробить скоринку ще кращою."
	elseif speed < 60 then
		feedback = "Смачна піца. Швидша подача додасть тобі балів."
	else
		feedback = "Bellissimo! Збалансована начинка, золотиста скоринка й чудова подача."
	end
	return {
		recipeName=match.name, recipeScore=match.score, bakeScore=bake,
		quality=quality, speed=speed, total=total, feedback=feedback,
	}
end

return Recipes
