-- Run on the actual Client. This changes only the local language attribute.
local p=game.Players.LocalPlayer
local pkg=game.ReplicatedStorage.PizzaChief
local L=require(pkg.Localization)
local gui=p.PlayerGui.PizzaChiefUI
local function visible(o)
 local parent=o
 while parent and parent~=gui do
  if parent:IsA('GuiObject') and not parent.Visible then return false end
  parent=parent.Parent
 end
 return true
end
local before=pkg.GetState:InvokeServer()
local rows={}
for _,lc in ipairs(L.Locales) do
 p:SetAttribute('PizzaChiefLocale',lc.id);task.wait(.2)
 local issues={};local count=0
 for _,o in ipairs(gui:GetDescendants()) do
  if (o:IsA('TextLabel') or o:IsA('TextButton')) and visible(o) then
   count+=1
   if not o.TextFits or o.Text:find('@[%w_]+%.') or o.Text:find('{[%w_]+}') then
    table.insert(issues,{path=o:GetFullName(),text=o.Text,fits=o.TextFits})
   end
  end
 end
 assert(gui:GetAttribute('ResolvedLocale')==lc.id,'Locale change not applied')
 table.insert(rows,{locale=lc.id,textCount=count,issues=issues})
end
local after=pkg.GetState:InvokeServer()
assert(before.recipeId==after.recipeId and before.startedAt==after.startedAt,'Language switch changed order')
for id,amount in pairs(before.ingredients) do assert(after.ingredients[id]==amount,'Language switch changed toppings') end
assert(before.profile.xp==after.profile.xp,'Language switch changed XP')
return {screen=before.phase,device=game:GetService('StudioDeviceSimulatorService'):GetDeviceAsync(),viewport=tostring(workspace.CurrentCamera.ViewportSize),locales=rows,gameplayUnchanged=true}
