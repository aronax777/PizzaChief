-- Actual client remotes and actual server clock; no score/profile injection.
local p=game.Players.LocalPlayer
local pkg=game.ReplicatedStorage.PizzaChief
local A,G=pkg.Action,pkg.GetState
local R=require(pkg.Recipes)
local checks={}
local function check(ok,name) assert(ok,name);table.insert(checks,name) end
A:FireServer('StartPractice','pepperoni');task.wait(.25)
A:FireServer('Bake');task.wait(.2)
local s=G:InvokeServer()
check(s.message=='@server.empty' and s.phase=='prep','Server rejects empty bake with locale-neutral key')
p:SetAttribute('PizzaChiefLocale','es');task.wait(.2)
check(p.PlayerGui.PizzaChiefUI.Canvas.Toast.Text==require(pkg.Localization).Text('es',s.message),'Current server error localizes after switching')
for id,n in pairs(R.ById.pepperoni.ingredients) do for _=1,n do A:FireServer('Add',id);task.wait(.075) end end
p:SetAttribute('PizzaChiefLocale','en');task.wait(.2)
s=G:InvokeServer();check(s.recipeId=='pepperoni' and s.ingredients.pepperoni==2,'Locale switch preserves order and toppings')
A:FireServer('Bake');task.wait(.2)
s=G:InvokeServer();check(s.phase=='bake','Real oven starts')
local locales={'ar','ja','hi','uk','en'};local index=1;local lastChange=0;local turn=false
local began=os.clock()
while os.clock()-began<26 do
 s=G:InvokeServer()
 if s.phase=='ready' then break end
 assert(s.phase=='bake','Server remains in baking phase')
 local elapsed=s.bakeElapsed
 local drift=math.sin(elapsed*.72)*55+math.sin(elapsed*1.63)*25
 A:FireServer('Heat',math.clamp((R.ById[s.recipeId].temperature-drift-260)/260,0,1))
 if not turn and elapsed/s.bakeDuration>=.48 then A:FireServer('Turn');turn=true end
 if elapsed-lastChange>=3 and index<=#locales then
  p:SetAttribute('PizzaChiefLocale',locales[index]);index+=1;lastChange=elapsed
 end
 task.wait(.15)
end
s=G:InvokeServer();check(s.phase=='ready','Actual server completes baking')
check(s.turned and s.turnBonus==6,'Perfect turn survives locale changes')
A:FireServer('Serve');task.wait(.3)
s=G:InvokeServer();check(s.phase=='result' and s.result.total>90,'Actual serve earns a three-star-level score')
check(s.result.reward.stars==3,'Actual server grants three stars')
return {checks=checks,passed=#checks,result=s.result,persistence=s.profile.persistence,realClient=true,multiClient=false}
