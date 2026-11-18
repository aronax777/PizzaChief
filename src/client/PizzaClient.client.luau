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
local Cooking = require(package:WaitForChild('Cooking'))
local Tutorial = require(package:WaitForChild('Tutorial'))
local Challenges = require(package:WaitForChild('Challenges'))
local ChallengeUI = require(package:WaitForChild('ChallengeUI'))
local MobileLayout = require(package:WaitForChild('MobileLayout'))
local Art = require(package:WaitForChild('IngredientArt'))
local L = require(package:WaitForChild('Localization'))
local automaticLocale = game:GetService('LocalizationService').RobloxLocaleId
local requestedLocale = player:GetAttribute('PizzaChiefLocale')
local locale = L.Normalize(requestedLocale=='auto' and automaticLocale or requestedLocale or automaticLocale)
local function T(key,params) return L.Text(locale,key,params) end
local SocialService=game:GetService('SocialService')
local Action, State, GetState = package:WaitForChild('Action'), package:WaitForChild('State'), package:WaitForChild('GetState')
local C = {ink=Color3.fromRGB(44,48,40), cream=Color3.fromRGB(255,248,230), paper=Color3.fromRGB(255,253,245), green=Color3.fromRGB(42,91,66), sage=Color3.fromRGB(200,216,169), orange=Color3.fromRGB(225,100,54), gold=Color3.fromRGB(245,186,77), muted=Color3.fromRGB(118,121,101), red=Color3.fromRGB(194,62,44)}
local gui=Instance.new('ScreenGui'); gui.Name='PizzaChiefUI'; gui.IgnoreGuiInset=false; gui.ScreenInsets=Enum.ScreenInsets.CoreUISafeInsets; gui.ClipToDeviceSafeArea=true; gui.ResetOnSpawn=false; gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; gui.Parent=player:WaitForChild('PlayerGui')
local backdrop=Instance.new('Frame');backdrop.Name='KitchenShade';backdrop.Size=UDim2.fromScale(1,1);backdrop.BackgroundColor3=Color3.fromRGB(23,35,29);backdrop.BackgroundTransparency=.42;backdrop.BorderSizePixel=0;backdrop.Parent=gui
local root=Instance.new('Frame'); root.Name='Canvas'; root.Size=UDim2.fromOffset(1440,900); root.AnchorPoint=Vector2.new(.5,.5); root.Position=UDim2.fromScale(.5,.5); root.BackgroundTransparency=1; root.Parent=gui
local scale=Instance.new('UIScale'); scale.Parent=root
local mobile=false
local refreshViewport
local function resize()
 local v=gui.AbsoluteSize
 if v.X<1 or v.Y<1 then v=workspace.CurrentCamera.ViewportSize end
 mobile=v.X<1000 or v.Y<600
 root.Size=mobile and UDim2.fromOffset(v.X,v.Y) or UDim2.fromOffset(1440,900)
 scale.Scale=mobile and 1 or math.min(v.X/1440,v.Y/900)
 if refreshViewport then refreshViewport() end
end
resize(); gui:GetPropertyChangedSignal('AbsoluteSize'):Connect(resize)
local function styleText(o)
 local rtl=L.IsRTL(locale)
 o.TextDirection=(rtl and o.Text:find('[\216-\219][\128-\191]')) and Enum.TextDirection.RightToLeft or Enum.TextDirection.Auto
 if not o:GetAttribute('KeepAlignment') and o.TextXAlignment~=Enum.TextXAlignment.Center then
  o.TextXAlignment=rtl and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left
 end
 local baseFont=o:GetAttribute('BaseFont')
 if baseFont then o.Font=(not o:GetAttribute('KeepFont') and (locale=='ar' or locale=='hi' or locale=='th')) and Enum.Font.Arial or Enum.Font[baseFont] end
end
local function make(class,parent,props)
 local o=Instance.new(class); for k,v in pairs(props or {}) do o[k]=v end
 if o:IsA('TextLabel') or o:IsA('TextButton') then
  o.AutoLocalize=false -- Our offline catalog owns all game text and manual overrides.
  o.RichText=false; o.TextWrapped=true; o.TextScaled=true
  local limit=Instance.new('UITextSizeConstraint');limit.MinTextSize=math.min(10,o.TextSize);limit.MaxTextSize=o.TextSize;limit.Parent=o
  o:SetAttribute('BaseFont',o.Font.Name)
  styleText(o)
  o:GetPropertyChangedSignal('Text'):Connect(function() styleText(o) end)
 end
 o.Parent=parent; return o
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
local brand=label(header,'Brand','PIZZA CHIEF',24,10,280,34,30,C.cream,Enum.Font.GothamBlack)
brand:SetAttribute('KeepAlignment',true);brand.TextXAlignment=Enum.TextXAlignment.Left
brand:SetAttribute('KeepFont',true);brand.Font=Enum.Font.GothamBlack
local tagline=label(header,'Tagline',T('tagline'),25,45,320,20,11,C.sage)
local status=label(header,'Status',T('header'),465,20,510,36,17,C.cream); status.TextXAlignment=Enum.TextXAlignment.Center
local clock=label(header,'Clock','BUON APPETITO!',1100,20,252,36,19,C.gold,Enum.Font.GothamBold); clock.TextXAlignment=Enum.TextXAlignment.Right;clock:SetAttribute('KeepAlignment',true)
local page=make('ScrollingFrame',root,{CanvasSize=UDim2.new(),ScrollBarThickness=0,ScrollingEnabled=false,BorderSizePixel=0,Name='Page',Position=UDim2.fromOffset(0,112),Size=UDim2.fromOffset(1440,740),BackgroundTransparency=1})
local footer=label(root,'Footer',T('footer'),35,865,1000,20,12,C.cream)
local toast=label(root,'Toast','',430,817,580,44,16,C.cream); toast.TextXAlignment=Enum.TextXAlignment.Center; toast.BackgroundColor3=C.green; toast.BackgroundTransparency=.08; toast.Visible=false; toast.ZIndex=30; round(toast,12)
local data=nil
local refs={}
local signature=''
local chosen=Recipes.List[1].id
local modal=nil
local challengeController
local seenChallenge
local openChallenge
local function layoutModal() if mobile and modal then MobileLayout.Modal(modal,root.Size.X.Offset,root.Size.Y.Offset) end end
local draggingHeat=false
local touchPosition=nil
local heatTouch=nil
local localNoticeUntil=0
local localNotice=''
local languageButton
local inviteBusy=false
local function notify(message) toast.ZIndex=60;localNotice=message;localNoticeUntil=workspace:GetServerTimeNow()+5 end
local function inviteFriends(challengeId,targetId)
 if type(challengeId)~='string' then challengeId=nil;targetId=nil end
 if inviteBusy then return end
 if game.PlaceId==0 or RunService:IsStudio() then notify(T('invite.studio'));return end
 inviteBusy=true
 task.spawn(function()
  local ok,allowed=pcall(function() return SocialService:CanSendGameInviteAsync(player) end)
  if ok and allowed then local sent=pcall(function() local options
   if challengeId then
    options=Instance.new('ExperienceInviteOptions');options.LaunchData=Challenges.LaunchData(challengeId)
    options.PromptMessage=T('challenge.invite_prompt')
    if targetId and targetId>0 then options.InviteUser=targetId end
   end
   SocialService:PromptGameInvite(player,options) end);if not sent then notify(T('invite.failed')) end else notify(T('invite.unavailable')) end
  inviteBusy=false
 end)
end
local function stars(n) n=math.clamp(math.floor(n or 0),0,3);return string.rep('★',n)..string.rep('☆',3-n) end
local ingredientById={}; for _,i in ipairs(Recipes.Ingredients) do ingredientById[i.id]=i end
local function rgb(v) if typeof(v)=='Color3' then return v end; return Color3.fromRGB(v[1] or 200,v[2] or 120,v[3] or 70) end
local function pizza(parent,x,y,w,h,ingredients,baked,turned)
 local vp=make('ViewportFrame',parent,{Name='PizzaPreview',Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(w,h),BackgroundTransparency=1,Ambient=Color3.fromRGB(190,180,150),LightColor=Color3.fromRGB(255,245,212),LightDirection=Vector3.new(-1,-3,-2)})
 local cam=Instance.new('Camera'); cam.CFrame=CFrame.lookAt(Vector3.new(0,8.2,5.2),Vector3.new(0,0,0)); cam.FieldOfView=36; cam.Parent=vp; vp.CurrentCamera=cam
 local world=Instance.new('WorldModel'); world.Name='PizzaWorld'; world.Parent=vp
 local food=Instance.new('Model'); food.Name='Pizza'; food.Parent=world
 food.WorldPivot=CFrame.new(0,.2,0)
 local function part(name,size,cf,color,shape)
  local p=Instance.new('Part'); p.Name=name; p.Size=size; p.CFrame=cf; p.Color=color; p.Anchored=true; p.Material=Enum.Material.SmoothPlastic; p.Shape=shape or Enum.PartType.Block; p.Parent=name=='Ceramic plate' and world or food; return p
 end
 local function disc(name,r,y,t,c) return part(name,Vector3.new(t,r*2,r*2),CFrame.new(0,y,0)*CFrame.Angles(0,0,math.pi/2),c,Enum.PartType.Cylinder) end
 disc('Ceramic plate',3.4,-.3,.16,C.cream); disc('Golden crust',2.94,0,.35,baked and Color3.fromRGB(190,113,42) or Color3.fromRGB(235,190,116))
 disc('Soft dough',2.65,.19,.05,Color3.fromRGB(251,223,151))
 if ingredients.tomato then disc('San Marzano',2.61,.23,.06,C.red) elseif ingredients.bbq then disc('Smoky BBQ',2.61,.23,.06,Color3.fromRGB(111,51,31)) elseif ingredients.pesto then disc('Fresh pesto',2.61,.23,.06,Color3.fromRGB(82,123,51)) end
 if ingredients.mozzarella then
  disc('Melted mozzarella',2.4,.27,.06,Color3.fromRGB(255,225,142))
  for j=1,ingredients.mozzarella*7 do local a=j*2.399;local r=.4+(j%7)*.28
   part('Mozzarella pearl',Vector3.new(.55,.09,.46),CFrame.new(math.cos(a)*r,.33,math.sin(a)*r),Color3.fromRGB(255,244,192),Enum.PartType.Ball)
  end
 end
 local n=0
 for _,ing in ipairs(Recipes.Ingredients) do local count=ingredients[ing.id] or 0
  if count>0 and ing.id~='tomato' and ing.id~='tomato_sauce' and ing.id~='mozzarella' and ing.id~='bbq' and ing.id~='pesto' then
   n+=1
   for j=1,math.min(12,count*5) do local a=j*2.399+n*.8; local r=.6+((j*7+n*3)%17)/10; local px,pz=math.cos(a)*r,math.sin(a)*r; local col=rgb(ing.color)
    if ing.id=='basil' or ing.id=='rocket' or ing.id=='oregano' then part(ing.id,Vector3.new(.3,.06,.65),CFrame.new(px,.4+n*.016,pz)*CFrame.Angles(0,a,0),col,Enum.PartType.Ball)
    elseif ing.id=='pepperoni' or ing.id=='sausage' then
     part(ing.id,Vector3.new(.07,.66,.66),CFrame.new(px,.38+n*.016,pz)*CFrame.Angles(0,0,math.pi/2),col,Enum.PartType.Cylinder)
     for f=1,3 do local fa=f*2.1;part('Salami marbling',Vector3.new(.08,.018,.06),CFrame.new(px+math.cos(fa)*.16,.43+n*.016,pz+math.sin(fa)*.16),Color3.fromRGB(255,202,150),Enum.PartType.Ball) end
    elseif ing.id=='mushroom' then
     part('Mushroom stem',Vector3.new(.13,.07,.31),CFrame.new(px,.4+n*.016,pz+.16)*CFrame.Angles(0,a,0),Color3.fromRGB(239,216,173))
     part('Mushroom cap',Vector3.new(.48,.14,.3),CFrame.new(px,.43+n*.016,pz),col,Enum.PartType.Ball)
    elseif ing.id=='onion' or ing.id=='olive' or ing.id=='pepper' then
     local radius=ing.id=='onion' and .27 or .17
     for k=1,10 do local angle=k*math.pi/5;part(ing.id,Vector3.new(.13,.07,.09),CFrame.new(px+math.cos(angle)*radius,.41+n*.016,pz+math.sin(angle)*radius)*CFrame.Angles(0,-angle,0),col,Enum.PartType.Ball) end
    elseif ing.id=='egg' then
     part('Egg white',Vector3.new(.72,.07,.65),CFrame.new(px,.42,pz),Color3.fromRGB(255,250,222),Enum.PartType.Ball)
     part('Golden yolk',Vector3.new(.33,.14,.33),CFrame.new(px,.48,pz),C.gold,Enum.PartType.Ball)
    elseif ing.id=='ham' or ing.id=='bacon' or ing.id=='parmesan' then
     part(ing.id,Vector3.new(.23,.055,.55),CFrame.new(px,.41+n*.016,pz)*CFrame.Angles(0,a,0),col)
    elseif ing.id=='olive_oil' then
     part('Olive oil glisten',Vector3.new(.12,.025,.23),CFrame.new(px,.49,pz)*CFrame.Angles(0,a,0),col,Enum.PartType.Ball)
    else part(ing.id,Vector3.new(.36,.14,.38),CFrame.new(px,.38+n*.016,pz)*CFrame.Angles(0,a,0),col,Enum.PartType.Ball) end
   end
  end
 end
 for j=1,24 do local a=j*math.pi/12; part('Crust blister',Vector3.new(.1,.2,.23),CFrame.new(math.cos(a)*2.8,.2,math.sin(a)*2.8),Color3.fromRGB(181,113,53),Enum.PartType.Ball) end
 if turned then food:PivotTo(food:GetPivot()*CFrame.Angles(0,math.pi,0)) end
 return vp
end
local function turnPizza(view)
 -- Turn the pizza on the oven surface: a half-turn in its horizontal plane.
 -- Height and upward-facing toppings remain unchanged throughout the motion.
 local food=view.PizzaWorld.Pizza
 local origin=food:GetPivot()
 local progress=Instance.new('NumberValue');progress.Name='TurnProgress';progress.Parent=view
 local changed=progress.Changed:Connect(function(value)
  if food.Parent then food:PivotTo(origin*CFrame.Angles(0,value*math.pi,0)) end
 end)
 local tween=TweenService:Create(progress,TweenInfo.new(.7,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Value=1})
 tween.Completed:Once(function()
  changed:Disconnect()
  if food.Parent then food:PivotTo(origin*CFrame.Angles(0,math.pi,0)) end
  progress:Destroy()
 end)
 tween:Play()
end
local function recipeLines(recipe)
 local lines={}; for _,i in ipairs(Recipes.Ingredients) do local n=recipe.ingredients[i.id]; if n then table.insert(lines,T(i.name)..'  ×'..n) end end; return table.concat(lines,'\n')
end
local function openRecipes()
 if modal then modal:Destroy() end
 modal=make('Frame',root,{Name='RecipeOverlay',Size=UDim2.fromScale(1,1),BackgroundColor3=C.ink,BackgroundTransparency=.35,BorderSizePixel=0,Active=true,ZIndex=20})
 local book=panel(modal,'RecipeBook',155,123,1130,700,C.cream)
 label(book,'Title',T('book.title'),30,18,850,40,30,C.green,Enum.Font.GothamBlack)
 label(book,'Subtitle',T('book.subtitle'),30,62,920,26,16,C.muted)
 button(book,'Close','×',1040,20,60,50,C.green,function() modal:Destroy(); modal=nil end)
 local scroll=make('ScrollingFrame',book,{Name='RecipeList',Position=UDim2.fromOffset(25,105),Size=UDim2.fromOffset(1080,570),CanvasSize=UDim2.fromOffset(0,math.ceil(#Recipes.List/3)*166),ScrollBarThickness=5,BackgroundTransparency=1,BorderSizePixel=0})
 for index,r in ipairs(Recipes.List) do
  local x=((index-1)%3)*358; local y=math.floor((index-1)/3)*166
  local card=panel(scroll,r.id,x,y,344,152,C.paper)
  label(card,'Name',r.name,16,10,310,28,20,C.green,Enum.Font.GothamBold)
  label(card,'Recipe',T(r.description),16,43,310,38,13,C.muted)
  local best=data and data.profile and data.profile.recipeBest and data.profile.recipeBest[r.id] or {}
  label(card,'Mastery',stars(best.stars)..'  '..(best.score and math.floor(best.score+.5)..'/100' or '—')..(index>(data and data.profile and data.profile.unlockedRecipes or 6) and T('book.practice_only') or T('book.career')),16,81,310,22,13,C.orange,Enum.Font.GothamBold)
  card.LayoutOrder=index
  button(card,'Choose',T('book.choose'),16,110,310,30,C.green,function() chosen=r.id; modal:Destroy(); modal=nil; send('StartPractice',chosen) end)
 end
 layoutModal()
end
local function progress(parent,name,x,y,w,value,color)
 local track=panel(parent,name,x,y,w,10,Color3.fromRGB(225,225,207)); round(track,5)
 local fill=panel(track,'Fill',0,0,math.max(1,w*value),10,color or C.green); round(fill,5); return fill
end
local function buildMenu()
 local p=panel(page,'Welcome',35,15,620,661,C.cream)
 label(p,'Eyebrow',T('menu.eyebrow'),30,26,560,24,14,C.orange,Enum.Font.GothamBold)
 label(p,'Hero',T('menu.hero'),30,62,560,138,57,C.green,Enum.Font.GothamBlack)
 label(p,'Intro',T('menu.intro'),32,212,555,64,22,C.ink)
 local shift=panel(p,'ShiftCard',25,299,570,195,C.green)
 label(shift,'Title',T('menu.shift'),20,15,530,30,22,C.cream,Enum.Font.GothamBold)
 label(shift,'Body',T('menu.shift_body'),20,53,530,55,17,C.sage)
 refs.shiftBest=label(shift,'Best',T('menu.shift_best'),20,112,525,23,14,C.gold)
 refs.menuStart=button(shift,'Start',T('menu.start'),20,146,530,36,C.orange,function() send('StartShift') end)
 refs.menuHero=p.Hero;refs.menuIntro=p.Intro;refs.menuShiftTitle=shift.Title;refs.menuShiftBody=shift.Body
 refs.tutorialHelp=button(p,'TutorialHelp','',25,508,570,44,C.green,function() send(Tutorial.NeedsIntroduction(data.profile or {}) and 'SkipTutorial' or 'StartTutorial') end)

 button(p,'Practice',T('menu.practice'),25,568,272,52,C.green,function() send('StartPractice',chosen) end)
 button(p,'Book',T('menu.book'),312,568,283,52,C.orange,openRecipes)
 local profile=panel(page,'Career',685,15,720,205,C.cream)
 refs.rank=label(profile,'Rank',T('menu.rank'),24,18,670,38,29,C.green,Enum.Font.GothamBlack)
 refs.xp=label(profile,'XP','0 XP',24,63,670,27,17,C.muted)
 refs.xpFill=progress(profile,'Progress',24,107,672,0,C.orange)
 refs.profileDetails=label(profile,'Details','',24,132,672,54,16,C.green)
 local daily=panel(page,'DailyCard',685,242,346,255,C.cream)
 label(daily,'Label',T('menu.daily'),21,16,303,27,17,C.orange,Enum.Font.GothamBold)
 refs.dailyName=label(daily,'Name',T('menu.special'),21,54,303,57,26,C.green,Enum.Font.GothamBlack)
 refs.dailyText=label(daily,'Description',T('menu.daily_body'),21,118,303,62,16,C.muted)
 button(daily,'Start',T('menu.accept'),21,197,303,40,C.green,function() send('StartDaily') end)
 local battle=panel(page,'CompetitionCard',1051,242,354,255,C.green)
 label(battle,'Label','03 / PIZZA BATTLE',20,16,314,27,18,C.gold,Enum.Font.GothamBold)
 label(battle,'Title',T('menu.battle_title'),20,55,314,57,28,C.cream,Enum.Font.GothamBlack)
 refs.roomInfo=label(battle,'Body',T('menu.battle_body'),20,119,314,60,16,C.sage)
 refs.join=button(battle,'Join',T('menu.join'),20,197,314,40,C.orange,function() if data and data.room and (data.room.member or data.room.queued) then send('LeaveRoom') else send('JoinRoom') end end)
 if mobile then refs.persistence=label(page,'Persistence','',12,1410,root.Size.X.Offset-24,64,14,C.cream) end
 button(page,'ChallengeEntry',T('challenge.title'),685,688,720,44,C.orange,function()openChallenge(data.pendingChallenge and 'incoming' or 'lookup')end)
 local badge=panel(page,'Collection',685,519,720,157,C.green)
 refs.collection=label(badge,'Count',T('menu.stars'),23,15,674,32,21,C.gold,Enum.Font.GothamBold)
 refs.badges=label(badge,'Badges',T('menu.next_goal'),23,54,674,40,16,C.cream)
 button(badge,'Passport',T('menu.collection'),23,106,330,34,C.orange,openRecipes)
 button(badge,'Invite',T('invite'),368,106,330,34,C.orange,inviteFriends)
 refs.lobby=panel(page,'Lobby',685,242,720,434,C.cream); refs.lobby.Visible=false
 label(refs.lobby,'Heading',T('lobby'),25,18,670,35,25,C.green,Enum.Font.GothamBlack)
 refs.lobbyStatus=label(refs.lobby,'Status','',25,66,670,36,18,C.orange,Enum.Font.GothamBold)
 refs.lobbyPlayers=label(refs.lobby,'Players','',25,115,670,215,22,C.green)
 button(refs.lobby,'Invite',T('invite'),25,358,325,46,C.orange,inviteFriends)
 button(refs.lobby,'Leave',T('leave'),370,358,325,46,C.green,function() send('LeaveRoom') end)
end
local function buildKitchen()
 local recipe=Recipes.ById[data.recipeId] or Recipes.List[1]
 refs.hotkeys={};for _,i in ipairs(Recipes.Ingredients) do if recipe.ingredients[i.id] then table.insert(refs.hotkeys,i.id) end end
 local p=panel(page,'Pantry',30,10,350,700,C.cream)
 label(p,'Title',T('pantry'),20,15,310,30,21,C.green,Enum.Font.GothamBlack)
 local pantryAll=false;local pantryPage=1
 local list=make('Frame',p,{Name='Ingredients',Position=UDim2.fromOffset(15,106),Size=UDim2.fromOffset(320,536),BackgroundTransparency=1})
 refs.counts={};refs.ingredientCards={};refs.portionLabels={}
 local function drawPantry()
  list:ClearAllChildren();refs.counts={};refs.ingredientCards={};refs.portionLabels={}
  local items={}
  for _,i in ipairs(Recipes.Ingredients) do if pantryAll or recipe.ingredients[i.id] then table.insert(items,i) end end
  local pageSize=mobile and 4 or 8
  local pages=math.max(1,math.ceil(#items/pageSize));pantryPage=math.clamp(pantryPage,1,pages)
  for slot=1,pageSize do
   local i=items[(pantryPage-1)*pageSize+slot];if not i then break end
   local row=panel(list,i.id,((slot-1)%2)*164,math.floor((slot-1)/2)*134,154,126,C.paper)
   row.LayoutOrder=slot
   refs.ingredientCards[i.id]=row
   Art.Draw(row,i.id,37,-7,80)
   local key=table.find(refs.hotkeys,i.id)
   label(row,'Key',key and tostring(key) or '',9,5,25,21,12,C.muted,Enum.Font.GothamBold)
   local n=(data.ingredients or {})[i.id] or 0;local wanted=recipe.ingredients[i.id] or 0
   refs.portionLabels[i.id]=label(row,'Target',wanted>0 and (T('need',{count=wanted})) or T('optional'),43,62,108,15,9,C.muted)
   label(row,'Name',T(i.name),7,76,140,20,12,C.ink,Enum.Font.GothamBold).TextXAlignment=Enum.TextXAlignment.Center
   local hit=button(row,'Pick','',0,0,154,95,C.green,function() if data.phase=='prep' then send('Add',i.id) end end);hit.BackgroundTransparency=1
   local remove=button(row,'Remove','−',8,98,32,24,C.muted,function() if data.phase=='prep' then send('Remove',i.id) end end)
   refs.counts[i.id]=label(row,'Count',n..' / '..wanted,44,98,65,24,14,C.green,Enum.Font.GothamBold);refs.counts[i.id].TextXAlignment=Enum.TextXAlignment.Center
   local add=button(row,'Add','+',114,98,32,24,C.green,function() if data.phase=='prep' then send('Add',i.id) end end)
   if data.phase~='prep' then for _,b in ipairs({hit,remove,add}) do b.Active=false;b.AutoButtonColor=false end end
  end
  refs.pantryPage.Text=pantryPage..' / '..pages
  if mobile then MobileLayout.Pantry(p,p.Size.X.Offset) end
  if refs.refreshTutorial then refs.refreshTutorial() end
 end
 button(p,'Recommended',T('recommended'),15,57,156,35,C.green,function() pantryAll=false;pantryPage=1;drawPantry() end)
 button(p,'All',T('all'),179,57,156,35,C.orange,function() pantryAll=true;pantryPage=1;drawPantry() end)
 button(p,'Previous','←',15,655,38,30,C.green,function() pantryPage-=1;drawPantry() end)
 refs.pantryPage=label(p,'Page','1 / 1',59,655,49,30,12,C.muted)
 button(p,'Next','→',108,655,38,30,C.green,function() pantryPage+=1;drawPantry() end)
 button(p,'Clear',T('clear'),161,655,174,30,C.orange,function() if data.phase=='prep' then send('Clear') end end)
 drawPantry()
 local ticket=panel(page,'OrderTicket',1055,10,355,493,C.paper)
 label(ticket,'Eyebrow',data.contract and T(data.contract.name) or T('order'),20,17,315,23,12,C.orange,Enum.Font.GothamBold)
 label(ticket,'RecipeName',recipe.name,20,50,315,66,28,C.green,Enum.Font.GothamBlack)
 label(ticket,'Description',T(recipe.description),20,121,315,48,14,C.muted)
 refs.checklistTitle=label(ticket,'ChecklistTitle',T('assemble'),20,185,315,24,13,C.green,Enum.Font.GothamBold)
 refs.checklist={}
 for n,id in ipairs(refs.hotkeys) do
  local i=ingredientById[id];local y=218+(n-1)*31
  Art.Draw(ticket,id,18,y-3,29)
  refs.checklist[id]=label(ticket,id,T(i.name),53,y,280,27,15,C.ink)
 end
 label(ticket,'OvenInfo',T('oven.info',{temperature=recipe.temperature,seconds=recipe.bakeTime}),20,452,315,27,16,C.orange,Enum.Font.GothamBold)
 local steps=panel(page,'Steps',400,10,630,49,C.green)
 refs.steps=label(steps,'Text',T('steps'),15,8,600,32,15,C.cream,Enum.Font.GothamBold);refs.steps.TextXAlignment=Enum.TextXAlignment.Center
 local board=panel(page,'Workbench',400,263,630,447,C.cream)
 refs.boardLabel=label(board,'Label',data.phase=='prep' and T('pizza') or T('crust'),20,14,590,24,12,C.muted,Enum.Font.GothamBold)
 refs.pizzaHolder=make('Frame',board,{Name='PizzaHolder',Position=UDim2.fromOffset(10,38),Size=UDim2.fromOffset(610,292),BackgroundTransparency=1})
 refs.pizzaWidth=610;refs.pizzaHeight=292
 refs.pizzaView=pizza(refs.pizzaHolder,0,0,610,292,data.ingredients or {},data.phase~='prep',data.turned)
 if data.phase=='prep' then
  refs.match=label(board,'Match','',20,332,590,30,17,C.green,Enum.Font.GothamBold)
  refs.prepProgress=progress(board,'PrepProgress',20,371,590,0,C.green)
  refs.bakeButton=button(board,'Bake',T('bake'),369,392,241,40,C.orange,function() send('Bake') end)
  label(board,'Shortcuts',T('shortcuts'),20,392,340,40,13,C.muted)
 elseif data.phase=='bake' then
  refs.bakeHint=label(board,'BakeHint','',20,326,590,26,17,C.green,Enum.Font.GothamBold)
  refs.bakeProgress=progress(board,'BakeProgress',20,362,590,0,C.orange)
  local timing=panel(board,'TurnWindow',20,390,335,34,C.green)
  panel(timing,'Good',335*(Cooking.TurnCenter-Cooking.TurnWindow),0,335*Cooking.TurnWindow*2,34,C.sage)
  panel(timing,'Perfect',335*(Cooking.TurnCenter-Cooking.PerfectWindow),0,335*Cooking.PerfectWindow*2,34,C.gold)
  refs.turnNeedle=panel(timing,'Needle',0,-3,4,40,C.cream)
  refs.turnButton=button(board,'Turn',T('turn'),369,387,241,43,C.green,function() send('Turn') end)
 elseif data.phase=='ready' then
  label(board,'Ready',T('ready'),20,336,590,30,24,C.green,Enum.Font.GothamBold)
  label(board,'ServeHint',T('serve_hint'),20,390,340,40,15,C.muted)
  button(board,'Serve',T('serve'),369,388,241,44,C.orange,function() send('Serve') end)
 end
 if data.phase=='bake' then
  local oven=panel(page,'OvenControl',400,75,630,173,C.green)
  label(oven,'Title',T('oven'),20,10,420,23,13,C.sage,Enum.Font.GothamBold)
  refs.ovenQuality=label(oven,'Quality','',440,10,170,23,13,C.gold,Enum.Font.GothamBold)
  refs.temp=label(oven,'Temperature','',20,36,175,45,33,C.cream,Enum.Font.GothamBlack)
  refs.heat=label(oven,'Heat','',201,37,409,31,15,C.cream)
  refs.powerTrack=panel(oven,'PowerSlider',200,73,410,10,C.ink);refs.powerTrack.Active=true
  refs.powerKnob=panel(refs.powerTrack,'Knob',200,-5,20,20,C.gold)
  local function startDrag(input) if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then draggingHeat=true;heatTouch=input.UserInputType==Enum.UserInputType.Touch and input or nil;touchPosition=heatTouch and input.Position or nil end end
  refs.powerTrack.InputBegan:Connect(startDrag);refs.powerKnob.Active=true;refs.powerKnob.InputBegan:Connect(startDrag)
  local track=panel(oven,'TemperatureTrack',20,99,590,17,Color3.fromRGB(22,53,40))
  local band=data.contract and data.contract.temperatureBand or 25
  panel(track,'PerfectZone',math.clamp((recipe.temperature-band-250)/280,0,1)*590,0,band*2/280*590,17,C.sage)
  refs.needle=panel(track,'Needle',0,-4,5,25,C.gold)
  button(oven,'Cool',T('cool'),20,132,175,29,C.orange,function() send('Heat',math.clamp((data.heat or .5)-.08,0,1)) end)
  label(oven,'Keys',T('oven_hint'),208,132,220,29,11,C.sage)
  button(oven,'Hot',T('hot'),440,132,170,29,C.orange,function() send('Heat',math.clamp((data.heat or .5)+.08,0,1)) end)
 else
  local tip=panel(page,'Tip',400,75,630,173,C.green)
  label(tip,'ChefHint',data.phase=='ready' and T('chef.waiting') or T('chef.title'),20,15,590,25,13,C.gold,Enum.Font.GothamBold)
  refs.coach=label(tip,'Text','',20,51,590,67,22,C.cream,Enum.Font.GothamBold)
  label(tip,'Goal',data.activeChallenge and T('challenge.target',{score=string.format('%.1f',data.activeChallenge.score),name=L.Literal(data.activeChallenge.creatorName)}) or (data.contract and (T('goal',{score=data.contract.goal,xp=data.contract.bonusXP})) or T('practice_hint')),20,130,590,25,14,C.sage)
 end
 button(page,'Exit',data.mode=='tutorial' and T('tutorial.skip') or (data.mode=='competition' and T('battle.leave') or T('menu.back')),1055,521,355,44,C.green,function() send(data.mode=='tutorial' and 'SkipTutorial' or (data.mode=='competition' and 'LeaveRoom' or 'Menu')) end)
 if data.mode=='practice' then
  button(page,'ChangeRecipe',T('change_recipe'),1055,581,355,43,C.orange,openRecipes)
  label(page,'PracticeKeys',T('keys'),1065,639,335,55,14,C.cream)
 else
  local runPanel=panel(page,'RunSummary',1055,583,355,127,C.green)
  refs.runInfo=label(runPanel,'RunInfo','',20,15,315,92,17,C.cream,Enum.Font.GothamBold)
 end
end
openChallenge=function(kind)
 if modal then modal:Destroy() end
 modal,challengeController=ChallengeUI.Open({root=root,mobile=mobile,T=T,C=C,make=make,panel=panel,label=label,button=button,
  pizza=pizza,stars=stars,player=player,Recipes=Recipes,Challenges=Challenges,L=L,
  data=function()return data end,send=send,invite=inviteFriends,notify=notify,
  onOffer=function(id)seenChallenge=id end,
  close=function()modal=nil;challengeController=nil end},kind)
 if kind=='incoming' and data.pendingChallenge then seenChallenge=data.pendingChallenge.id end
end
local function openRecordCard() openChallenge('result') end
local function buildResult()
 local r=data.result or {};local reward=r.reward or {};local card=panel(page,'Verdict',265,10,910,685,C.cream)
 label(card,'Eyebrow',data.shift and data.shift.finished and T('result.shift') or T('result.verdict'),32,18,680,27,15,C.orange,Enum.Font.GothamBold)
 label(card,'Title',r.recipeName or T('result.pizza'),32,58,650,58,39,C.green,Enum.Font.GothamBlack)
 local score=label(card,'Score','0',709,42,175,94,70,C.green,Enum.Font.GothamBlack)
 local counter=make('NumberValue',card,{Value=0});counter.Changed:Connect(function(v) score.Text=tostring(math.floor(v+.5)) end);TweenService:Create(counter,TweenInfo.new(.65,Enum.EasingStyle.Quart),{Value=r.total or 0}):Play()
 label(card,'Stars',stars(reward.stars),34,119,400,37,28,C.orange,Enum.Font.GothamBold)
 label(card,'ScoreCaption',T('result.points'),711,136,175,22,13,C.muted)
 local quality=math.floor((r.quality or 0)+.5);local speed=math.floor((r.speed or 0)+.5)
 label(card,'Quality',T('quality',{value=quality}),38,174,395,30,21,C.green,Enum.Font.GothamBold)
 progress(card,'QualityBar',38,214,394,quality/100,C.green)
 label(card,'Speed',T('speed',{value=speed}),478,174,395,30,21,C.orange,Enum.Font.GothamBold)
 progress(card,'SpeedBar',478,214,394,speed/100,C.orange)
 label(card,'Detail',T('result.detail',{recipe=math.floor((r.recipeScore or 0)+.5),bake=math.floor((r.bakeScore or 0)+.5),seconds=string.format("%.1f",r.elapsed or 0),bonus=r.turnBonus or 0}),38,237,835,29,17,C.muted)
 local gains=panel(card,'Rewards',30,279,850,79,C.green)
 label(gains,'XP','+'..tostring(reward.xp or 0)..' XP  ·  '..T(reward.headline or '@retry'),17,10,818,29,22,C.gold,Enum.Font.GothamBold)
 refs.rewardDetail=label(gains,'Detail','',17,43,818,24,15,C.cream)
 local feedback=r.feedback and T(r.feedback)
 label(card,'Feedback',feedback or T('result.encourage'),38,370,835,49,19,C.ink)
 refs.standings=label(card,'Standings','',38,427,835,116,16,C.green)
 refs.again=button(card,'Again',T('next_order'),38,559,402,51,C.orange,function()
  if data.mode=='challenge' then send('RetryChallenge') elseif data.mode=='tutorial' then send('StartShift') elseif data.mode=='competition' then send('JoinRoom') elseif data.mode=='shift' then send(data.shift and data.shift.finished and 'StartShift' or 'NextOrder') elseif data.mode=='daily' then send('StartDaily') else send('StartPractice',data.recipeId) end
 end)
 button(card,'Menu',T('main_menu'),466,559,407,51,C.green,function() send(data.mode=='competition' and 'LeaveRoom' or 'Menu') end)
 button(card,'Record',T('challenge.card'),38,625,835,37,C.orange,openRecordCard)
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
 local previous=data
 data=d;if not d then return end
 local sig=tostring(d.phase)..':'..tostring(d.recipeId)..':'..tostring(d.mode)..':'..tostring(d.shift and d.shift.stage or 0)..':'..tostring(d.startedAt)
 if sig~=signature then
  if modal then modal:Destroy();modal=nil end
  signature=sig;draggingHeat=false;touchPosition=nil;page:ClearAllChildren();page.CanvasPosition=Vector2.zero;refs={}
  local dock=root:FindFirstChild('MobileDock');if dock then dock:Destroy() end
  if d.phase=='menu' or not d.phase then buildMenu() elseif d.phase=='result' then buildResult() else buildKitchen() end
  if mobile then MobileLayout.Apply(root,page,refs,d,T) end
 end
 local profile=d.profile or {};local recipe=Recipes.ById[d.recipeId]
 brand.Text=mobile and d.phase~='menu' and recipe and recipe.name or 'PIZZA CHIEF'
 local selected=d.ingredients or {}
 local check=recipe and Cooking.Checklist(recipe.ingredients,selected)
 if refs.counts then for id,l in pairs(refs.counts) do
  local n=selected[id] or 0;local wanted=recipe.ingredients[id] or 0
  l.Text=n..' / '..wanted;l.TextColor3=n>wanted and C.red or C.green
  local card=refs.ingredientCards[id]
  card.BackgroundColor3=n>wanted and Color3.fromRGB(255,223,207) or (wanted>0 and n==wanted and Color3.fromRGB(218,234,201) or C.paper)
  refs.portionLabels[id].Text=n>wanted and T('extra_portion') or (wanted>0 and n==wanted and T('done') or (wanted>0 and (T('need',{count=wanted})) or T('optional')))
 end end
 if refs.checklist then for id,l in pairs(refs.checklist) do
  local n=selected[id] or 0;local wanted=recipe.ingredients[id]
  l.Text=(n==wanted and '✓ ' or (n>wanted and '! ' or '· '))..T(ingredientById[id].name)..'   '..n..' / '..wanted
  l.TextColor3=n>wanted and C.red or (n==wanted and C.green or C.muted)
 end end
 if refs.checklistTitle then refs.checklistTitle.Text=check.ready and T('checklist.done') or (T('checklist',{count=check.complete,total=check.total})) end
 local ingSig='';for _,i in ipairs(Recipes.Ingredients) do ingSig..=tostring(selected[i.id] or 0)..',' end
 if refs.pizzaHolder and refs.ingSig~=ingSig then
  refs.ingSig=ingSig;refs.pizzaHolder:ClearAllChildren()
  refs.pizzaView=pizza(refs.pizzaHolder,0,0,refs.pizzaWidth,refs.pizzaHeight,selected,d.phase~='prep',d.turned)
 end
 if previous and previous.phase=='prep' and d.phase=='prep' and previous.recipeId==d.recipeId and previous.startedAt==d.startedAt then
  for id,n in pairs(selected) do if n>((previous.ingredients or {})[id] or 0) then
   local card=refs.ingredientCards[id]
   if card then
    local pos=(card.AbsolutePosition-root.AbsolutePosition)/scale.Scale
    local fly=Art.Draw(root,id,pos.X+45,pos.Y,64);fly.ZIndex=15
    for _,child in fly:GetDescendants() do if child:IsA('GuiObject') then child.ZIndex=15 end end
    local destination=(refs.pizzaHolder.AbsolutePosition+refs.pizzaHolder.AbsoluteSize/2-root.AbsolutePosition)/scale.Scale
    TweenService:Create(fly,TweenInfo.new(.38,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Position=UDim2.fromOffset(destination.X,destination.Y),Rotation=45,Size=UDim2.fromOffset(24,24)}):Play()
    task.delay(.4,function() fly:Destroy() end)
   end
  end end
 end
 if refs.match then
  refs.match.Text=check.ready and T('prep.ready') or (check.extra>0 and (T('extra',{count=check.extra})) or (T('portions',{count=check.placed,total=check.needed})))
  refs.match.TextColor3=check.extra>0 and C.red or C.green
  refs.prepProgress.Size=UDim2.fromScale(check.placed/math.max(1,check.needed),1)
  refs.bakeButton.Text=mobile and T('bake.short') or (check.ready and T('bake.space') or T('bake.short'))
 end
 if refs.coach then
  if d.phase=='ready' then refs.coach.Text=T(mobile and 'tutorial.serve' or 'coach.serve')
  elseif check.extra>0 then refs.coach.Text=T('coach.extra')
  elseif check.ready then refs.coach.Text=T(mobile and 'tutorial.bake' or 'coach.ready')
  else
   for _,id in ipairs(refs.hotkeys) do if (selected[id] or 0)<recipe.ingredients[id] then
    refs.coach.Text=T(mobile and 'tutorial.add' or 'coach.add',{ingredient=ingredientById[id].name,count=recipe.ingredients[id]-(selected[id] or 0),key=table.find(refs.hotkeys,id)});break
   end end
  end
 end
 if refs.powerKnob then refs.powerKnob.Position=UDim2.fromOffset((d.heat or .5)*(refs.powerTrack.Size.X.Offset-refs.powerKnob.Size.X.Offset),mobile and -8 or -5) end
 if refs.temp then
  refs.temp.Text=tostring(math.floor(d.temperature or 0))..'°C'
  refs.heat.Text=T('heat',{power=math.floor((d.heat or .5)*100),temperature=recipe.temperature})
  refs.needle.Position=UDim2.fromOffset(math.clamp(((d.temperature or 250)-250)/280,0,1)*(refs.needle.Parent.Size.X.Offset-5),-4)
  refs.ovenQuality.Text=T('quality',{value=math.floor(math.min(100,(d.bakeQuality or 0)+(d.turnBonus or 0)))})
  local dist=(d.temperature or 0)-recipe.temperature;local band=d.contract and d.contract.temperatureBand or 25
  refs.bakeHint.Text=math.abs(dist)<=band and T('heat.perfect') or (dist>0 and T('heat.high') or T('heat.low'))
  refs.bakeHint.TextColor3=math.abs(dist)<=band and C.green or C.orange
 end
 if refs.turnButton then
  if d.turned then
   refs.turnButton.Text=d.perfectTurn and T('turn.perfect_short') or T('turn.good_short');refs.turnButton.BackgroundColor3=C.green
   if previous and not previous.turned and refs.pizzaView then
    turnPizza(refs.pizzaView)
   end
  end
 end
 local room=d.room or {};local players=room.players or {}
 if refs.rank then
  local intro=Tutorial.NeedsIntroduction(profile)
  refs.menuStart.Text=T(intro and 'tutorial.start' or 'menu.start')
  refs.menuShiftTitle.Text=T(intro and 'tutorial.title' or 'menu.shift')
  refs.menuShiftBody.Text=T(intro and 'steps' or 'menu.shift_body')
  refs.menuHero.Text=T(intro and 'tutorial.title' or 'menu.hero')
  refs.menuIntro.Text=T(intro and 'tutorial.intro' or 'menu.intro')
  refs.tutorialHelp.Text=T(intro and 'tutorial.skip' or 'tutorial.replay')
  refs.rank.Text=T('rank',{level=profile.level or 1,title=profile.title or "@rank.1"})
  refs.xp.Text=T('xp',{xp=profile.xp or 0,next=profile.nextXP and T("xp.next",{xp=profile.nextXP}) or T("xp.max")})
  refs.xpFill.Size=UDim2.fromScale(profile.progress or 0,1)
  refs.profileDetails.Text=T('profile',{recipes=profile.unlockedRecipes or 6,pizzas=profile.completed or 0,wins=profile.battleWins or 0,combo=profile.bestCombo or 0})
  refs.shiftBest.Text=T('shift.best',{score=math.floor((profile.bestShift or 0)+.5)})
  refs.collection.Text=T('collection',{count=profile.totalStars or 0})
  local names={};for _,badge in ipairs(profile.badges or {}) do table.insert(names,T(badge.name)) end
  local shown={};for i=math.max(1,#names-2),#names do table.insert(shown,names[i]) end
  refs.badges.Text=#names>0 and (table.concat(shown,'  •  ')..(#names>3 and T('more',{count=#names-3}) or '')) or T('first_goal')
  local daily=d.daily or d.dailyChallenge or Rules.Daily(math.floor(os.time()/86400),Recipes)
  refs.dailyName.Text=Recipes.ById[daily.recipeId] and Recipes.ById[daily.recipeId].name or T(daily.name)
  local dailyDone=profile.lastDailyDay==math.floor((d.serverNow or os.time())/86400)
  refs.dailyText.Text=dailyDone and (T('daily.done',{score=math.floor((profile.dailyBest and profile.dailyBest.score or 0)+.5)})) or (T('daily.goal',{name=daily.name or "@daily",score=daily.goal or 85,xp=daily.bonusXP or 60}))
 end
 if refs.lobby then
  refs.lobby.Visible=room.member or room.queued or false
  refs.lobbyStatus.Text=room.queued and T('lobby.queued') or (room.phase=='countdown' and T('lobby.starting') or T('lobby.invite'))
  local names={};for n,p in ipairs(players) do table.insert(names,string.format('%02d  %s',n,p.name)) end;refs.lobbyPlayers.Text=table.concat(names,'\n')
 end
 if refs.roomInfo then
  refs.roomInfo.Text=T('menu.battle_body')
  refs.join.Text=room.member and T('lobby.leave') or (room.queued and T('lobby.unqueue') or T('menu.join'))
 end
 if refs.steps and d.shift then refs.steps.Text=T('shift.steps',{stage=d.shift.stage,combo=d.shift.combo or 0,name=d.contract and d.contract.name or ""}) end
 if refs.runInfo then
  if d.activeChallenge then refs.runInfo.Text=T('challenge.target',{score=string.format('%.1f',d.activeChallenge.score),name=L.Literal(d.activeChallenge.creatorName)})
  elseif d.shift then refs.runInfo.Text=T('shift.progress',{score=math.floor((d.shift.score or 0)+.5),count=3-d.shift.stage})
  elseif d.mode=='tutorial' then refs.runInfo.Text=T('tutorial.intro')
  elseif d.mode=='daily' then refs.runInfo.Text=T('daily.hint')
  else local done=0;for _,p in ipairs(players) do if p.done then done+=1 end end;refs.runInfo.Text=T('battle.progress',{count=#players,done=done}) end
 end
 if d.mode=='tutorial' and d.phase=='result' then
  local verdict=page:FindFirstChild('Verdict')
  if verdict then verdict.Rewards.XP.Text=T('tutorial.done');verdict.Rewards.Detail.Text='';verdict.Feedback.Text=T('tutorial.done_body') end
 end
 if refs.rewardDetail then
  local r=d.result or {};local reward=r.reward or {}
  refs.rewardDetail.Text=reward.leveledUp and (T('rank.up',{title=profile.title or "",count=profile.unlockedRecipes or 6})) or (T('reward.detail',{record=r.personalBest and "@reward.pb" or "",combo=reward.combo or 0,xp=profile.xp or 0}))
 end
 if refs.standings then
  local r=d.result or {}
  if r.challenge then refs.standings.Text=T(Challenges.OutcomeMessage[r.challenge.outcome],{name=L.Literal(r.challenge.creatorName),score=string.format('%.1f',r.challenge.score),target=string.format('%.1f',r.challenge.target)})
  elseif d.mode=='tutorial' then refs.standings.Text=''
  elseif d.mode=='competition' then
   local heading=room.phase=='finished' and T('battle.no_winner') or T('battle.cooking')
   local lines={room.winner and (T('winner',{name=L.Literal(room.winner.name),score=math.floor(room.winner.total+.5)})) or heading}
   for n,p in ipairs(players) do table.insert(lines,n..'. '..p.name..'   '..(p.done and T('points',{count=math.floor((p.total or 0)+.5)}) or T('cooking'))) end
   refs.standings.Text=table.concat(lines,'\n')
  elseif d.shift then
   refs.standings.Text=T('shift.result',{heading=d.shift.finished and T("shift.finished") or T("shift.order",{stage=d.shift.stage}),score=math.floor((d.shift.score or 0)+.5),hint=d.shift.finished and T("shift.finish_hint") or T("shift.next_hint"),best=math.floor((profile.bestShift or 0)+.5)})
  else
   refs.standings.Text=(d.mode=='daily' and T('daily.shared') or T('mastery'))..'\n'..T('previous',{best=math.floor((r.previousBest or 0)+.5),delta=string.format("%+.1f",r.delta or 0)})..T('three_stars')
  end
 end
 if refs.again then
  local active=d.mode=='competition' and room.phase=='active'
  refs.again.Active=not active;refs.again.AutoButtonColor=not active
  refs.again.Text=d.mode=='challenge' and T('challenge.retry') or d.mode=='tutorial' and T('tutorial.continue') or (active and T('battle.wait') or (d.mode=='competition' and T('battle.rematch') or (d.mode=='shift' and (d.shift and d.shift.finished and T('shift.new') or T('shift.next')) or (d.mode=='daily' and T('daily.retry') or T('again')))))
 end
 if d.mode=='tutorial' then
  local function guidance()
   local nextId,index=Tutorial.NextIngredient(d.ingredients or {},recipe.ingredients)
   if refs.steps then refs.steps.Text=T('tutorial.title') end
   if refs.coach then
    refs.coach.Text=d.phase=='ready' and T('tutorial.serve') or (nextId and T('tutorial.add',{ingredient=ingredientById[nextId].name,count=recipe.ingredients[nextId]-((d.ingredients or {})[nextId] or 0)}) or T('tutorial.bake'))
   end
   if refs.runInfo then refs.runInfo.Text=T('tutorial.intro') end
   if refs.bakeButton then refs.bakeButton.Active=check.ready;refs.bakeButton.AutoButtonColor=check.ready;refs.bakeButton.BackgroundColor3=check.ready and C.orange or C.muted end
   for id,card in pairs(refs.ingredientCards or {}) do
    local unlocked=table.find(Tutorial.Ingredients,id) and table.find(Tutorial.Ingredients,id)<=index
    card.Visible=unlocked==true
    if mobile then
     card.Visible=id==(nextId or Tutorial.Ingredients[#Tutorial.Ingredients])
     card.Position=UDim2.fromOffset((card.Parent.Size.X.Offset-card.Size.X.Offset)/2,0)
    end
    if card:FindFirstChild('Pick') then card.Pick.Active=id==nextId;card.Add.Active=id==nextId end
   end
   local pantry=page:FindFirstChild('Pantry')
   if pantry then
    pantry.All.Visible=false;pantry.Clear.Visible=false;pantry.Recommended.Active=false
    if mobile then
     pantry.Previous.Visible=false;pantry.Next.Visible=false;pantry.Page.Visible=false
     local compact=root.Size.X.Offset>=650 and root.Size.Y.Offset<500
     pantry.Size=UDim2.fromOffset(pantry.Size.X.Offset,compact and 164 or 272)
     page.CanvasSize=UDim2.fromOffset(0,pantry.Position.Y.Offset+(compact and 172 or 284))
    end
   end
   if refs.bakeHint then refs.bakeHint.Text=T(d.turned and 'tutorial.heat' or 'tutorial.turn') end
  end
  refs.refreshTutorial=guidance;guidance()
 end
 if workspace:GetServerTimeNow()>localNoticeUntil then
  local message=d.message or ''
  if room.member and room.phase=='countdown' and message=="@server.waiting" then message='' end
  if room.queued and room.phase=='finished' and message=="@server.queued" then message="@server.rematch" end
  toast.Text=T(message);toast.Visible=message~=''
 end
 status.Text=d.phase=='menu' and T('status.menu') or ({challenge=T('challenge.title'),tutorial=T('tutorial.title'),competition=T('status.battle'),shift=T('shift.status',{stage=d.shift and d.shift.stage or 1}),daily=T('status.daily'),practice=T('status.practice')})[d.mode] or 'PIZZA CHIEF'
 if refs.persistence then refs.persistence.Text=profile.persistence=='session' and T('footer.studio') or (profile.persistence=='unavailable' and T('footer.unsaved') or T('footer.normal')) end
 if challengeController then challengeController:Update(d) end
 if d.phase=='menu' and d.pendingChallenge and seenChallenge~=d.pendingChallenge.id and not modal then openChallenge('incoming') end
 footer.Text=profile.persistence=='session' and T('footer.studio') or (profile.persistence=='unavailable' and T('footer.unsaved') or T('footer.normal'))
end
local function openLanguages()
 if modal then modal:Destroy() end
 modal=make('Frame',root,{Name='LanguageOverlay',Size=UDim2.fromScale(1,1),BackgroundColor3=C.ink,BackgroundTransparency=.2,BorderSizePixel=0,Active=true,ZIndex=40})
 local card=panel(modal,'Languages',290,110,860,675,C.cream)
 label(card,'Title',T('language.title'),28,20,720,43,28,C.green,Enum.Font.GothamBold)
 button(card,'Close','×',765,17,65,48,C.green,function() modal:Destroy();modal=nil end)
 label(card,'Hint',T('language.note'),28,73,804,46,16,C.muted)
 local function choose(id)
  player:SetAttribute('PizzaChiefLocale',id)
  if modal then modal:Destroy();modal=nil end
 end
 button(card,'Automatic',T('language.auto'),28,135,804,42,C.green,function() choose('auto') end)
 for n,entry in ipairs(L.Locales) do
  local x=28+((n-1)%2)*410;local y=191+math.floor((n-1)/2)*50
  local selected=locale==entry.id
  local b=button(card,'Locale_'..entry.id,(selected and '✓  ' or '')..entry.name,x,y,394,42,selected and C.orange or C.green,function() choose(entry.id) end)
  b.TextDirection=Enum.TextDirection.Auto -- Autonyms always keep their own writing direction.
 end
 layoutModal()
end
languageButton=button(root,'Language',T('language')..' / '..locale,1125,855,280,36,C.green,openLanguages)
languageButton.ZIndex=10
refreshViewport=function()
 signature=''
 -- Restore desktop chrome after rotating/resizing out of a compact layout.
 if not mobile then
  header.Position=UDim2.fromOffset(30,26);header.Size=UDim2.fromOffset(1380,76)
  brand.Position=UDim2.fromOffset(24,10);brand.Size=UDim2.fromOffset(280,34)
  brand.TextSize=30;brand.UITextSizeConstraint.MaxTextSize=30
  tagline.Visible=true;status.Visible=true;footer.Visible=true
  clock.Position=UDim2.fromOffset(1100,20);clock.Size=UDim2.fromOffset(252,36)
  clock.TextSize=19;clock.UITextSizeConstraint.MaxTextSize=19
  languageButton.Position=UDim2.fromOffset(1125,855);languageButton.Size=UDim2.fromOffset(280,36)
  toast.Position=UDim2.fromOffset(430,817);toast.Size=UDim2.fromOffset(580,44)
  page.Position=UDim2.fromOffset(0,112);page.Size=UDim2.fromOffset(1440,740)
  page.CanvasSize=UDim2.new();page.ScrollingEnabled=false;page.ScrollBarThickness=0
 end
 if data then update(data) end
 gui:SetAttribute('CompactLayout',mobile)
end
-- World lettering is localized on this client only, including the captured Edit scene.
local function localizeWorldText(o)
 if not o:IsA('TextLabel') or not o.Parent or o.Parent.Name~='Lettering' then return end
 local sign=o.Parent.Parent
 if not sign then return end
 local key=({['House motto']='tagline',['House year']='world.year',['Open sign']='world.open'})[sign.Name]
 if key then o.Text=T(key)
 elseif sign.Name=='Chef nameplate' then o.Text=T('chef')..' LUCA / '..T('result.verdict')
 elseif sign.Name=='Station number' then
  local number=o:GetAttribute('StationNumber') or o.Text:match('^%d+') or ''
  o:SetAttribute('StationNumber',number);o.Text=T('world.station',{number=L.Literal(number)})
 elseif sign.Name=='Recipe board' then o.Text=T('world.specials')..'\n\nMARGHERITA\nDIAVOLA\nCARBONARA\n\n'..T('tagline')
 else return end
 o.AutoLocalize=false;o.RichText=false;o.TextWrapped=true;o.TextDirection=L.IsRTL(locale) and Enum.TextDirection.RightToLeft or Enum.TextDirection.Auto
end
workspace.DescendantAdded:Connect(function(o) if o:IsA('TextLabel') then task.defer(localizeWorldText,o) end end)
local function refreshWorld() for _,o in ipairs(workspace:GetDescendants()) do localizeWorldText(o) end end
refreshWorld()
local function refreshLocale()
 local requested=player:GetAttribute('PizzaChiefLocale')
 locale=L.Normalize(requested=='auto' and automaticLocale or requested or automaticLocale)
 signature='';localNoticeUntil=0;localNotice='';refreshWorld()
 -- Persistent header/footer are outside the rebuilt page.
 tagline.Text=T('tagline');footer.Text=T('footer.normal')
 languageButton.Text=T('language')..' / '..locale
 for _,o in ipairs(root:GetDescendants()) do
  if o:IsA('TextLabel') or o:IsA('TextButton') then styleText(o) end
 end
 if data then update(data) end
 gui:SetAttribute('ResolvedLocale',locale)
end
player:GetAttributeChangedSignal('PizzaChiefLocale'):Connect(refreshLocale)
game:GetService('LocalizationService'):GetPropertyChangedSignal('RobloxLocaleId'):Connect(function()
 automaticLocale=game:GetService('LocalizationService').RobloxLocaleId
 local requested=player:GetAttribute('PizzaChiefLocale')
 if requested==nil or requested=='auto' then refreshLocale() end
end)
gui:SetAttribute('ResolvedLocale',locale)
State.OnClientEvent:Connect(update)
local ok,initial=pcall(function() return GetState:InvokeServer() end); if ok then update(initial) end
UIS.InputBegan:Connect(function(input,processed)
 if processed or modal or UIS:GetFocusedTextBox() or not data then return end
 local keys={Enum.KeyCode.One,Enum.KeyCode.Two,Enum.KeyCode.Three,Enum.KeyCode.Four,Enum.KeyCode.Five,Enum.KeyCode.Six,Enum.KeyCode.Seven}
 local n=table.find(keys,input.KeyCode)
 if data.phase=='prep' and n and refs.hotkeys and refs.hotkeys[n] then
  send((UIS:IsKeyDown(Enum.KeyCode.LeftShift) or UIS:IsKeyDown(Enum.KeyCode.RightShift)) and 'Remove' or 'Add',refs.hotkeys[n])
 elseif input.KeyCode==Enum.KeyCode.Space then
  if data.phase=='prep' then send('Bake') elseif data.phase=='bake' then send('Turn') elseif data.phase=='ready' then send('Serve') end
 end
end)
local lastHeat=0
UIS.InputEnded:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 or input==heatTouch then draggingHeat=false; touchPosition=nil;heatTouch=nil end end)
UIS.InputChanged:Connect(function(input) if input==heatTouch then touchPosition=input.Position end end)
RunService.RenderStepped:Connect(function()
 local cam=workspace.CurrentCamera; cam.CameraType=Enum.CameraType.Scriptable
 local target=data and data.phase~='menu' and CFrame.lookAt(Vector3.new(27,24,38),Vector3.new(0,4,-7)) or CFrame.lookAt(Vector3.new(38,29,43),Vector3.new(1,4,-4))
 cam.CFrame=cam.CFrame:Lerp(target,.035); cam.FieldOfView=55
 if data then
  if workspace:GetServerTimeNow()<localNoticeUntil then toast.Text=localNotice;toast.Visible=true end
  local now=workspace:GetServerTimeNow(); local room=data.room or {}
  clock.TextColor3=(data.deadline and data.deadline>0 and data.phase~='result' and data.phase~='menu' and data.deadline-now<=15) and C.orange or C.gold
  if room.phase=='countdown' and room.member then clock.Text=T('clock.start',{seconds=math.max(0,math.ceil((room.startsAt or now)-now))})
  elseif data.deadline and data.deadline>0 and data.phase~='result' and data.phase~='menu' then clock.Text=T('clock.left',{seconds=math.max(0,math.ceil(data.deadline-now))})
  elseif data.phase=='bake' then clock.Text=T('clock.bake',{elapsed=math.floor(data.bakeElapsed or 0),seconds=math.floor(data.bakeDuration or 22)})
  elseif data.mode=='tutorial' then clock.Text=T('tutorial.title')
  elseif data.phase=='prep' and data.startedAt then clock.Text=T('clock.time',{seconds=math.floor(now-data.startedAt)})
  else clock.Text='BUON APPETITO!' end
  if data.phase=='bake' and refs.bakeProgress then
   local elapsed=math.min(data.bakeDuration,(data.bakeElapsed or 0)+math.clamp(now-(data.serverNow or now),0,.3))
   local ratio=elapsed/math.max(1,data.bakeDuration)
   refs.bakeProgress.Size=UDim2.fromScale(ratio,1)
   refs.turnNeedle.Position=UDim2.fromOffset((refs.turnTrackWidth or 331)*ratio,-3)
   if not data.turned then
    local window=math.abs(ratio-Cooking.TurnCenter)<=Cooking.TurnWindow
    refs.turnButton.Text=window and (mobile and T('turn.now'):gsub('%s*·%s*SPACE','') or T('turn.now')) or (ratio<.5 and T('turn.wait') or T('turn.missed'))
    refs.turnButton.BackgroundColor3=window and C.orange or C.muted
   end
  end
  if data.phase=='bake' and not modal and not UIS:GetFocusedTextBox() and now-lastHeat>.12 then
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
