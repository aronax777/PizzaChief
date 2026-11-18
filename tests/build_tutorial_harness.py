"""Run actual server onboarding against isolated players, clocks and profiles."""
from pathlib import Path
import runpy
root=Path(__file__).resolve().parents[1]
runpy.run_path(str(root/'tests/build_room_harness.py'))
s=(root/'tests/generated-room-validation.luau').read_text()
marker='return { passed = #reports, checks = reports, idleBakeQuality = idleQuality, controlledBakeQuality = controlledQuality }'
tests=r'''
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
'''
assert marker in s
(root/'tests/generated-tutorial-validation.luau').write_text(s.replace(marker,tests))
