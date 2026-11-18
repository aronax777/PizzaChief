"""Exercise the real server turn mechanic with isolated clock/remotes/profile.
Generate with python3 tests/build_cooking_harness.py; execute the chunk in Studio.
"""
from pathlib import Path
import runpy

root=Path(__file__).resolve().parents[1]
context=runpy.run_path(str(root/'tests/build_room_harness.py'))
source=(root/'tests/generated-room-validation.luau').read_text()
marker='return { passed = #reports, checks = reports, idleBakeQuality = idleQuality, controlledBakeQuality = controlledQuality }'
checks=r'''
local Cooking=TestCooking
check(Cooking.Turn(0,20,false)==nil and Cooking.Turn(20,20,false)==nil,"Early and late turns cannot earn a bonus")
check(Cooking.Turn(10,20,true)==nil,"Already-turned pizza cannot earn a second bonus")
check(Cooking.Turn(10,20,false).bonus==6 and Cooking.Turn(8,20,false).bonus==3,"Perfect and good turn windows have distinct rewards")
check(Cooking.Turn(0/0,20,false)==nil and Cooking.Turn(10,math.huge,false)==nil,"Invalid turn times are rejected")
for _,recipe in ipairs(TestRecipes.List) do
 local c=Cooking.Checklist(recipe.ingredients,recipe.ingredients)
 check(c.ready and c.extra==0 and c.placed==c.needed,"Exact checklist ready: "..recipe.id)
end
local wrong=Cooking.Checklist({tomato=2},{tomato=1,basil=3})
check(not wrong.ready and wrong.extra==3 and wrong.placed==1,"Unwanted toppings do not count toward required portions")
local extra=Cooking.Checklist({tomato=2},{tomato=3})
check(not extra.ready and extra.extra==1,"Overfilling a required ingredient is visible")
local chef=fakePlayer(2000)
handleAction(chef,"StartPractice","margherita")
handleAction(chef,"Turn")
check(not sessions[chef].turned,"Turn rejected during preparation")
prepare(chef);handleAction(chef,"Bake")
handleAction(chef,"Turn",{bonus=100,elapsed=9})
check(not sessions[chef].turned and sessions[chef].turnBonus==0,"Client cannot forge turn timing or bonus")
local duration=sessions[chef].bakeDuration
advance(duration*.5,chef)
handleAction(chef,"Turn")
check(sessions[chef].turned and sessions[chef].perfectTurn and sessions[chef].turnBonus==6,"Real server awards the perfect mid-bake turn")
local snap=snapshot(chef)
check(snap.turned and snap.perfectTurn and snap.turnBonus==6,"Client snapshot carries authoritative turn feedback")
handleAction(chef,"Turn");handleAction(chef,"Turn")
check(sessions[chef].turnBonus==6,"Repeated remote calls cannot stack turn rewards")
advance(duration*.5+.2,chef)
local raw=sessions[chef].bakeQuality
handleAction(chef,"Serve")
local result=sessions[chef].result
check(result.turnBonus==6 and result.bakeScore==math.min(100,raw+6),"Serving applies the turn bonus once and caps bake quality")
handleAction(chef,"StartPractice","margherita")
check(not sessions[chef].turned and sessions[chef].turnBonus==0 and not sessions[chef].perfectTurn,"New pizzas reset turn state")
prepare(chef);handleAction(chef,"Bake");advance(sessions[chef].bakeDuration*.4,chef);handleAction(chef,"Turn")
check(sessions[chef].turned and not sessions[chef].perfectTurn and sessions[chef].turnBonus==3,"Good turn is accepted before the perfect window")
advance(20,chef);handleAction(chef,"Serve")
handleAction(chef,"StartPractice","margherita");prepare(chef);handleAction(chef,"Bake")
advance(sessions[chef].bakeDuration+.2,chef);handleAction(chef,"Turn");handleAction(chef,"Serve")
check(sessions[chef].result.bakeScore>90 and sessions[chef].result.turnBonus==0,"Skipping a turn preserves a successful temperature-controlled bake")
return {passed=#reports,checks=reports,liveDataStoreAccess=false}
'''
assert marker in source
(root/'tests/generated-cooking-validation.luau').write_text(source.replace(marker,checks))
print(root/'tests/generated-cooking-validation.luau')
