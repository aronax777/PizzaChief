-- Pizza Chief: presentation only. All scores and cooking are server-authoritative.
local Players = game:GetService('Players')
local RS = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')
local UIS = game:GetService('UserInputService')
local TweenService = game:GetService('TweenService')
local player = Players.LocalPlayer
local StarterGui = game:GetService('StarterGui')
pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All,false) end)
local playerGui = player:WaitForChild('PlayerGui')
local TextChatService = game:GetService('TextChatService')
-- Legacy chat can create its ScreenGui after CoreGui was disabled during startup.
local function keepChatHidden(chat)
 local legacy=chat:IsA('ScreenGui') and chat.Name=='Chat'
 local modern=chat:IsA('ChatWindowConfiguration') or chat:IsA('ChatInputBarConfiguration') or chat:IsA('ChannelTabsConfiguration')
 if not legacy and not modern then return end
 chat.Enabled=false
 chat:GetPropertyChangedSignal('Enabled'):Connect(function()
  if chat.Enabled then chat.Enabled=false end
 end)
end
playerGui.ChildAdded:Connect(keepChatHidden)
TextChatService.ChildAdded:Connect(keepChatHidden)
for _,child in ipairs(playerGui:GetChildren()) do keepChatHidden(child) end
for _,child in ipairs(TextChatService:GetChildren()) do keepChatHidden(child) end
task.spawn(function()
 for _=1,8 do
  pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat,false) end)
  task.wait(.5)
 end
end)
local package = RS:WaitForChild('PizzaChief')
local Recipes = require(package:WaitForChild('Recipes'))
local Rules = require(package:WaitForChild('GameRules'))
local SocialService=game:GetService('SocialService')
local Action, State, GetState = package:WaitForChild('Action'), package:WaitForChild('State'), package:WaitForChild('GetState')
local C = {ink=Color3.fromRGB(44,48,40), cream=Color3.fromRGB(255,248,230), paper=Color3.fromRGB(255,253,245), green=Color3.fromRGB(42,91,66), sage=Color3.fromRGB(200,216,169), orange=Color3.fromRGB(225,100,54), gold=Color3.fromRGB(245,186,77), muted=Color3.fromRGB(118,121,101), red=Color3.fromRGB(194,62,44)}
local gui=Instance.new('ScreenGui'); gui.Name='PizzaChiefUI'; gui.IgnoreGuiInset=true; gui.ResetOnSpawn=false; gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; gui.Parent=player:WaitForChild('PlayerGui')
local root=Instance.new('Frame'); root.Name='Canvas'; root.Size=UDim2.fromOffset(1440,900); root.AnchorPoint=Vector2.new(.5,.5); root.Position=UDim2.fromScale(.5,.5); root.BackgroundTransparency=1; root.Parent=gui
local scale=Instance.new('UIScale'); scale.Parent=root
local function resize() local v=workspace.CurrentCamera.ViewportSize; scale.Scale=math.min(v.X/1440,v.Y/900) end
resize(); workspace.CurrentCamera:GetPropertyChangedSignal('ViewportSize'):Connect(resize)
local function make(class,parent,props)
 local o=Instance.new(class); for k,v in pairs(props or {}) do o[k]=v end; o.Parent=parent; return o
end
local function round(o,r) make('UICorner',o,{CornerRadius=UDim.new(0,r or 18)}); return o end
local function panel(parent,name,x,y,w,h,color,trans)
 return round(make('Frame',parent,{Name=name,Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(w,h),BackgroundColor3=color or C.paper,BackgroundTransparency=trans or 0,BorderSizePixel=0}),20)
end
local function label(parent,name,text,x,y,w,h,size,color,font)
 return make('TextLabel',parent,{Name=name,Text=text,Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(w,h),BackgroundTransparency=1,TextColor3=color or C.ink,Font=font or Enum.Font.GothamMedium,TextSize=size or 18,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Center,TextWrapped=true})
end
local function button(parent,name,text,x,y,w,h,color,fn)
 local b=round(make('TextButton',parent,{Name=name,Text=text,Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(w,h),BackgroundColor3=color or C.green,TextColor3=C.cream,Font=Enum.Font.GothamBold,TextSize=18,BorderSizePixel=0,AutoButtonColor=true}),12)
 if fn then b.Activated:Connect(fn) end; return b
end
local function send(a,v) Action:FireServer(a,v) end
local header=panel(root,'Header',30,26,1380,76,C.green)
label(header,'Brand','PIZZA CHIEF',24,10,280,34,30,C.cream,Enum.Font.GothamBlack)
label(header,'Tagline','MAKE IT. BAKE IT. OWN IT.',25,45,320,20,11,C.sage)
local status=label(header,'Status','LA CUCINA • ТВОЯ КУХНЯ',465,20,510,36,17,C.cream); status.TextXAlignment=Enum.TextXAlignment.Center
local clock=label(header,'Clock','BUON APPETITO!',1100,20,252,36,19,C.gold,Enum.Font.GothamBold); clock.TextXAlignment=Enum.TextXAlignment.Right
local page=make('Frame',root,{Name='Page',Position=UDim2.fromOffset(0,112),Size=UDim2.fromOffset(1440,740),BackgroundTransparency=1})
local footer=label(root,'Footer','PIZZA CHIEF  /  SECOND SERVING     •     Готуй. Рости. Дивуй.',35,865,1000,20,12,C.cream)
local toast=label(root,'Toast','',430,817,580,44,16,C.cream); toast.TextXAlignment=Enum.TextXAlignment.Center; toast.BackgroundColor3=C.green; toast.BackgroundTransparency=.08; toast.Visible=false; toast.ZIndex=30; round(toast,12)
local data=nil
local refs={}
local signature=''
local chosen=Recipes.List[1].id
local modal=nil
local draggingHeat=false
local touchPosition=nil
local localNoticeUntil=0
local localNotice=''
local inviteBusy=false
local function notify(message) localNotice=message;localNoticeUntil=workspace:GetServerTimeNow()+5 end
local function inviteFriends()
 if inviteBusy then return end
 if game.PlaceId==0 or RunService:IsStudio() then notify('Запрошення друзів з’являться в опублікованій грі. У Studio: Server & Clients → 2 гравці.');return end
 inviteBusy=true
 task.spawn(function()
  local ok,allowed=pcall(function() return SocialService:CanSendGameInviteAsync(player) end)
  if ok and allowed then local sent=pcall(function() SocialService:PromptGameInvite(player) end);if not sent then notify('Не вдалося відкрити запрошення. Спробуй пізніше.') end else notify('Запрошення зараз недоступні для цього акаунта.') end
  inviteBusy=false
 end)
end
local function stars(n) n=math.clamp(math.floor(n or 0),0,3);return string.rep('★',n)..string.rep('☆',3-n) end
local ingredientById={}; for _,i in ipairs(Recipes.Ingredients) do ingredientById[i.id]=i end
local function rgb(v) if typeof(v)=='Color3' then return v end; return Color3.fromRGB(v[1] or 200,v[2] or 120,v[3] or 70) end
local function pizza(parent,x,y,w,h,ingredients,baked)
 local vp=make('ViewportFrame',parent,{Name='PizzaPreview',Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(w,h),BackgroundTransparency=1,Ambient=Color3.fromRGB(190,180,150),LightColor=Color3.fromRGB(255,245,212),LightDirection=Vector3.new(-1,-3,-2)})
 local cam=Instance.new('Camera'); cam.CFrame=CFrame.lookAt(Vector3.new(0,8.2,5.2),Vector3.new(0,0,0)); cam.FieldOfView=36; cam.Parent=vp; vp.CurrentCamera=cam
 local world=Instance.new('WorldModel'); world.Parent=vp
 local function part(name,size,cf,color,shape)
  local p=Instance.new('Part'); p.Name=name; p.Size=size; p.CFrame=cf; p.Color=color; p.Anchored=true; p.Material=Enum.Material.SmoothPlastic; p.Shape=shape or Enum.PartType.Block; p.Parent=world; return p
 end
 local function disc(name,r,y,t,c) return part(name,Vector3.new(t,r*2,r*2),CFrame.new(0,y,0)*CFrame.Angles(0,0,math.pi/2),c,Enum.PartType.Cylinder) end
 disc('Ceramic plate',3.4,-.3,.16,C.cream); disc('Golden crust',2.94,0,.35,baked and Color3.fromRGB(190,113,42) or Color3.fromRGB(235,190,116))
 disc('Soft dough',2.65,.19,.05,Color3.fromRGB(251,223,151))
 if ingredients.tomato or ingredients.tomato_sauce then disc('San Marzano',2.61,.23,.06,C.red) end
 if ingredients.mozzarella then disc('Melted mozzarella',2.4,.27,.06,Color3.fromRGB(255,225,142)) end
 local n=0
 for _,ing in ipairs(Recipes.Ingredients) do local count=ingredients[ing.id] or 0
  if count>0 and ing.id~='tomato' and ing.id~='tomato_sauce' and ing.id~='mozzarella' then
   n+=1
   for j=1,math.min(12,count*5) do local a=j*2.399+n*.8; local r=.6+((j*7+n*3)%17)/10; local px,pz=math.cos(a)*r,math.sin(a)*r; local col=rgb(ing.color)
    if ing.id=='basil' or ing.id=='rocket' or ing.id=='oregano' then part(ing.id,Vector3.new(.3,.06,.65),CFrame.new(px,.4+n*.016,pz)*CFrame.Angles(0,a,0),col,Enum.PartType.Ball)
    elseif ing.id=='pepperoni' or ing.id=='salami' or ing.id=='tomato' then part(ing.id,Vector3.new(.07,.66,.66),CFrame.new(px,.38+n*.016,pz)*CFrame.Angles(0,0,math.pi/2),col,Enum.PartType.Cylinder)
    else part(ing.id,Vector3.new(.36,.14,.38),CFrame.new(px,.38+n*.016,pz)*CFrame.Angles(0,a,0),col,Enum.PartType.Ball) end
   end
  end
 end
 for j=1,24 do local a=j*math.pi/12; part('Crust blister',Vector3.new(.1,.2,.23),CFrame.new(math.cos(a)*2.8,.2,math.sin(a)*2.8),Color3.fromRGB(181,113,53),Enum.PartType.Ball) end
 return vp
end
local function recipeLines(recipe)
 local lines={}; for _,i in ipairs(Recipes.Ingredients) do local n=recipe.ingredients[i.id]; if n then table.insert(lines,i.name..'  ×'..n) end end; return table.concat(lines,'\n')
end
local function openRecipes()
 if modal then modal:Destroy() end
 modal=make('Frame',root,{Name='RecipeOverlay',Size=UDim2.fromScale(1,1),BackgroundColor3=C.ink,BackgroundTransparency=.35,BorderSizePixel=0,Active=true,ZIndex=20})
 local book=panel(modal,'RecipeBook',155,123,1130,700,C.cream)
 label(book,'Title','КНИГА РЕЦЕПТІВ',30,18,850,40,30,C.green,Enum.Font.GothamBlack)
 label(book,'Subtitle','3★: рецепт ≥95% · піч ≥90% · оцінка ≥90. У тренуванні доступні всі піци.',30,62,920,26,16,C.muted)
 button(book,'Close','×',1040,20,60,50,C.green,function() modal:Destroy(); modal=nil end)
 local scroll=make('ScrollingFrame',book,{Name='RecipeList',Position=UDim2.fromOffset(25,105),Size=UDim2.fromOffset(1080,570),CanvasSize=UDim2.fromOffset(0,math.ceil(#Recipes.List/3)*166),ScrollBarThickness=5,BackgroundTransparency=1,BorderSizePixel=0})
 for index,r in ipairs(Recipes.List) do
  local x=((index-1)%3)*358; local y=math.floor((index-1)/3)*166
  local card=panel(scroll,r.id,x,y,344,152,C.paper)
  label(card,'Name',r.name,16,10,310,28,20,C.green,Enum.Font.GothamBold)
  label(card,'Recipe',r.description or '',16,43,310,38,13,C.muted)
  local best=data and data.profile and data.profile.recipeBest and data.profile.recipeBest[r.id] or {}
  label(card,'Mastery',stars(best.stars)..'  '..(best.score and math.floor(best.score+.5)..'/100' or '—')..(index>(data and data.profile and data.profile.unlockedRecipes or 6) and ' · лише тренування' or ' · у кар’єрі'),16,81,310,22,13,C.orange,Enum.Font.GothamBold)
  button(card,'Choose','Тренувати рецепт  →',16,110,310,30,C.green,function() chosen=r.id; modal:Destroy(); modal=nil; send('StartPractice',chosen) end)
 end
end
local function progress(parent,name,x,y,w,value,color)
 local track=panel(parent,name,x,y,w,10,Color3.fromRGB(225,225,207)); round(track,5)
 local fill=panel(track,'Fill',0,0,math.max(1,w*value),10,color or C.green); round(fill,5); return fill
end
local function buildMenu()
 local p=panel(page,'Welcome',35,15,620,661,C.cream)
 label(p,'Eyebrow','SECOND SERVING / НОВА ЗМІНА',30,26,560,24,14,C.orange,Enum.Font.GothamBold)
 label(p,'Hero','Ще одну.\nІдеальну.',30,62,560,138,57,C.green,Enum.Font.GothamBlack)
 label(p,'Intro','Три замовлення. Три різні виклики.\nВід новачка до легенди піци.',32,212,555,64,22,C.ink)
 local shift=panel(p,'ShiftCard',25,299,570,195,C.green)
 label(shift,'Title','01 / ЗМІНА ШЕФА',20,15,530,30,22,C.cream,Enum.Font.GothamBold)
 label(shift,'Body','Класика → примхлива піч → година пік.\nТримай серію та побий свій рекорд.',20,53,530,55,17,C.sage)
 refs.shiftBest=label(shift,'Best','Рекорд зміни: — / 300',20,112,525,23,14,C.gold)
 button(shift,'Start','ПОЧАТИ ЗМІНУ  →',20,146,530,36,C.orange,function() send('StartShift') end)
 label(p,'PracticeHint','Без таймера? Відточи смак у тренуванні.',30,516,550,30,17,C.muted)
 button(p,'Practice','Вільна кухня',25,568,272,52,C.green,function() send('StartPractice',chosen) end)
 button(p,'Book','Паспорт піц  ★',312,568,283,52,C.orange,openRecipes)
 local profile=panel(page,'Career',685,15,720,205,C.cream)
 refs.rank=label(profile,'Rank','1 / ПОЧАТКІВЕЦЬ',24,18,670,38,29,C.green,Enum.Font.GothamBlack)
 refs.xp=label(profile,'XP','0 XP',24,63,670,27,17,C.muted)
 refs.xpFill=progress(profile,'Progress',24,107,672,0,C.orange)
 refs.profileDetails=label(profile,'Details','',24,132,672,54,16,C.green)
 local daily=panel(page,'DailyCard',685,242,346,255,C.cream)
 label(daily,'Label','02 / ВИКЛИК ДНЯ',21,16,303,27,17,C.orange,Enum.Font.GothamBold)
 refs.dailyName=label(daily,'Name','Особливий рецепт',21,54,303,57,26,C.green,Enum.Font.GothamBlack)
 refs.dailyText=label(daily,'Description','Однакові умови для всіх.\nСпробуй краще за друзів.',21,118,303,62,16,C.muted)
 button(daily,'Start','ПРИЙНЯТИ ВИКЛИК',21,197,303,40,C.green,function() send('StartDaily') end)
 local battle=panel(page,'CompetitionCard',1051,242,354,255,C.green)
 label(battle,'Label','03 / PIZZA BATTLE',20,16,314,27,18,C.gold,Enum.Font.GothamBold)
 label(battle,'Title','Хто тут шеф?',20,55,314,57,28,C.cream,Enum.Font.GothamBlack)
 refs.roomInfo=label(battle,'Body','2–6 кухарів · 90 секунд.\nОдин рецепт. Чесний реванш.',20,119,314,60,16,C.sage)
 refs.join=button(battle,'Join','ДО ЗМАГАННЯ →',20,197,314,40,C.orange,function() if data and data.room and (data.room.member or data.room.queued) then send('LeaveRoom') else send('JoinRoom') end end)
 local badge=panel(page,'Collection',685,519,720,157,C.green)
 refs.collection=label(badge,'Count','0 / 60 ЗІРОК МАЙСТЕРНОСТІ',23,15,674,32,21,C.gold,Enum.Font.GothamBold)
 refs.badges=label(badge,'Badges','Перший ідеальний рецепт — твоя наступна ціль.',23,54,674,40,16,C.cream)
 button(badge,'Passport','Переглянути колекцію',23,106,330,34,C.orange,openRecipes)
 button(badge,'Invite','Покликати друга',368,106,330,34,C.orange,inviteFriends)
 refs.lobby=panel(page,'Lobby',685,242,720,434,C.cream); refs.lobby.Visible=false
 label(refs.lobby,'Heading','PIZZA BATTLE / КІМНАТА',25,18,670,35,25,C.green,Enum.Font.GothamBlack)
 refs.lobbyStatus=label(refs.lobby,'Status','',25,66,670,36,18,C.orange,Enum.Font.GothamBold)
 refs.lobbyPlayers=label(refs.lobby,'Players','',25,115,670,215,22,C.green)
 button(refs.lobby,'Invite','Покликати друга',25,358,325,46,C.orange,inviteFriends)
 button(refs.lobby,'Leave','Вийти з кімнати',370,358,325,46,C.green,function() send('LeaveRoom') end)
end
local function buildKitchen()
 local recipe=Recipes.ById[data.recipeId] or Recipes.List[1]
 local p=panel(page,'Pantry',30,10,310,660,C.cream)
 label(p,'Title','КОМОРА',20,18,270,32,25,C.green,Enum.Font.GothamBlack)
 label(p,'Hint',data.phase=='prep' and '+ додати   /   − прибрати' or 'Рецепт зафіксовано',20,52,275,24,14,C.muted)
 local list=make('ScrollingFrame',p,{Name='Ingredients',Position=UDim2.fromOffset(15,92),Size=UDim2.fromOffset(280,490),CanvasSize=UDim2.fromOffset(0,#Recipes.Ingredients*52),ScrollBarThickness=4,BorderSizePixel=0,BackgroundTransparency=1})
 refs.counts={}
 local pantry=table.clone(Recipes.Ingredients)
 table.sort(pantry,function(a,b) local aa=recipe.ingredients[a.id]~=nil;local bb=recipe.ingredients[b.id]~=nil;if aa~=bb then return aa end;return a.name<b.name end)
 for n,i in ipairs(pantry) do
  local row=panel(list,i.id,0,(n-1)*52,268,46,C.paper)
  local dot=panel(row,'Color',9,12,20,20,rgb(i.color)); round(dot,10)
  label(row,'Name',i.name,39,4,134,38,13,C.ink)
  refs.counts[i.id]=label(row,'Count','0',174,4,21,38,15,C.green,Enum.Font.GothamBold)
  button(row,'Remove','−',201,8,27,29,C.muted,function() send('Remove',i.id) end)
  button(row,'Add','+',234,8,27,29,C.green,function() send('Add',i.id) end)
 end
 button(p,'Clear',data.phase=='prep' and 'Очистити основу' or 'Інгредієнти вже у печі',20,603,270,38,data.phase=='prep' and C.orange or C.muted,function() send('Clear') end)
 if data.phase~='prep' then for _,v in list:GetDescendants() do if v:IsA('TextButton') then v.Active=false;v.AutoButtonColor=false;v.BackgroundTransparency=.55 end end end
 local ticket=panel(page,'OrderTicket',1080,10,330,487,C.paper)
 label(ticket,'Eyebrow',data.contract and data.contract.name or 'ЗАМОВЛЕННЯ / ORDER',22,18,285,22,13,C.orange,Enum.Font.GothamBold)
 label(ticket,'RecipeName',recipe.name,22,53,286,75,29,C.green,Enum.Font.GothamBlack)
 label(ticket,'Description',recipe.description or '',22,132,286,53,15,C.muted)
 label(ticket,'Divider','--------------------------------',22,191,286,18,15,C.sage)
 label(ticket,'Ingredients',recipeLines(recipe),22,218,286,180,17,C.ink)
 label(ticket,'OvenInfo',tostring(recipe.temperature)..'°C   /   '..tostring(recipe.bakeTime)..' с у печі',22,424,286,35,17,C.orange,Enum.Font.GothamBold)
 local steps=panel(page,'Steps',370,10,680,54,C.green)
 refs.steps=label(steps,'Text','01  ЗБЕРИ     →     02  ВИПІКАЙ     →     03  ШЕФ',20,10,640,34,16,C.cream,Enum.Font.GothamBold); refs.steps.TextXAlignment=Enum.TextXAlignment.Center
 local board=panel(page,'Workbench',370,273,680,397,C.cream)
 label(board,'Label',data.phase=='prep' and 'ТВОЯ МАЙБУТНЯ ЛЕГЕНДА' or 'ВІД РЕЦЕПТА ДО ШЕДЕВРА',20,14,640,24,13,C.muted,Enum.Font.GothamBold)
 refs.pizzaHolder=make('Frame',board,{Name='PizzaHolder',Position=UDim2.fromOffset(10,34),Size=UDim2.fromOffset(660,280),BackgroundTransparency=1})
 pizza(refs.pizzaHolder,0,0,660,280,data.ingredients or {},data.phase~='prep')
 if data.phase=='prep' then
  refs.match=label(board,'Match','',20,310,385,35,18,C.green,Enum.Font.GothamBold)
  button(board,'Bake','У ПІЧ  →',434,318,224,54,C.orange,function() send('Bake') end)
 elseif data.phase=='bake' then
  label(board,'BakeHint','Утримуй жар у зеленій зоні',20,310,620,34,21,C.green,Enum.Font.GothamBold)
  refs.bakeProgress=progress(board,'BakeProgress',20,364,638,0,C.orange)
 elseif data.phase=='ready' then
  label(board,'Ready','Піца готова. Час вразити шефа!',22,308,400,55,18,C.green,Enum.Font.GothamBold)
  button(board,'Serve','ПОДАТИ  →',434,318,224,54,C.orange,function() send('Serve') end)
 end
 if data.phase=='bake' then
  local oven=panel(page,'OvenControl',370,80,680,177,C.green)
  label(oven,'Title','FORNO • КЕРУВАННЯ ПІЧЧЮ',20,12,530,22,14,C.sage,Enum.Font.GothamBold)
  refs.temp=label(oven,'Temperature','',20,38,190,48,35,C.cream,Enum.Font.GothamBlack)
  refs.heat=label(oven,'Heat','',226,48,425,35,16,C.cream)
  refs.powerTrack=panel(oven,'PowerSlider',226,84,430,8,C.ink); refs.powerTrack.Active=true
  refs.powerKnob=panel(refs.powerTrack,'Knob',210,-5,18,18,C.gold); round(refs.powerKnob,9)
  refs.powerTrack.InputBegan:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then draggingHeat=true; touchPosition=input.UserInputType==Enum.UserInputType.Touch and input.Position or nil end end)
  refs.powerKnob.Active=true; refs.powerKnob.InputBegan:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then draggingHeat=true; touchPosition=input.UserInputType==Enum.UserInputType.Touch and input.Position or nil end end)
  local track=panel(oven,'TemperatureTrack',22,100,636,18,Color3.fromRGB(22,53,40)); round(track,9)
  local band=data.contract and data.contract.temperatureBand or 25
  local low=(recipe.temperature-band-250)/280; local high=(recipe.temperature+band-250)/280
  panel(track,'PerfectZone',math.clamp(low,0,1)*636,0,(high-low)*636,18,C.sage)
  refs.needle=panel(track,'Needle',0,-5,5,28,C.gold); round(refs.needle,2)
  refs.down=button(oven,'Cool','−  Менше жару',22,132,205,32,C.orange,function() send('Heat',math.clamp((data.heat or .5)-.08,0,1)) end)
  label(oven,'Keys','A / D  або кнопки',240,132,210,32,13,C.sage)
  refs.up=button(oven,'Hot','Більше жару  +',454,132,205,32,C.orange,function() send('Heat',math.clamp((data.heat or .5)+.08,0,1)) end)
 else
  local tip=panel(page,'Tip',390,95,640,114,C.green,.07)
  label(tip,'ChefHint',data.contract and ('ЦІЛЬ: '..tostring(data.contract.goal)..'+ БАЛІВ') or 'ПОРАДА ШЕФА',20,12,600,23,12,C.gold,Enum.Font.GothamBold)
  label(tip,'Text',data.phase=='ready' and 'Золотиста скоринка? Збалансований смак?\nПокажи, на що ти здатен.' or (data.contract and data.contract.description or 'Дотримуйся пропорцій у замовленні.\nЗайві інгредієнти теж впливають на оцінку.'),20,40,600,61,19,C.cream)
 end
 button(page,'Exit',data.mode=='competition' and 'Вийти зі змагання' or '←  До меню',1080,521,330,45,C.green,function() send(data.mode=='competition' and 'LeaveRoom' or 'Menu') end)
 if data.mode=='practice' then button(page,'ChangeRecipe','Паспорт піц',1080,580,330,45,C.orange,openRecipes) else local runPanel=panel(page,'RunSummary',1080,580,330,81,C.green);refs.runInfo=label(runPanel,'RunInfo','',15,8,300,65,16,C.cream,Enum.Font.GothamBold) end
end
local function openRecordCard()
 if modal then modal:Destroy() end
 local r=data.result or {};local reward=r.reward or {};local profile=data.profile or {}
 modal=make('Frame',root,{Name='RecordOverlay',Size=UDim2.fromScale(1,1),BackgroundColor3=C.ink,BackgroundTransparency=.2,BorderSizePixel=0,Active=true,ZIndex=20})
 local card=panel(modal,'RecordCard',330,145,780,595,C.cream)
 label(card,'Brand','PIZZA CHIEF  /  МІЙ ВИКЛИК ТОБІ',32,26,716,35,22,C.green,Enum.Font.GothamBlack)
 label(card,'Name',player.DisplayName..'  •  '..(profile.title or 'Шеф'),32,75,716,36,20,C.muted)
 local score=label(card,'Score',tostring(math.floor((r.total or 0)+.5)),32,134,716,130,105,C.green,Enum.Font.GothamBlack);score.TextXAlignment=Enum.TextXAlignment.Center
 local mastery=label(card,'Stars',stars(reward.stars),32,266,716,55,43,C.orange);mastery.TextXAlignment=Enum.TextXAlignment.Center
 local name=label(card,'Recipe',r.recipeName or '',32,330,716,45,30,C.green,Enum.Font.GothamBold);name.TextXAlignment=Enum.TextXAlignment.Center
 label(card,'Numbers',string.format('ЯКІСТЬ %.0f%%    /    ШВИДКІСТЬ %.0f%%    /    %.1f С',r.quality or 0,r.speed or 0,r.elapsed or 0),32,389,716,36,19,C.green).TextXAlignment=Enum.TextXAlignment.Center
 label(card,'Hint','Збережи скріншот або запроси друга на реванш.',32,440,716,28,16,C.muted).TextXAlignment=Enum.TextXAlignment.Center
 button(card,'Invite','Покликати друга',32,504,345,51,C.orange,inviteFriends)
 button(card,'Close','Повернутися',402,504,345,51,C.green,function() modal:Destroy();modal=nil end)
end
local function buildResult()
 local r=data.result or {};local reward=r.reward or {};local card=panel(page,'Verdict',265,10,910,685,C.cream)
 label(card,'Eyebrow',data.shift and data.shift.finished and 'ЗМІНУ ЗАВЕРШЕНО / BELLISSIMO' or 'IL VERDETTO / ВЕРДИКТ ШЕФА',32,18,680,27,15,C.orange,Enum.Font.GothamBold)
 label(card,'Title',r.recipeName or 'Твоя піца',32,58,650,58,39,C.green,Enum.Font.GothamBlack)
 local score=label(card,'Score','0',709,42,175,94,70,C.green,Enum.Font.GothamBlack)
 local counter=make('NumberValue',card,{Value=0});counter.Changed:Connect(function(v) score.Text=tostring(math.floor(v+.5)) end);TweenService:Create(counter,TweenInfo.new(.65,Enum.EasingStyle.Quart),{Value=r.total or 0}):Play()
 label(card,'Stars',stars(reward.stars),34,119,400,37,28,C.orange,Enum.Font.GothamBold)
 label(card,'ScoreCaption','БАЛІВ / 100',711,136,175,22,13,C.muted)
 local quality=math.floor((r.quality or 0)+.5);local speed=math.floor((r.speed or 0)+.5)
 label(card,'Quality','ЯКІСТЬ  '..quality..'%',38,174,395,30,21,C.green,Enum.Font.GothamBold)
 progress(card,'QualityBar',38,214,394,quality/100,C.green)
 label(card,'Speed','ШВИДКІСТЬ  '..speed..'%',478,174,395,30,21,C.orange,Enum.Font.GothamBold)
 progress(card,'SpeedBar',478,214,394,speed/100,C.orange)
 label(card,'Detail',string.format('Рецепт %.0f%%  •  Піч %.0f%%  •  Час %.1f с',r.recipeScore or 0,r.bakeScore or 0,r.elapsed or 0),38,237,835,29,17,C.muted)
 local gains=panel(card,'Rewards',30,279,850,79,C.green)
 label(gains,'XP','+'..tostring(reward.xp or 0)..' XP  ·  '..(reward.headline or 'Спробуй ще раз'),17,10,818,29,22,C.gold,Enum.Font.GothamBold)
 refs.rewardDetail=label(gains,'Detail','',17,43,818,24,15,C.cream)
 local feedback=r.feedback;if type(feedback)=='table' then feedback=table.concat(feedback,' ') end
 label(card,'Feedback',feedback or 'Кожна піца — крок до майстерності.',38,370,835,49,19,C.ink)
 refs.standings=label(card,'Standings','',38,427,835,116,16,C.green)
 refs.again=button(card,'Again','Наступне замовлення →',38,559,402,51,C.orange,function()
  if data.mode=='competition' then send('JoinRoom') elseif data.mode=='shift' then send(data.shift and data.shift.finished and 'StartShift' or 'NextOrder') elseif data.mode=='daily' then send('StartDaily') else send('StartPractice',data.recipeId) end
 end)
 button(card,'Menu','До головного меню',466,559,407,51,C.green,function() send(data.mode=='competition' and 'LeaveRoom' or 'Menu') end)
 button(card,'Record','Картка результату  /  виклик другу',38,625,835,37,C.orange,openRecordCard)
 if (reward.stars or 0)>=2 then
  for i=1,16 do
   local a=i*math.pi/8
   local spark=label(card,'Celebration','✦',765,84,22,22,20,i%2==0 and C.gold or C.orange)
   TweenService:Create(spark,TweenInfo.new(.9,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Position=UDim2.fromOffset(765+math.cos(a)*120,84+math.sin(a)*70),TextTransparency=1,Rotation=i*25}):Play()
   task.delay(1,function() spark:Destroy() end)
  end
 end
end
local function update(d)
 data=d;if not d then return end
 local sig=tostring(d.phase)..':'..tostring(d.recipeId)..':'..tostring(d.mode)..':'..tostring(d.shift and d.shift.stage or 0)
 if sig~=signature then
  if modal then modal:Destroy();modal=nil end
  signature=sig;draggingHeat=false;page:ClearAllChildren();refs={}
  if d.phase=='menu' or not d.phase then buildMenu() elseif d.phase=='result' then buildResult() else buildKitchen() end
 end
 local profile=d.profile or {};local recipe=Recipes.ById[d.recipeId]
 if refs.counts then for id,l in pairs(refs.counts) do local n=(d.ingredients or {})[id] or 0;l.Text=tostring(n);l.TextColor3=n==(recipe.ingredients[id] or 0) and C.green or C.orange end end
 local ingSig='';for _,i in ipairs(Recipes.Ingredients) do ingSig..=tostring((d.ingredients or {})[i.id] or 0)..',' end
 if refs.pizzaHolder and refs.ingSig~=ingSig then refs.ingSig=ingSig;refs.pizzaHolder:ClearAllChildren();pizza(refs.pizzaHolder,0,0,660,280,d.ingredients or {},d.phase~='prep') end
 if refs.match then local m=Recipes.Match(d.ingredients or {});refs.match.Text=(m.name or '')..'  '..math.floor(m.score or 0)..'%' end
 if refs.powerKnob then refs.powerKnob.Position=UDim2.fromOffset((d.heat or .5)*412,-5) end
 if refs.temp then refs.temp.Text=tostring(math.floor(d.temperature or 0))..'°C';refs.heat.Text='Жар: '..math.floor((d.heat or .5)*100)..'%  •  Ціль: '..recipe.temperature..'°C';refs.needle.Position=UDim2.fromOffset(math.clamp(((d.temperature or 250)-250)/280,0,1)*631,-5) end
 if refs.bakeProgress then refs.bakeProgress.Size=UDim2.fromOffset(638*math.clamp((d.bakeElapsed or 0)/math.max(1,d.bakeDuration or 22),0,1),10) end
 local room=d.room or {};local players=room.players or {}
 if refs.rank then
  refs.rank.Text='РАНГ '..tostring(profile.level or 1)..' / '..(profile.title or 'Початківець')
  refs.xp.Text=tostring(profile.xp or 0)..' XP'..(profile.nextXP and '  •  Наступний ранг: '..tostring(profile.nextXP)..' XP' or '  •  Найвищий ранг')
  refs.xpFill.Size=UDim2.fromOffset(math.max(1,672*(profile.progress or 0)),10)
  refs.profileDetails.Text=tostring(profile.unlockedRecipes or 6)..'/20 рецептів у кар’єрі   •   '..tostring(profile.completed or 0)..' піц\n'..tostring(profile.battleWins or 0)..' перемог   •   Найкраща серія: ×'..tostring(profile.bestCombo or 0)
  refs.shiftBest.Text='Рекорд зміни: '..math.floor((profile.bestShift or 0)+.5)..' / 300'
  refs.collection.Text=tostring(profile.totalStars or 0)..' / 60 ЗІРОК МАЙСТЕРНОСТІ'
  local names={};for _,badge in ipairs(profile.badges or {}) do table.insert(names,badge.name) end
  local shown={};for i=math.max(1,#names-2),#names do table.insert(shown,names[i]) end
  refs.badges.Text=#names>0 and (table.concat(shown,'  •  ')..(#names>3 and '  ·  ще '..(#names-3) or '')) or 'Перша ціль: приготуй піцу на 80+ балів.'
  local daily=d.daily or d.dailyChallenge or Rules.Daily(math.floor(os.time()/86400),Recipes)
  refs.dailyName.Text=Recipes.ById[daily.recipeId] and Recipes.ById[daily.recipeId].name or daily.name
  local dailyDone=profile.lastDailyDay==math.floor((d.serverNow or os.time())/86400)
  refs.dailyText.Text=dailyDone and ('Бонус отримано · рекорд '..math.floor((profile.dailyBest and profile.dailyBest.score or 0)+.5)..'/100\nСпробуй покращити результат.') or ((daily.name or 'Виклик дня')..'\n'..tostring(daily.goal or 85)..'+ балів → +'..tostring(daily.bonusXP or 60)..' XP за перше проходження')
 end
 if refs.lobby then
  refs.lobby.Visible=room.member or room.queued or false
  refs.lobbyStatus.Text=room.queued and 'Наступний раунд — ти у черзі' or (room.phase=='countdown' and 'Усі готові! Стартуємо разом…' or 'Запроси друзів до цього сервера')
  local names={};for n,p in ipairs(players) do table.insert(names,string.format('%02d  %s',n,p.name)) end;refs.lobbyPlayers.Text=table.concat(names,'\n')
 end
 if refs.roomInfo then
  refs.roomInfo.Text='2–6 кухарів · 90 секунд.\nОдин рецепт. Чесний реванш.'
  refs.join.Text=room.member and 'Покинути кімнату' or (room.queued and 'Вийти з черги' or 'ДО ЗМАГАННЯ →')
 end
 if refs.steps and d.shift then refs.steps.Text='ЗМІНА '..d.shift.stage..'/3   •   СЕРІЯ ×'..tostring(d.shift.combo or 0)..'   •   '..tostring(d.contract and d.contract.name or '') end
 if refs.runInfo then
  if d.shift then refs.runInfo.Text='Сума: '..math.floor((d.shift.score or 0)+.5)..'/300\n'..(3-d.shift.stage)..' замовлень після цього'
  elseif d.mode=='daily' then refs.runInfo.Text='Ті самі умови для всіх.\nПобий свій рекорд дня.'
  else local done=0;for _,p in ipairs(players) do if p.done then done+=1 end end;refs.runInfo.Text='Кухарів: '..#players..'  /  Подали: '..done end
 end
 if refs.rewardDetail then
  local r=d.result or {};local reward=r.reward or {}
  refs.rewardDetail.Text=reward.leveledUp and ('НОВИЙ РАНГ! '..(profile.title or '')..' · '..tostring(profile.unlockedRecipes or 6)..' рецептів у кар’єрі') or ((r.personalBest and 'НОВИЙ ОСОБИСТИЙ РЕКОРД!  ' or '')..'Серія ×'..tostring(reward.combo or 0)..'  ·  '..tostring(profile.xp or 0)..' XP загалом')
 end
 if refs.standings then
  local r=d.result or {}
  if d.mode=='competition' then
   local heading=room.phase=='finished' and 'РАУНД ЗАВЕРШЕНО / БЕЗ ПЕРЕМОЖЦЯ' or 'PIZZA BATTLE / ІНШІ КУХАРІ ЩЕ ГОТУЮТЬ'
   local lines={room.winner and ('ПЕРЕМОЖЕЦЬ: '..room.winner.name..' / '..math.floor(room.winner.total+.5)..' балів') or heading}
   for n,p in ipairs(players) do table.insert(lines,n..'. '..p.name..'   '..(p.done and tostring(math.floor((p.total or 0)+.5))..' балів' or 'готує…')) end
   refs.standings.Text=table.concat(lines,'\n')
  elseif d.shift then
   refs.standings.Text=(d.shift.finished and 'ЗМІНУ ЗАВЕРШЕНО' or 'ЗАМОВЛЕННЯ '..d.shift.stage..' / 3')..'   •   '..math.floor((d.shift.score or 0)+.5)..' / 300 БАЛІВ\n'..(d.shift.finished and 'Три різні виклики позаду. Наступна зміна — нові рецепти.' or 'Наступний контракт змінить умови. Готовий до складнішого?')..'\nТвій рекорд зміни: '..math.floor((profile.bestShift or 0)+.5)..' / 300'
  else
   refs.standings.Text=(d.mode=='daily' and 'ВИКЛИК ДНЯ · СПІЛЬНИЙ РЕЦЕПТ ДЛЯ ВСІХ' or 'МАЙСТЕРНІСТЬ РЕЦЕПТА')..'\n'..string.format('Попередній рекорд: %.0f  •  Різниця: %+.1f',r.previousBest or 0,r.delta or 0)..'\nДля 3★: рецепт ≥95%, піч ≥90%, оцінка ≥90.'
  end
 end
 if refs.again then
  local active=d.mode=='competition' and room.phase=='active'
  refs.again.Active=not active;refs.again.AutoButtonColor=not active
  refs.again.Text=active and 'Інші кухарі ще готують…' or (d.mode=='competition' and 'РЕВАНШ →' or (d.mode=='shift' and (d.shift and d.shift.finished and 'НОВА ЗМІНА →' or 'НАСТУПНЕ ЗАМОВЛЕННЯ →') or (d.mode=='daily' and 'ПОКРАЩИТИ РЕЗУЛЬТАТ →' or 'СПРОБУВАТИ ЩЕ →')))
 end
 if workspace:GetServerTimeNow()>localNoticeUntil then
  local message=d.message or ''
  if room.member and room.phase=='countdown' and message=='Очікуємо другого кухаря…' then message='' end
  if room.queued and room.phase=='finished' and message=='Ти в черзі на наступний раунд. Поточне змагання ще триває.' then message='Ти в черзі на реванш. Готуємо наступний раунд…' end
  toast.Text=message;toast.Visible=message~=''
 end
 status.Text=d.phase=='menu' and 'SECOND SERVING / ТВОЯ НОВА ЗМІНА' or ({competition='PIZZA BATTLE / ЗМАГАННЯ',shift='ЗМІНА ШЕФА / '..tostring(d.shift and d.shift.stage or 1)..' З 3',daily='ВИКЛИК ДНЯ / УСІМ ОДНАКОВІ УМОВИ',practice='ВІЛЬНА КУХНЯ / ТРЕНУВАННЯ'})[d.mode] or 'PIZZA CHIEF'
 if d.phase=='menu' then footer.Text=profile.persistence=='session' and 'PIZZA CHIEF / SECOND SERVING  •  У Studio прогрес діє лише в цій сесії' or (profile.persistence=='unavailable' and 'PIZZA CHIEF / SECOND SERVING  •  Збереження недоступне — прогрес цієї сесії тимчасовий' or 'PIZZA CHIEF / SECOND SERVING  •  Готуй. Рости. Дивуй.') end
end
State.OnClientEvent:Connect(update)
local ok,initial=pcall(function() return GetState:InvokeServer() end); if ok then update(initial) end
local lastHeat=0
UIS.InputEnded:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then draggingHeat=false; touchPosition=nil end end)
UIS.InputChanged:Connect(function(input) if input.UserInputType==Enum.UserInputType.Touch then touchPosition=input.Position end end)
RunService.RenderStepped:Connect(function()
 local cam=workspace.CurrentCamera; cam.CameraType=Enum.CameraType.Scriptable
 local target=data and data.phase~='menu' and CFrame.lookAt(Vector3.new(27,24,38),Vector3.new(0,4,-7)) or CFrame.lookAt(Vector3.new(38,29,43),Vector3.new(1,4,-4))
 cam.CFrame=cam.CFrame:Lerp(target,.035); cam.FieldOfView=55
 if data then
  if workspace:GetServerTimeNow()<localNoticeUntil then toast.Text=localNotice;toast.Visible=true end
  local now=workspace:GetServerTimeNow(); local room=data.room or {}
  clock.TextColor3=(data.deadline and data.deadline>0 and data.phase~='result' and data.phase~='menu' and data.deadline-now<=15) and C.orange or C.gold
  if room.phase=='countdown' and room.member then clock.Text='СТАРТ ЧЕРЕЗ '..math.max(0,math.ceil((room.startsAt or now)-now))..' с'
  elseif data.deadline and data.deadline>0 and data.phase~='result' and data.phase~='menu' then clock.Text='ЗАЛИШИЛОСЬ '..math.max(0,math.ceil(data.deadline-now))..' с'
  elseif data.phase=='bake' then clock.Text='У ПЕЧІ  '..math.floor(data.bakeElapsed or 0)..' / '..math.floor(data.bakeDuration or 22)..' с'
  elseif data.phase=='prep' and data.startedAt then clock.Text='ТВІЙ ЧАС  '..math.floor(now-data.startedAt)..' с'
  else clock.Text='BUON APPETITO!' end
  if data.phase=='bake' and now-lastHeat>.12 then
   local dir=(UIS:IsKeyDown(Enum.KeyCode.D) and 1 or 0)-(UIS:IsKeyDown(Enum.KeyCode.A) and 1 or 0)
   if draggingHeat and refs.powerTrack then local pos=touchPosition or UIS:GetMouseLocation(); lastHeat=now; send('Heat',math.clamp((pos.X-refs.powerTrack.AbsolutePosition.X)/refs.powerTrack.AbsoluteSize.X,0,1)) elseif dir~=0 then lastHeat=now; send('Heat',math.clamp((data.heat or .5)+dir*.025,0,1)) end
  end
 end
end)
-- The kitchen is controlled through accessible UI; avatars remain safely in the dining area.
task.spawn(function()
 local module=player:WaitForChild('PlayerScripts'):WaitForChild('PlayerModule',10)
 if module then local ok,control=pcall(require,module); if ok then control:GetControls():Disable() end end
end)
local function characterAdded(char)
 local hum=char:WaitForChild('Humanoid'); hum.WalkSpeed=0; hum.JumpPower=0
end
player.CharacterAdded:Connect(characterAdded); if player.Character then task.spawn(characterAdded,player.Character) end
