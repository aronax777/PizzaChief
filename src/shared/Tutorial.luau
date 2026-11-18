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
