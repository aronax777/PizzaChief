"""Generate pure replay-rule validation using the exact current module sources.
Run the emitted chunk in Studio Edit or Server. No live services are changed.
"""
from pathlib import Path

root = Path(__file__).resolve().parents[1]
recipes = (root / 'src/shared/Recipes.luau').read_text()
rules = (root / 'src/shared/GameRules.luau').read_text()
checks = r'''
local checks = {}
local function check(ok, detail)
    assert(ok, detail)
    table.insert(checks, detail)
end
check(Rules.Version == 2, "Replay rules have an explicit schema version")
local first, nextRank = Rules.Rank(0), Rules.Rank(100)
check(first.level == 1 and first.unlockedRecipes == 6, "New chefs begin with a manageable six-recipe career pool")
check(Rules.Rank(99).level == 1 and nextRank.level == 2, "Rank changes at the exact XP boundary")
check(Rules.Rank(100000).unlockedRecipes == #Recipes.List and Rules.Rank(100000).nextXP == nil and Rules.Rank(100000).progress == 1, "Veteran rank unlocks the entire career catalog")
local stages = {}
for stage = 1, 3 do
    local a = Rules.Contract(1234, stage, 6, Recipes)
    local b = Rules.Contract(1234, stage, 6, Recipes)
    local index
    for n, recipe in ipairs(Recipes.List) do if recipe.id == a.recipeId then index = n end end
    check(index and index <= 6 and a.duration > Recipes.ById[a.recipeId].bakeTime,
        "Shift stage " .. stage .. " stays in unlocked pool and permits a complete bake")
    check(a.id == b.id and a.recipeId == b.recipeId and a.duration == b.duration,
        "Shift stage " .. stage .. " is deterministic for the same seed")
    stages[stage] = a
end
check(stages[2].heatMultiplier > stages[1].heatMultiplier and stages[3].duration < stages[1].duration,
    "Shift stages vary cooking pressure and time pressure")
check(Rules.Rank(0/0).level == 1 and Rules.Rank(math.huge).level == 1 and Rules.Rank(-20).level == 1,
    "Non-finite and negative XP cannot produce invalid ranks")
local unsafe = Rules.Contract(0/0, math.huge, 0/0, Recipes)
check(Recipes.ById[unsafe.recipeId] ~= nil and unsafe.duration > 0, "Non-finite contract inputs fall back to valid gameplay")
local dailyA, dailyB = Rules.Daily(20000, Recipes), Rules.Daily(20000, Recipes)
check(dailyA.recipeId == dailyB.recipeId and dailyA.id == dailyB.id and dailyA.duration == dailyB.duration,
    "Every chef receives the same daily contract")
check(Recipes.ById[Rules.Daily(20001, Recipes).recipeId] ~= nil, "Next day's challenge remains a valid catalog recipe")
check(Rules.RecipeStars(100, 100, 100) == 3, "A perfect pizza earns three stars")
check(Rules.RecipeStars(0, 0, 0) == 0, "An unfinished pizza earns no stars")
check(Rules.RecipeStars(94, 100, 100) < 3 and Rules.RecipeStars(100, 89, 100) < 3,
    "Three stars require both recipe fidelity and baking mastery")
local exploit = Rules.Reward({recipeScore=0,bakeScore=100,total=100,quality=100,speed=100}, 'practice', 5, true)
check(exploit.xp == 0, "Perfect-looking totals cannot reward zero recipe fidelity")
check(Rules.Reward({recipeScore=0/0,bakeScore=100,total=math.huge}, 'shift', math.huge, true).xp == 0,
    "Non-finite result fields cannot grant XP")
local zero = Rules.Reward({recipeScore=0,bakeScore=0,total=0,quality=0,speed=0}, 'shift', 5, true)
check(zero.xp == 0 and zero.nextCombo == 0, "Failure gives no XP and resets only the current combo")
local perfect = {recipeScore=100,bakeScore=100,total=100,quality=100,speed=100}
local reward = Rules.Reward(perfect, 'shift', 5, true)
check(reward.xp > 0 and reward.nextCombo == 5 and reward.stars == 3, "Excellent cooking earns XP without unbounded combo growth")
check(Rules.Reward(perfect, 'practice', 0, false).xp < Rules.Reward(perfect, 'shift', 0, false).xp,
    "Practice remains rewarding while career challenges earn more")
local badges = Rules.Badges({completed=0,totalStars=0,perfects=0,battleWins=0,bestCombo=0,shiftFinishes=0,dailyClears=0})
check(#badges == 0, "New profiles do not claim unearned achievements")
local earned = Rules.Badges({completed=100,totalStars=60,perfects=20,battleWins=20,bestCombo=5,shiftFinishes=20,dailyClears=20})
local unique = {}; for _, badge in ipairs(earned) do assert(not unique[badge.id]); unique[badge.id] = true end
check(#earned >= 4, "Long-term skill goals award distinct achievements")
local exactQuality, meaningfulSpeed, reachableMastery = true, true, true
for _, recipe in ipairs(Recipes.List) do
    local match = Recipes.Match(recipe.ingredients)
    check(match.id == recipe.id and match.score == 100, "Exact catalog profile matches " .. recipe.id)
    local portions=0;for _,amount in pairs(recipe.ingredients) do portions+=amount end
    local par=recipe.bakeTime+6+portions*.5
    local ideal=Recipes.Score(recipe.id,recipe.ingredients,100,0)
    local faster=Recipes.Score(recipe.id,recipe.ingredients,100,par+5)
    local slower=Recipes.Score(recipe.id,recipe.ingredients,100,par+20)
    local human=Recipes.Score(recipe.id,recipe.ingredients,100,35)
    exactQuality=exactQuality and ideal.recipeScore==100 and ideal.bakeScore==100 and ideal.quality==100 and ideal.speed==100
    meaningfulSpeed=meaningfulSpeed and faster.speed>slower.speed and faster.total>slower.total and faster.quality==slower.quality
    reachableMastery=reachableMastery and Rules.RecipeStars(human.recipeScore,human.bakeScore,human.total)==3
end
check(exactQuality,"Every exact recipe preserves perfect fidelity bake and quality at ideal time")
check(meaningfulSpeed,"Every recipe rewards a faster real finish beyond its recipe-specific par")
check(reachableMastery,"Three-star mastery stays reachable at a human-scale 35-second finish")
return {passed=#checks,checks=checks}
'''
output = root / 'tests/generated-progression-validation.luau'
output.write_text('local Recipes = (function()\n' + recipes + '\nend)()\nlocal Rules = (function()\n' + rules + '\nend)()\n' + checks)
print(output)
