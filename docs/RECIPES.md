# Pizza Chief recipe and judging model

The prototype includes **20 recognizable pizza profiles and 28 ingredients**. This is an expandable launch catalog, not a claim to cover every regional pizza. Dough is already on the board; one unit is a game portion, not a gram measurement. Ingredient colors use RGB byte triples.

## Culinary grounding

The [Associazione Verace Pizza Napoletana's regulation](https://www.pizzanapoletana.org/public/pdf/Disciplinare_AVPN_2022_en.pdf) describes Marinara with tomato, garlic, oregano and oil, and Margherita with tomato, mozzarella, basil, oil and grated cheese. Our Margherita intentionally omits grated cheese for an accessible four-ingredient opening recipe; it is not an AVPN-certified simulation.

[Italy's official tourism portal](https://www.italia.it/it/campania/napoli/cosa-fare/pizza) describes familiar combinations including capricciosa, four cheeses, mushroom-and-sausage boscaiola and spicy-salami diavola. Regional and restaurant variations differ. Our four-cheese, diavola, bianca and carbonara pizzas are explicitly house variations; carbonara pizza has no single universal recipe standard. Bacon is the prototype's simplified carbonara meat ingredient. The remaining international combinations are recognizable game profiles, not regulated recipes. Sources checked 6 November 2026.

All oven temperatures and 18–24 second bake durations are **arcade balance settings**, not real cooking instructions or food-safety thresholds. Ingredient names describe toppings, not safe preparation of raw meat or egg. The game assumes toppings have been prepared by the kitchen.

## Catalog

Margherita, Marinara, Pepperoni, Diavola, Funghi, Prosciutto, Capricciosa, Quattro Formaggi, Carbonara, Hawaiian, BBQ Chicken, Vegetarian, Tonno e Cipolla, Napoli, Pesto Chicken, Meat Feast, Prosciutto e Funghi, Boscaiola, Rucola, Bianca.

The exact count maps, target temperatures and bake durations live in `src/shared/Recipes.luau`. Counts range from one to two portions in this catalog; the data contract supports three. Adding a profile to `Recipes.List` automatically adds it to `Recipes.ById` and the best-match search.

## Deterministic judging

For each ingredient i, expected count is E_i, actual count is A_i, and its weight is W_i. Sauce and protein weigh 2, cheese 1.5, vegetables 1.25, herbs/oil 1. Unknown ingredients weigh 2 and only add a penalty.

`recipeScore = 100 × sum(W_i × min(E_i, A_i)) / sum(W_i × max(E_i, A_i))`

This weighted intersection-over-union penalizes missing toppings, unnecessary toppings and excessive portions. An exact recipe scores 100; no overlap scores zero. Extra portions cannot improve an already complete recipe. `Match(selected)` evaluates every recipe and returns the highest score; ties use catalog order for determinism. `Score(recipeId, ...)` evaluates the requested recipe, falling back to the best match for an unknown ID. This supports both assigned orders and free creation.

`bakeScore = clamp(serverMeasuredBakeQuality, 0, 100)`

`par = recipe.bakeTime + 6 + 0.5 × totalIngredientPortions`

`speed = clamp(100 - 0.85 × (elapsedSeconds - par), 0, 100)`

`quality = recipeScore × 0.65 + bakeScore × 0.35`

`total = quality × 0.80 + speed × 0.20`

Service at or below the recipe-specific par earns full speed points; 60 seconds over par earns 49, and 120 seconds over par earns zero. Scores remain fractional internally; presentation may round them. With zero recipe overlap, bake and speed are forced to zero, so an empty pizza cannot earn points. Nonfinite bake/time inputs earn zero for those components; negative elapsed time also earns zero. Counts are floored and bounded to 0–100 for defensive calculation. The authoritative server must separately enforce phase order, inventory, per-topping limits, deadlines, oven simulation and serving permissions; this module never trusts a client-provided result as authoritative.

## Public API

- `Recipes.Ingredients`: array of `{id, name, color={r,g,b}, category}`.
- `Recipes.IngredientById`: ingredient dictionary.
- `Recipes.List`: array of `{id, name, description, ingredients, temperature, bakeTime}`.
- `Recipes.ById`: recipe dictionary.
- `Recipes.Match(counts)`: `{id, name, score, missing, extra}`; missing and extra contain sorted ingredient names.
- `Recipes.Score(recipeId, counts, bakeQuality, elapsed)`: `{recipeName, recipeScore, bakeScore, quality, speed, total, feedback}`.

The empty input returns a zero-score first-catalog match, with missing ingredients listed. UI should show the recipe name only alongside its match percentage, or show “unfinished” for zero.
