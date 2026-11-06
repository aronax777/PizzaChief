local p=game.ReplicatedStorage.PizzaChief
local R=require(p.Recipes)
local folder=Instance.new("Folder");folder.Name="MultiplayerEvidence";folder.Parent=game.Players.LocalPlayer.PlayerGui
local function save(name,value) local v=Instance.new("StringValue");v.Name=name;v.Value=game:GetService("HttpService"):JSONEncode(value);v.Parent=folder end
save("Identity",{name=game.Players.LocalPlayer.Name,id=game.Players.LocalPlayer.UserId,players=#game.Players:GetPlayers()})
task.spawn(function()
for round=1,2 do
 local s
 repeat task.wait(.1);s=p.GetState:InvokeServer() until s.phase=="prep" and s.mode=="competition"
 save("Start"..round,s)
 local recipe=R.ById[s.recipeId]
 local good=(game.Players.LocalPlayer.UserId==-1)==(round==1)
 for id,n in pairs(recipe.ingredients) do for i=1,n do p.Action:FireServer("Add",id);task.wait(.1) end end
 if round==2 and game.Players.LocalPlayer.UserId==-1 then task.wait(25) end
 p.Action:FireServer("Bake");task.wait(.2)
 repeat
  s=p.GetState:InvokeServer()
  if s.phase=="bake" then
   local t=s.bakeElapsed
   local drift=(math.sin(t*.72)*55+math.sin(t*1.63)*25)
   p.Action:FireServer("Heat",good and math.clamp((recipe.temperature-260-drift)/260,0,1) or 0)
  end
  task.wait(.13)
 until s.phase~="bake"
 save("Ready"..round,s)
 p.Action:FireServer("Serve")
 task.wait(.4)
 s=p.GetState:InvokeServer()
 if s.phase=="result" and s.room.phase=="active" then
  local v=game.Players.LocalPlayer.PlayerGui.PizzaChiefUI.Canvas.Page.Verdict
  save("Waiting"..round,{state=s,againActive=v.Again.Active,standings=v.Standings.Text})
 end
 repeat task.wait(.15);s=p.GetState:InvokeServer() until s.phase=="result" and s.room.phase=="finished"
 save("Result"..round,s)
 if round==1 then repeat task.wait(.15);s=p.GetState:InvokeServer() until s.phase=="menu" end
end
end)
return "Two-round real client driver armed; join and rematch still require UI clicks"