-- Run in Studio Edit. Checks all original sprites; no uploads or live services.
local shared=game.ReplicatedStorage.PizzaChief
local pixels=require(shared.IngredientPixels)
local recipes=require(shared.Recipes)
local count=0
for _,ingredient in ipairs(recipes.Ingredients) do
 local data=assert(pixels[ingredient.id],ingredient.id)
 local cursor,opaque=0,0
 assert(#data.runs%2==0)
 for n=1,#data.runs,2 do
  local length,index=data.runs[n],data.runs[n+1]
  assert(length>=1 and length<=64 and cursor%64+length<=64,'Scanline bounds: '..ingredient.id)
  assert(data.palette[index+1]~=nil,'Palette index: '..ingredient.id)
  local alpha=bit32.extract(data.palette[index+1],0,8)
  if alpha>0 then opaque+=length end
  cursor+=length
 end
 assert(cursor==64*64 and opaque>100 and opaque<64*64,'Pixel coverage: '..ingredient.id)
 count+=1
end
-- Force the supported offline GUI renderer, independently of EditableImage.
local temp=Instance.new('Folder')
local copy=shared.IngredientPixels:Clone();copy.Parent=temp
local art=shared.IngredientArt:Clone();art.Source=art.Source:gsub('local unavailable = false','local unavailable = true');art.Parent=temp
local Art=require(art)
local holder=Instance.new('Frame')
local fallbackCounts={}
for _,id in ipairs({'tomato','mozzarella','pepperoni','onion'}) do
 local sprite=Art.Draw(holder,id,0,0,80)
 assert(#sprite:GetChildren()>0,'Empty fallback: '..id)
 fallbackCounts[id]=#sprite:GetChildren()
 sprite:Destroy()
 task.wait()
end
holder:Destroy();temp:Destroy()
return {spritesValidated=count,fallbackCounts=fallbackCounts,networkAccess=false}
