-- Run against the real client after opening a compact screen or modal.
local gui=game.Players.LocalPlayer.PlayerGui:WaitForChild('PizzaChiefUI')
local root=gui.Canvas
local issues,buttons={},0
local function shown(o)
 local p=o
 while p and p~=gui do
  if p:IsA('GuiObject') and not p.Visible then return false end
  p=p.Parent
 end
 return true
end
for _,o in root:GetDescendants() do
 if o:IsA('TextButton') and shown(o) and o.Active then
  buttons+=1
  if o.AbsoluteSize.X<43 or o.AbsoluteSize.Y<43 then table.insert(issues,'Small button: '..o:GetFullName()..' '..tostring(o.AbsoluteSize)) end
 end
end
local dock=root:FindFirstChild('MobileDock')
if dock then
 for _,o in dock:GetChildren() do
  if o:IsA('TextButton') then
   local pos=o.AbsolutePosition-root.AbsolutePosition
   if pos.X<0 or pos.Y<0 or pos.X+o.AbsoluteSize.X>root.AbsoluteSize.X+1 or pos.Y+o.AbsoluteSize.Y>root.AbsoluteSize.Y+1 then table.insert(issues,'Offscreen action: '..o.Name) end
  end
 end
end
return {viewport=tostring(workspace.CurrentCamera.ViewportSize),safeArea=tostring(gui.AbsoluteSize),buttons=buttons,issues=issues,locale=gui:GetAttribute('ResolvedLocale')}
