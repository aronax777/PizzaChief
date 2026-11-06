-- Read-only scene snapshot. Chunks are retrieved from _G.PizzaChiefSceneExport.
local HttpService = game:GetService("HttpService")
local function typed(value)
 local kind=typeof(value)
 if kind=="Vector3" then return {type=kind,value={value.X,value.Y,value.Z}} end
 if kind=="Vector2" then return {type=kind,value={value.X,value.Y}} end
 if kind=="Color3" then return {type=kind,value={value.R,value.G,value.B}} end
 if kind=="CFrame" then return {type=kind,value={value:GetComponents()}} end
 if kind=="UDim" then return {type=kind,value={value.Scale,value.Offset}} end
 if kind=="UDim2" then return {type=kind,value={value.X.Scale,value.X.Offset,value.Y.Scale,value.Y.Offset}} end
 if kind=="EnumItem" then return {type="token",value=value.Value} end
 if kind=="BrickColor" then return {type="BrickColor",value=value.Number} end
 if kind=="string" or kind=="boolean" or kind=="number" then return {type=kind,value=value} end
 return nil
end
local basePart={"Anchored","CanCollide","CanTouch","CanQuery","Color","Material","Transparency","Reflectance","Size","CFrame","CastShadow","TopSurface","BottomSurface"}
local classProperties={
 Part={"Shape"},
 SpawnLocation={"Neutral","Duration","Enabled","AllowTeamChangeOnTouch","TeamColor"},
 SurfaceGui={"Face","SizingMode","PixelsPerStud","LightInfluence","CanvasSize","Brightness","AlwaysOnTop","Enabled","ClipsDescendants","ZIndexBehavior"},
 TextLabel={"Text","Font","TextSize","TextScaled","TextColor3","TextTransparency","BackgroundColor3","BackgroundTransparency","Size","Position","AnchorPoint","TextXAlignment","TextYAlignment","TextWrapped","BorderSizePixel","RichText","Visible","ZIndex","AutomaticSize"},
 UIPadding={"PaddingBottom","PaddingLeft","PaddingTop","PaddingRight"},
 PointLight={"Brightness","Color","Range","Shadows","Enabled"},
 Atmosphere={"Density","Offset","Color","Decay","Glare","Haze"},
 BloomEffect={"Enabled","Intensity","Size","Threshold"},
 ColorCorrectionEffect={"Enabled","Brightness","Contrast","Saturation","TintColor"},
 Lighting={"Ambient","OutdoorAmbient","ClockTime","Brightness","EnvironmentDiffuseScale","EnvironmentSpecularScale","GlobalShadows","ShadowSoftness","FogColor","FogStart","FogEnd","ExposureCompensation","GeographicLatitude"},
 Camera={"CFrame","Focus","FieldOfView","CameraType"},
}
local total=0
local function snapshot(instance)
 total+=1
 local entry={class=instance.ClassName,name=instance.Name,properties={},children={}}
 local function capture(name)
  local ok,value=pcall(function() return instance[name] end)
  if ok then entry.properties[name]=typed(value) end
 end
 if instance:IsA("BasePart") then for _,name in basePart do capture(name) end end
 for _,name in classProperties[instance.ClassName] or {} do capture(name) end
 for _,child in instance:GetChildren() do
  if not child:IsA("LuaSourceContainer") then table.insert(entry.children,snapshot(child)) end
 end
 return entry
end
local world=assert(workspace:FindFirstChild("PizzaChiefWorld"),"Missing PizzaChiefWorld")
local lighting=game:GetService("Lighting")
local lightingEntry=snapshot(lighting)
-- Preserve only this game's lighting effects, not unrelated scene content.
local ownedEffects={}
for _,child in lightingEntry.children do if string.sub(child.name,1,10)=="PizzaChief" then table.insert(ownedEffects,child) end end
lightingEntry.children=ownedEffects
local result={version=1,world=snapshot(world),lighting=lightingEntry,camera=snapshot(workspace.CurrentCamera)}
_G.PizzaChiefSceneExport=HttpService:JSONEncode(result)
return {bytes=#_G.PizzaChiefSceneExport,instances=total,chunkSize=32000}
