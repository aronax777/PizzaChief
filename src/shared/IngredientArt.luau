-- Original Blender sprites. No HTTP, file access or uploaded asset required.
-- Cache one EditableImage per ingredient; use the same pixels as GUI scanlines
-- if dynamic image creation is unavailable. Instances are owned by the UI page.
local Art = {}
local pixels = require(script.Parent:WaitForChild('IngredientPixels'))
local AssetService = game:GetService('AssetService')
local images = {}
local unavailable = false
Art.Atlas = '' -- Optional approved Roblox atlas; 7 columns, 256px cells.
local order={'tomato','mozzarella','basil','garlic','oregano','olive_oil','parmesan','gorgonzola','ricotta','pepperoni','ham','mushroom','olive','artichoke','anchovy','caper','tuna','onion','pepper','pineapple','chicken','bbq','bacon','egg','black_pepper','pesto','rocket','sausage'}
local indices={};for n,id in ipairs(order) do indices[id]=n-1 end
local function channels(p)
 return bit32.extract(p,24,8),bit32.extract(p,16,8),bit32.extract(p,8,8),bit32.extract(p,0,8)
end
local function content(id)
 if images[id] then return Content.fromObject(images[id]) end
 if unavailable then return nil end
 local image
 local ok,result=pcall(function()
  image=AssetService:CreateEditableImage({Size=Vector2.new(64,64)})
  if not image then return nil end
  local data=pixels[id];local buf=buffer.create(64*64*4);local offset=0
  for n=1,#data.runs,2 do
   local r,g,b,a=channels(data.palette[data.runs[n+1]+1])
   for _=1,data.runs[n] do
    buffer.writeu8(buf,offset,r);buffer.writeu8(buf,offset+1,g);buffer.writeu8(buf,offset+2,b);buffer.writeu8(buf,offset+3,a);offset+=4
   end
  end
  image:WritePixelsBuffer(Vector2.zero,Vector2.new(64,64),buf)
  images[id]=image
  return Content.fromObject(image)
 end)
 if ok and result then return result end
 if image then image:Destroy() end
 unavailable=true
 return nil
end
function Art.Draw(parent,id,x,y,size)
 assert(pixels[id], 'Unknown ingredient artwork: '..tostring(id))
 local holder=Instance.new('Frame');holder.Name='Sprite_'..id;holder.BackgroundTransparency=1
 holder.Position=UDim2.fromOffset(x,y);holder.Size=UDim2.fromOffset(size,size);holder.Parent=parent
 local source=Art.Atlas=='' and content(id) or nil
 if source or Art.Atlas~='' then
  local img=Instance.new('ImageLabel');img.Name='Artwork';img.BackgroundTransparency=1;img.Size=UDim2.fromScale(1,1)
  if source then img.ImageContent=source else
   img.Image=Art.Atlas;local index=indices[id];img.ImageRectOffset=Vector2.new((index%7)*256,math.floor(index/7)*256);img.ImageRectSize=Vector2.new(256,256)
  end
  img.Parent=holder
 else
  local data=pixels[id];local cursor=0
  for n=1,#data.runs,2 do
   local length=data.runs[n];local r,g,b,a=channels(data.palette[data.runs[n+1]+1])
   if a>0 then
    local line=Instance.new('Frame');line.BorderSizePixel=0;line.BackgroundColor3=Color3.fromRGB(r,g,b);line.BackgroundTransparency=1-a/255
    line.Position=UDim2.fromScale((cursor%64)/64,math.floor(cursor/64)/64);line.Size=UDim2.fromScale(length/64,1/64);line.Parent=holder
   end
   cursor+=length
  end
 end
 return holder
end
return Art
