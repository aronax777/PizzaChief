-- Pizza Chief: hand-built, asset-free kitchen diorama. Safe to rerun in Edit mode.
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local old = Workspace:FindFirstChild("PizzaChiefWorld")
if old then old:Destroy() end
local root = Instance.new("Model")
root.Name = "PizzaChiefWorld"
root.Parent = Workspace
local C = {
 cream=Color3.fromRGB(248,231,200), tile=Color3.fromRGB(243,225,192),
 sage=Color3.fromRGB(75,115,95), mint=Color3.fromRGB(162,187,151),
 dark=Color3.fromRGB(35,59,50), red=Color3.fromRGB(177,65,42),
 terra=Color3.fromRGB(193,101,63), gold=Color3.fromRGB(241,175,70),
 wood=Color3.fromRGB(137,86,48), walnut=Color3.fromRGB(83,54,37),
 metal=Color3.fromRGB(182,185,170), white=Color3.fromRGB(255,246,222),
 green=Color3.fromRGB(71,123,54), tomato=Color3.fromRGB(218,63,40),
 cheese=Color3.fromRGB(250,204,87), dough=Color3.fromRGB(223,155,72),
}
local count=0
local function group(name)
 local m=Instance.new("Model") m.Name=name m.Parent=root return m
end
local function part(parent,name,size,pos,color,material,shape)
 local p=Instance.new("Part") p.Name=name p.Size=size p.Position=pos
 p.Color=color or C.cream p.Material=material or Enum.Material.SmoothPlastic
 p.Anchored=true p.TopSurface=Enum.SurfaceType.Smooth p.BottomSurface=Enum.SurfaceType.Smooth
 if shape then p.Shape=shape end
 p.Parent=parent count+=1
 if count%180==0 then task.wait() end
 return p
end
local function box(parent,name,x,y,z,px,py,pz,color,material)
 return part(parent,name,Vector3.new(x,y,z),Vector3.new(px,py,pz),color,material)
end
local function ball(parent,name,size,pos,color)
 return part(parent,name,size,pos,color,Enum.Material.SmoothPlastic,Enum.PartType.Ball)
end
local function disc(parent,name,radius,height,pos,color,material)
 local p=part(parent,name,Vector3.new(height,radius*2,radius*2),pos,color,material,Enum.PartType.Cylinder)
 p.CFrame=CFrame.new(pos)*CFrame.Angles(0,0,math.pi/2)
 return p
end
local function label(parent,name,text,size,pos,bg,fg,textSize,face)
 local p=part(parent,name,size,pos,bg)
 local g=Instance.new("SurfaceGui") g.Name="Lettering" g.Face=face or Enum.NormalId.Back
 g.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud g.PixelsPerStud=45 g.LightInfluence=0.15 g.Parent=p
 local t=Instance.new("TextLabel") t.Name="Text" t.Size=UDim2.fromScale(1,1) t.BackgroundTransparency=1
 t.Text=text t.TextColor3=fg or C.white t.TextScaled=true t.TextSize=textSize or 40
 t.Font=Enum.Font.GothamBold t.Parent=g
 local pad=Instance.new("UIPadding") pad.PaddingLeft=UDim.new(.04,0) pad.PaddingRight=UDim.new(.04,0)
 pad.PaddingTop=UDim.new(.09,0) pad.PaddingBottom=UDim.new(.09,0) pad.Parent=t
 return p
end
local function light(parent,brightness,range,color)
 local l=Instance.new("PointLight") l.Brightness=brightness l.Range=range l.Color=color or C.gold l.Shadows=true l.Parent=parent
end
local function pizza(parent,center,radius)
 disc(parent,"Hand-stretched crust",radius,.22,center,C.dough)
 disc(parent,"Tomato passata",radius*.86,.07,center+Vector3.new(0,.14,0),C.tomato)
 disc(parent,"Melted mozzarella",radius*.80,.05,center+Vector3.new(0,.19,0),C.cheese)
 for i=1,7 do
  local a=i*2.399 local r=radius*(i%3==0 and .35 or .62)
  local at=center+Vector3.new(math.cos(a)*r,.24,math.sin(a)*r)
  disc(parent,"Pepperoni",radius*.14,.045,at,C.red)
  if i%2==0 then
   local basil=ball(parent,"Fresh basil",Vector3.new(.15,.06,.35),at+Vector3.new(.26,.03,.12),C.green)
   basil.Orientation=Vector3.new(0,i*47,0)
  end
 end
end
local structure=group("01 Architecture")
box(structure,"Floating terracotta foundation",76,1.8,56,0,-1.0,2,C.terra)
box(structure,"Foundation shadow trim",77,.35,57,0,-1.8,2,C.dark)
-- Individually laid tiles make the overhead gameplay camera readable.
for ix=0,17 do for iz=0,11 do
 local color=(ix+iz)%2==0 and C.tile or C.sage
 box(structure,"Checker tile",3.97,.18,3.97,-34+ix*4,.03,-20+iz*4,color)
end end
box(structure,"Back wall plaster",74,15,.8,0,7.2,-22.3,C.cream,Enum.Material.Plaster)
box(structure,"Left wall plaster",.8,10,37,-36.4,4.8,-4,C.cream,Enum.Material.Plaster)
box(structure,"Right back return",.8,9,17,36.4,4.3,-14,C.cream,Enum.Material.Plaster)
box(structure,"Back wainscoting",73,4,.25,0,2,-21.75,C.sage)
box(structure,"Back brass rail",73,.13,.35,0,4.1,-21.45,C.gold,Enum.Material.Metal)
box(structure,"Left wainscoting",.25,4,37,-35.9,2,-4,C.sage)
box(structure,"Left brass rail",.3,.13,37,-35.65,4.1,-4,C.gold,Enum.Material.Metal)
for x=-34,34,3.4 do box(structure,"Wainscot seam",.05,3.4,.12,x,2,-21.55,C.dark) end
for z=-20,12,3.4 do box(structure,"Wainscot seam",.12,3.4,.05,-35.65,2,z,C.dark) end
box(structure,"Back crown molding",75,.42,1.3,0,14.65,-22.1,C.terra)
box(structure,"Crown gold line",74,.13,1.4,0,14.33,-22.0,C.gold)
label(structure,"House name","P I Z Z A   C H I E F",Vector3.new(33,3.3,.35),Vector3.new(0,11.55,-21.65),C.dark,C.white)
label(structure,"House motto","MAKE  /  BAKE  /  IMPRESS",Vector3.new(23,1.05,.25),Vector3.new(0,9.15,-21.6),C.cream,C.red)
label(structure,"House year","EST. 2026   •   THE PIZZA CHAMPIONSHIP",Vector3.new(23,.65,.18),Vector3.new(0,8.2,-21.6),C.cream,C.sage)
-- Front courtyard and street edge, kept entirely open to the camera.
box(structure,"Courtyard",76,.25,11,0,-.03,31.5,Color3.fromRGB(205,181,148),Enum.Material.Cobblestone)
box(structure,"Front threshold",74,.24,.65,0,.15,26,C.terra)
for x=-34,34,4 do box(structure,"Courtyard inlay",.08,.02,9,x,.12,31,C.cream) end
local ovens=group("02 Wood-fired ovens")
for _,x in {-25,25} do
 box(ovens,"Oven pedestal",13,3.4,10,x,1.85,-16.3,C.terra,Enum.Material.Brick)
 box(ovens,"Oven stone ledge",14,.5,11,x,3.7,-16.3,C.cream,Enum.Material.Slate)
 ball(ovens,"Domed terracotta oven",Vector3.new(12,9,10),Vector3.new(x,5,-16.7),C.terra)
 -- Dark entry and a gold stone arch visually cut the dome face.
 ball(ovens,"Stone arch",Vector3.new(5.6,5.6,.85),Vector3.new(x,5,-11.87),C.cream)
 box(ovens,"Stone arch feet",5.5,2.2,.7,x,3.85,-11.8,C.cream)
 ball(ovens,"Oven darkness",Vector3.new(4.5,4.5,.94),Vector3.new(x,4.9,-11.45),C.dark)
 box(ovens,"Firebox darkness",4.4,1.8,.96,x,3.9,-11.4,C.dark)
 local glow=box(ovens,"Fire ember bed",4,.14,1.3,x,3.78,-10.95,Color3.fromRGB(255,119,34),Enum.Material.Neon)
 light(glow,2,13,Color3.fromRGB(255,135,50))
 for n=-1,1 do
  local log=box(ovens,"Oak firewood",.6,.5,1.8,x+n*.85,4.02,-11.1,C.walnut,Enum.Material.Wood)
  log.Orientation=Vector3.new(0,n*17,0)
  local flame=ball(ovens,"Golden flame",Vector3.new(.4,1.1,.25),Vector3.new(x+n*.9,4.55,-10.87),C.gold)
  flame.Material=Enum.Material.Neon
 end
 box(ovens,"Oven chimney",2,7,2,x,11.5,-17.5,C.dark,Enum.Material.Brick)
 box(ovens,"Chimney cap",2.9,.45,2.9,x,14.8,-17.5,C.terra)
 label(ovens,"Oven plaque",x<0 and "01 / FUOCO" or "02 / FIAMMA",Vector3.new(6,.9,.18),Vector3.new(x,2.5,-11.15),C.dark,C.white)
 for n=1,5 do
  local log=disc(ovens,"Stacked firewood",.32,3,Vector3.new(x-3.8+n*1.2,1.0,-10.99),C.wood,Enum.Material.Wood)
  log.CFrame=CFrame.new(log.Position)*CFrame.Angles(0,math.pi/2,0)
 end
end
local chef=group("03 Chef's tasting counter")
box(chef,"Counter base",15,3.4,4.2,0,1.8,-14.5,C.sage)
box(chef,"Counter brass footrail",15.5,.15,.15,0,.65,-12.15,C.gold,Enum.Material.Metal)
box(chef,"Counter marble top",16,.45,5,0,3.7,-14.5,C.cream,Enum.Material.Marble)
for _,x in {-6,-3,0,3,6} do box(chef,"Counter panel",2.7,2.4,.12,x,1.9,-12.31,C.dark) end
label(chef,"Chef nameplate","CHEF LUCA  /  THE FINAL TASTE",Vector3.new(12,.85,.12),Vector3.new(0,2.5,-12.16),C.dark,C.gold)
local skin=Color3.fromRGB(225,169,112)
box(chef,"Chef torso",2.3,2.7,1.35,0,5.25,-16.1,C.white)
box(chef,"Chef apron",1.9,2.3,.15,0,4.95,-15.35,C.cream)
box(chef,"Red neckerchief",1.2,.3,.22,0,6.4,-15.34,C.red)
local tie=box(chef,"Neckerchief point",.36,.7,.2,.05,6,-15.22,C.red) tie.Orientation=Vector3.new(0,0,20)
ball(chef,"Chef head",Vector3.new(1.7,1.85,1.6),Vector3.new(0,7.2,-16),skin)
for _,x in {-.34,.34} do
 ball(chef,"Bright eye",Vector3.new(.13,.15,.06),Vector3.new(x,7.42,-15.23),C.dark)
 local brow=box(chef,"Eyebrow",.28,.08,.1,x,7.65,-15.28,C.walnut) brow.Orientation=Vector3.new(0,0,x*20)
 local moustache=ball(chef,"Chef moustache",Vector3.new(.55,.17,.18),Vector3.new(x*.68,7.02,-15.17),C.walnut)
 moustache.Orientation=Vector3.new(0,0,x*25)
end
ball(chef,"Chef nose",Vector3.new(.3,.32,.3),Vector3.new(0,7.18,-15.12),skin)
disc(chef,"Toque band",.86,.42,Vector3.new(0,8.13,-16),C.white)
for _,v in {Vector3.new(-.47,8.65,-16),Vector3.new(.47,8.65,-16),Vector3.new(0,8.92,-15.9)} do
 ball(chef,"Cloud toque",Vector3.new(1.15,1.3,1.15),v,C.white)
end
for _,side in {-1,1} do
 local arm=box(chef,"Sleeve",.8,1.9,.8,side*1.35,5.25,-15.85,C.white) arm.Orientation=Vector3.new(0,0,side*24)
 ball(chef,"Hand",Vector3.new(.75,.7,.7),Vector3.new(side*1.65,4.45,-15.72),skin)
end
for _,y in {5.0,5.45,5.9} do for _,x in {-.5,.5} do ball(chef,"Coat button",Vector3.new(.11,.11,.07),Vector3.new(x,y,-15.24),C.dark) end end
disc(chef,"Tasting plate",1.3,.1,Vector3.new(0,3.99,-13.3),C.white)
pizza(chef,Vector3.new(0,4.12,-13.3),1.05)
box(chef,"Recipe ledger",1.7,.13,1.3,-4,4,-14,C.dark)
box(chef,"Ledger pages",1.55,.04,1.15,-4,4.1,-14,C.cream)
local bell=disc(chef,"Service bell base",.4,.1,Vector3.new(4.9,4,-13.3),C.dark)
ball(chef,"Service bell",Vector3.new(.65,.4,.65),Vector3.new(4.9,4.18,-13.3),C.gold)
local prep=group("04 Mise en place")
local function station(x,z,index)
 box(prep,"Station "..index.." base",11.7,3.05,5.8,x,1.65,z,C.sage)
 box(prep,"Station "..index.." marble",12.4,.4,6.4,x,3.36,z,C.white,Enum.Material.Marble)
 box(prep,"Station walnut edge",12.4,.13,6.5,x,3.15,z,C.wood)
 for _,dx in {-4,0,4} do
  box(prep,"Drawer face",3.65,1.65,.12,x+dx,2.05,z+2.96,C.dark)
  box(prep,"Brass drawer pull",1.15,.12,.13,x+dx,2.5,z+3.1,C.gold,Enum.Material.Metal)
 end
 label(prep,"Station number","0"..index.."  /  PIZZA LAB",Vector3.new(5,.65,.12),Vector3.new(x,1.0,z+3.08),C.sage,C.white)
 box(prep,"Floured oak board",5.2,.15,3.7,x-1.6,3.65,z+.55,C.wood,Enum.Material.Wood)
 pizza(prep,Vector3.new(x-1.5,3.87,z+.55),1.5)
 local rolling=disc(prep,"Rolling pin",.22,2.3,Vector3.new(x-4.7,3.8,z+.3),C.wood,Enum.Material.Wood)
 rolling.CFrame=CFrame.new(rolling.Position)
 for n=1,4 do
  local dx=-4.4+(n-1)*2.15
  box(prep,"Ingredient steel tray",1.8,.35,1.35,x+dx,3.7,z-2.13,C.metal,Enum.Material.Metal)
  local color=({C.tomato,C.cheese,C.green,C.red})[n]
  box(prep,"Fresh ingredient",1.52,.16,1.1,x+dx,3.93,z-2.13,color)
  for k=1,3 do
   ball(prep,"Ingredient texture",Vector3.new(.4,.2,.34),Vector3.new(x+dx+(k-2)*.45,4.04,z-2.12),color)
  end
 end
 disc(prep,"Flour bowl",.65,.35,Vector3.new(x+4.3,3.83,z+.5),C.terra)
 disc(prep,"Flour",.57,.05,Vector3.new(x+4.3,4.03,z+.5),C.white)
 disc(prep,"Olive oil bottle",.23,.9,Vector3.new(x+4.7,4.04,z-1.1),C.green)
 disc(prep,"Bottle neck",.12,.3,Vector3.new(x+4.7,4.64,z-1.1),C.gold)
end
station(-9,3.5,1) station(9,3.5,2)
station(-25,5.5,3) station(25,5.5,4)
local dining=group("05 Trattoria seating")
local function stool(x,z)
 disc(dining,"Round leather stool",.95,.27,Vector3.new(x,2.05,z),C.red)
 for _,v in {Vector3.new(-.5,0,-.5),Vector3.new(.5,0,-.5),Vector3.new(-.5,0,.5),Vector3.new(.5,0,.5)} do
  box(dining,"Stool leg",.17,1.9,.17,x+v.X,1,z+v.Z,C.walnut,Enum.Material.Wood)
 end
end
for _,x in {-27,-13,13,27} do
 disc(dining,"Bistro table",2.5,.25,Vector3.new(x,3.3,19),C.wood,Enum.Material.Wood)
 disc(dining,"Table pedestal",.25,3.0,Vector3.new(x,1.65,19),C.dark,Enum.Material.Metal)
 disc(dining,"Table foot",1.25,.16,Vector3.new(x,.25,19),C.dark)
 stool(x-3.1,19) stool(x+3.1,19)
 box(dining,"Linen runner",1.25,.035,4.6,x,3.46,19,C.cream)
 disc(dining,"Ceramic vase",.24,.65,Vector3.new(x,3.8,19),C.terra)
 box(dining,"Herb stem",.07,.65,.07,x,4.4,19,C.green)
 for i=1,3 do ball(dining,"Table herbs",Vector3.new(.45,.3,.45),Vector3.new(x+math.sin(i*2)*.2,4.4+i*.12,19),C.green) end
 disc(dining,"Side plate",.62,.07,Vector3.new(x+1.4,3.5,19),C.white)
end
local decor=group("06 House details")
local function plant(x,z,size)
 disc(decor,"Terracotta planter",size*.55,size*.9,Vector3.new(x,size*.45,z),C.terra)
 disc(decor,"Planter rim",size*.63,.18,Vector3.new(x,size*.9,z),C.cream)
 for i=1,6 do
  local a=i*math.pi/3
  local leaf=ball(decor,"Olive foliage",Vector3.new(size*.65,size*1.3,size*.65),Vector3.new(x+math.cos(a)*size*.3,size*(1.1+(i%2)*.3),z+math.sin(a)*size*.3),i%2==0 and C.green or C.mint)
  leaf.Orientation=Vector3.new(math.cos(a)*20,0,math.sin(a)*20)
 end
end
plant(-33,-7,2.1) plant(33,-7,2.1) plant(-34,24,2.4) plant(34,24,2.4)
-- Shelves against the back wall: cookbooks, sacks, bottles, and fresh herbs.
for _,x in {-11,11} do
 box(decor,"Oak shelf",6.1,.25,1.7,x,6.55,-20.7,C.wood,Enum.Material.Wood)
 for i=1,5 do
  local xx=x-2.3+i*.75
  disc(decor,"Olive bottle",.18,.9,Vector3.new(xx,7.1,-20.5),i%2==0 and C.green or C.terra)
  disc(decor,"Bottle stopper",.09,.25,Vector3.new(xx,7.65,-20.5),C.gold)
 end
end
for _,x in {-32,32} do
 label(decor,"Recipe board","TODAY'S SPECIALS\n\nMARGHERITA\nDIAVOLA\nCARBONARA\n\nFRESH. FIRED. FANTASTIC.",Vector3.new(5,5,.2),Vector3.new(x,8,-21.66),C.dark,C.cream)
end
-- Red-and-cream striped awning on the left wall.
box(decor,"Window frame",.3,5,10,-35.67,7.6,2,C.wood)
box(decor,"Window glass",.36,4.5,9.5,-35.45,7.6,2,Color3.fromRGB(118,166,166),Enum.Material.Glass)
box(decor,"Window mullion",.4,4.7,.15,-35.2,7.6,2,C.cream)
box(decor,"Window horizontal",.4,.15,9.6,-35.2,7.6,2,C.cream)
for i=0,7 do
 local awning=box(decor,"Awning stripe",3,.2,1.35,-34.3,10.5,-2.7+i*1.35,i%2==0 and C.red or C.cream)
 awning.Orientation=Vector3.new(0,0,-12)
 box(decor,"Awning valance",.2,.65,1.35,-32.8,10,-2.7+i*1.35,i%2==0 and C.red or C.cream)
end
local open=label(decor,"Open sign","OPEN",Vector3.new(.2,1.2,3.6),Vector3.new(-35.0,8,3),C.dark,C.gold,nil,Enum.NormalId.Right)
local pendants=group("07 Pendant lighting")
for _,x in {-24,-8,8,24} do
 box(pendants,"Ceiling cable",.06,4.6,.06,x,12,0,C.dark)
 local shade=disc(pendants,"Enamel pendant",1.45,.5,Vector3.new(x,9.8,0),C.sage)
 disc(pendants,"Pendant brass rim",1.47,.08,Vector3.new(x,9.53,0),C.gold,Enum.Material.Metal)
 local bulb=ball(pendants,"Warm bulb",Vector3.new(.75,.45,.75),Vector3.new(x,9.45,0),C.white)
 bulb.Material=Enum.Material.Neon light(bulb,1.4,21,Color3.fromRGB(255,222,170))
end
-- Festoon lights above the open courtyard.
for _,x in {-36,36} do box(pendants,"Festoon post",.25,12,.25,x,6,27,C.dark) end
for i=0,15 do
 local x=-36+i*4.8 local y=11.3-math.sin((i/15)*math.pi)*1.6
 local nextX=x+4.8 local nextY=11.3-math.sin(((i+1)/15)*math.pi)*1.6
 if i<15 then
  local a=Vector3.new(x,y,27) local b=Vector3.new(nextX,nextY,27)
  local cable=part(pendants,"Festoon wire",Vector3.new(.045,.045,(b-a).Magnitude),(a+b)/2,C.dark)
  cable.CFrame=CFrame.lookAt((a+b)/2,b)
 end
 local b=ball(pendants,"Festoon bulb",Vector3.new(.28,.38,.28),Vector3.new(x,y-.25,27),C.gold)
 b.Material=Enum.Material.Neon
end
local spawn=Instance.new("SpawnLocation") spawn.Name="KitchenSpawn"
spawn.Size=Vector3.new(5,.2,5) spawn.Position=Vector3.new(0,.3,19) spawn.Anchored=true
spawn.Transparency=1 spawn.CanCollide=false spawn.Neutral=true spawn.Duration=0 spawn.Parent=root
local anchor=box(root,"PrepCameraAnchor",.1,.1,.1,0,6,3,C.white)
anchor.Transparency=1 anchor.CanCollide=false anchor.CanQuery=false
root:SetAttribute("HeroCameraPosition",Vector3.new(40,32,48))
root:SetAttribute("HeroCameraTarget",Vector3.new(0,4,0))
Lighting.ClockTime=17.1 Lighting.Brightness=2.1
Lighting.Ambient=Color3.fromRGB(135,119,98) Lighting.OutdoorAmbient=Color3.fromRGB(160,145,124)
Lighting.EnvironmentDiffuseScale=.65 Lighting.EnvironmentSpecularScale=.45
Lighting.GlobalShadows=true Lighting.ShadowSoftness=.4
for _,name in {"PizzaChiefAtmosphere","PizzaChiefBloom","PizzaChiefColor"} do
 local effect=Lighting:FindFirstChild(name) if effect then effect:Destroy() end
end
local atmosphere=Instance.new("Atmosphere") atmosphere.Name="PizzaChiefAtmosphere"
atmosphere.Density=.22 atmosphere.Offset=.25 atmosphere.Color=Color3.fromRGB(255,223,183)
atmosphere.Decay=Color3.fromRGB(154,143,119) atmosphere.Glare=.13 atmosphere.Haze=.8 atmosphere.Parent=Lighting
local bloom=Instance.new("BloomEffect") bloom.Name="PizzaChiefBloom" bloom.Intensity=.18 bloom.Size=24 bloom.Threshold=1.4 bloom.Parent=Lighting
local grade=Instance.new("ColorCorrectionEffect") grade.Name="PizzaChiefColor" grade.Saturation=.06 grade.Contrast=.05 grade.TintColor=Color3.fromRGB(255,247,231) grade.Parent=Lighting
-- Servers have no CurrentCamera; the client sets its own gameplay view.
if Workspace.CurrentCamera then
 Workspace.CurrentCamera.CFrame=CFrame.lookAt(Vector3.new(40,32,48),Vector3.new(0,4,0))
 Workspace.CurrentCamera.FieldOfView=55
end
return {name=root.Name,parts=count,descendants=#root:GetDescendants()}
