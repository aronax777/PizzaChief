-- Reflow the same controls and callbacks, without shrinking desktop hit targets.
local Layout = {}
local function box(o,x,y,w,h)
 if not o then return end
 o.Position=UDim2.fromOffset(x,y);o.Size=UDim2.fromOffset(w,h)
end
local function child(p,n,x,y,w,h) box(p and p:FindFirstChild(n),x,y,w,h) end
local function hide(p,n) local o=p and p:FindFirstChild(n);if o then o.Visible=false end end
local function textSize(o,size)
 if not o then return end
 o.TextSize=size;local c=o:FindFirstChildOfClass('UITextSizeConstraint');if c then c.MinTextSize=12;c.MaxTextSize=size end
end
local function full(p,n,y,h,w) child(p,n,16,y,w-32,h) end

function Layout.Pantry(p,width)
 box(p.Ingredients,12,104,width-24,332)
 local cardWidth=(width-34)/2
 local cards={}
 for _,o in p.Ingredients:GetChildren() do if o:IsA('Frame') then table.insert(cards,o) end end
 table.sort(cards,function(a,b) return a.LayoutOrder<b.LayoutOrder end)
 for index,row in ipairs(cards) do
  box(row,((index-1)%2)*(cardWidth+10),math.floor((index-1)/2)*164,cardWidth,154)
  child(row,'Pick',0,0,cardWidth,104)
  child(row,'Name',4,76,cardWidth-8,26);textSize(row:FindFirstChild('Name'),14)
  child(row,'Target',42,59,cardWidth-46,18)
  child(row,'Remove',4,106,44,44)
  child(row,'Count',48,108,cardWidth-96,40)
  child(row,'Add',cardWidth-48,106,44,44)
 end
 full(p,'Title',10,30,width)
 child(p,'Recommended',12,48,(width-34)/2,44)
 child(p,'All',22+(width-34)/2,48,(width-34)/2,44)
 child(p,'Previous',12,442,44,44);child(p,'Page',60,442,50,44)
 child(p,'Next',112,442,44,44);child(p,'Clear',166,442,width-178,44)
 if p:GetAttribute('LandscapeCompact') then p.Ingredients.Position=UDim2.fromOffset(12,52) end
end

function Layout.Apply(root,page,refs,data,T)
 local w,h=root.Size.X.Offset,root.Size.Y.Offset
 local wide=w>=650
 local pad=12
 local header=root.Header
 box(header,pad,4,w-24,48)
 child(header,'Brand',12,6,math.min(190,w*.51),36);textSize(header.Brand,22)
 hide(header,'Tagline');hide(header,'Status')
 child(header,'Clock',w*.53-24,6,w*.47-12,36);textSize(header.Clock,15)
 root.Footer.Visible=false
 box(root.Language,w-162,h-48,150,44)
 box(root.Toast,12,h-164,w-24,48)
 box(page,0,60,w,h-116);page.ScrollingEnabled=true;page.ScrollBarThickness=3
 local old=root:FindFirstChild('MobileDock');if old then old:Destroy() end
 if data.phase=='menu' then
  local cw=math.min(w-24,520);local x=(w-cw)/2
  local welcome=page.Welcome;box(welcome,x,0,cw,452)
  hide(welcome,'Eyebrow');full(welcome,'Hero',12,68,cw);textSize(welcome.Hero,33)
  full(welcome,'Intro',82,54,cw);textSize(welcome.Intro,18)
  local shift=welcome.ShiftCard;box(shift,12,148,cw-24,174)
  full(shift,'Title',10,28,cw-24);textSize(shift.Title,19)
  full(shift,'Body',42,48,cw-24);textSize(shift.Body,15)
  full(shift,'Best',92,20,cw-24);full(shift,'Start',118,48,cw-24)
  hide(welcome,'PracticeHint');full(welcome,'TutorialHelp',332,44,cw)
  child(welcome,'Practice',12,388,(cw-34)/2,48);child(welcome,'Book',22+(cw-34)/2,388,(cw-34)/2,48)
  local career=page.Career;box(career,x,464,cw,195)
  full(career,'Rank',12,36,cw);textSize(career.Rank,23)
  full(career,'XP',54,30,cw);full(career,'Progress',94,10,cw);full(career,'Details',116,64,cw)
  for i,name in ipairs({'DailyCard','CompetitionCard'}) do
   local card=page[name];box(card,x,671+(i-1)*252,cw,240)
   full(card,'Label',12,26,cw);full(card,name=='DailyCard' and 'Name' or 'Title',47,48,cw)
   full(card,name=='DailyCard' and 'Description' or 'Body',104,62,cw)
   full(card,name=='DailyCard' and 'Start' or 'Join',178,48,cw)
  end
  local collection=page.Collection;box(collection,x,1175,cw,220)
  full(collection,'Count',12,34,cw);full(collection,'Badges',50,48,cw)
  full(collection,'Passport',108,44,cw);full(collection,'Invite',162,44,cw)
  local lobby=page.Lobby;box(lobby,x,671,cw,492);lobby.ZIndex=5
  full(lobby,'Heading',14,38,cw);full(lobby,'Status',62,58,cw);full(lobby,'Players',132,218,cw)
  full(lobby,'Invite',364,48,cw);full(lobby,'Leave',426,48,cw)
  box(page.ChallengeEntry,x,1407,cw,48)
  box(page.Persistence,x,1468,cw,64)
  page.CanvasSize=UDim2.fromOffset(0,1544)
 elseif data.phase=='result' then
  local cw=math.min(w-24,540);local card=page.Verdict;box(card,(w-cw)/2,0,cw,850)
  full(card,'Eyebrow',12,30,cw);full(card,'Title',50,60,cw);textSize(card.Title,29)
  full(card,'Score',116,86,cw);card.Score.TextXAlignment=Enum.TextXAlignment.Center
  full(card,'ScoreCaption',198,24,cw);card.ScoreCaption.TextXAlignment=Enum.TextXAlignment.Center
  full(card,'Stars',230,38,cw);card.Stars.TextXAlignment=Enum.TextXAlignment.Center
  full(card,'Quality',280,28,cw);full(card,'QualityBar',314,10,cw)
  full(card,'Speed',338,28,cw);full(card,'SpeedBar',372,10,cw)
  card.QualityBar.Fill.Size=UDim2.fromScale((data.result.quality or 0)/100,1)
  card.SpeedBar.Fill.Size=UDim2.fromScale((data.result.speed or 0)/100,1)
  full(card,'Detail',396,48,cw)
  local rewards=card.Rewards;box(rewards,12,454,cw-24,96)
  full(rewards,'XP',8,40,cw-24);textSize(rewards.XP,18);full(rewards,'Detail',52,34,cw-24)
  full(card,'Feedback',560,64,cw);full(card,'Standings',632,200,cw)
  -- Keep all result actions reachable without scrolling past the verdict.
  full(card,'Again',0,48,cw);full(card,'Menu',58,44,cw);full(card,'Record',112,44,cw)
  local actions=Instance.new('Frame');actions.Name='Actions';actions.BackgroundTransparency=1;actions.Parent=page
  box(actions,(w-cw)/2,862,cw,166)
  for _,name in ipairs({'Again','Menu','Record'}) do card[name].Parent=actions end
  local dock=Instance.new('Frame');dock.Name='MobileDock';dock.BackgroundTransparency=1;dock.Parent=root
  box(dock,12,h-108,w-24,104)
  actions.Again.Parent=dock;box(dock.Again,0,0,w-24,48)
  actions.Menu.Parent=dock;box(dock.Menu,0,56,w-186,44)
  box(page,0,60,w,h-180)
  child(actions,'Record',16,0,cw-32,44)
  page.CanvasSize=UDim2.fromOffset(0,918)
  if data.mode=='tutorial' then
   hide(card,'Speed');hide(card,'SpeedBar');hide(card,'Detail');hide(card,'Standings')
   full(card,'Eyebrow',8,24,cw);full(card,'Title',36,42,cw)
   full(card,'Score',84,74,cw);textSize(card.Score,64)
   full(card,'ScoreCaption',158,20,cw);full(card,'Stars',184,32,cw)
   full(card,'Quality',228,26,cw);full(card,'QualityBar',260,8,cw)
   box(rewards,12,282,cw-24,56);full(rewards,'XP',4,48,cw-24);hide(rewards,'Detail')
   full(card,'Feedback',350,100,cw);textSize(card.Feedback,16);box(card,(w-cw)/2,0,cw,462)
   box(actions,(w-cw)/2,474,cw,56);page.CanvasSize=UDim2.fromOffset(0,542)
  end
 else
  local dock=Instance.new('Frame');dock.Name='MobileDock';dock.BackgroundTransparency=1;dock.Parent=root
  box(dock,12,h-108,w-24,104)
  box(page,0,60,w,h-180)
  local exit=page.Exit;exit.Parent=dock;box(exit,0,56,w-186,44);textSize(exit,15)
  local board=page.Workbench
  local primary=board:FindFirstChild('Bake') or board:FindFirstChild('Turn') or board:FindFirstChild('Serve')
  if primary then primary.Parent=dock;box(primary,0,0,w-24,48) end
  local left=wide and math.floor((w-36)*.45) or w-24
  local right=wide and (w-36-left) or left
  local rx=wide and left+24 or 12
  local panelY=wide and 0 or (data.mode=='tutorial' and 250 or 290)
  hide(page,'Steps');hide(page,'OrderTicket');hide(page,'RunSummary');hide(page,'PracticeKeys')
  local hint=page:FindFirstChild('Tip')
  if hint then
   box(hint,12,0,left,84);full(hint,'ChefHint',6,22,left);full(hint,'Text',28,50,left);textSize(hint.Text,17);hide(hint,'Goal')
  end
  local by=hint and 94 or 0
  local bh=wide and 166 or (data.mode=='tutorial' and 146 or 186)
  box(board,12,by,left,bh)
  hide(board,'Label');hide(board,'Shortcuts');hide(board,'ServeHint')
  box(refs.pizzaHolder,8,0,left-16,bh-64)
  refs.pizzaWidth,refs.pizzaHeight=left-16,bh-64;refs.ingSig=nil
  full(board,'Match',bh-58,42,left);textSize(refs.match,15)
  full(board,'PrepProgress',bh-12,8,left)
  full(board,'BakeHint',bh-62,34,left);textSize(refs.bakeHint,15)
  full(board,'BakeProgress',bh-22,8,left)
  full(board,'Ready',bh-60,48,left)
  local oven=page:FindFirstChild('OvenControl')
  if oven then
   box(oven,rx,wide and 0 or bh+10,right,230)
   full(oven,'Title',6,22,right);child(oven,'Quality',right-148,6,136,22)
   child(oven,'Temperature',12,32,130,42);textSize(oven.Temperature,30)
   child(oven,'Heat',148,32,right-160,48)
   child(oven,'PowerSlider',22,92,right-44,28);child(oven.PowerSlider,'Knob',0,-8,44,44)
   child(oven,'TemperatureTrack',16,137,right-32,18)
   local recipeBand=data.contract and data.contract.temperatureBand or 25
   local zone=oven.TemperatureTrack.PerfectZone
   box(zone,zone.Position.X.Offset/590*(right-32),0,recipeBand*2/280*(right-32),18)
   child(oven,'Cool',12,176,(right-34)/2,44);child(oven,'Hot',22+(right-34)/2,176,(right-34)/2,44);hide(oven,'Keys');oven.Cool.Text=oven.Cool.Text:gsub('^A%s*/%s*','');oven.Hot.Text=oven.Hot.Text:gsub('^D%s*/%s*','')
   local timing=board.TurnWindow;timing.Parent=page
   box(timing,rx,wide and 242 or bh+252,right,34)
   box(timing.Good,right*.36,0,right*.28,34);box(timing.Perfect,right*.445,0,right*.111,34)
   refs.turnTrackWidth=right-4
   page.CanvasSize=UDim2.fromOffset(0,wide and math.max(288,bh) or bh+300)
  elseif data.phase=='prep' then
   local pantry=page.Pantry;box(pantry,rx,panelY,right,498);Layout.Pantry(pantry,right)
   page.CanvasSize=UDim2.fromOffset(0,panelY+510)
  else
   page.CanvasSize=UDim2.fromOffset(0,by+bh+12)
  end
  if data.phase~='prep' then page.Pantry.Visible=false end
  local change=page:FindFirstChild('ChangeRecipe')
  if change then
   local y=page.CanvasSize.Y.Offset;box(change,12,y,w-24,44);page.CanvasSize=UDim2.fromOffset(0,y+56)
  end
 end
 -- Short landscape phones use one bottom action row and a compact two-column kitchen.
 if wide and h<500 then
  box(root.Language,w-162,6,150,44)
  child(header,'Clock',202,6,w-392,36)
  local dock=root:FindFirstChild('MobileDock')
  if dock then
   box(dock,12,h-52,w-24,48)
   for _,o in dock:GetChildren() do
    if o:IsA('GuiObject') then
     if o.Name=='Exit' or o.Name=='Menu' then box(o,0,0,144,44)
     else box(o,156,0,w-180,44) end
    end
   end
  end
  box(root.Toast,12,h-106,w-24,44)
  box(page,0,60,w,h-(dock and 118 or 66))
  local board=page:FindFirstChild('Workbench')
  if board then
   local left=math.floor((w-36)*.45);local right=w-36-left;local rx=left+24
   local available=math.max(130,h-118)
   local tip=page:FindFirstChild('Tip')
   local by=tip and 64 or 0
   if tip then box(tip,12,0,left,58);hide(tip,'ChefHint');full(tip,'Text',4,50,left);textSize(tip.Text,15) end
   local bh=math.max(92,available-by)
   box(board,12,by,left,bh)
   box(refs.pizzaHolder,6,0,left-12,math.max(36,bh-42))
   refs.pizzaWidth,refs.pizzaHeight=left-12,math.max(36,bh-42);refs.ingSig=nil
   full(board,'Match',bh-42,30,left);full(board,'PrepProgress',bh-8,6,left);full(board,'Ready',bh-40,36,left)
   local pantry=page:FindFirstChild('Pantry')
   if data.phase=='prep' then
    box(pantry,rx,0,right,498);pantry:SetAttribute('LandscapeCompact',true);hide(pantry,'Title')
    child(pantry,'Recommended',12,0,(right-34)/2,44);child(pantry,'All',22+(right-34)/2,0,(right-34)/2,44)
    pantry.Ingredients.Position=UDim2.fromOffset(12,data.mode=='tutorial' and 0 or 52)
    if data.mode=='tutorial' then hide(pantry,'Recommended') end
   elseif data.phase=='bake' then
    local oven=page.OvenControl;box(oven,rx,0,right,164)
    hide(oven,'Title');hide(oven,'Quality')
    child(oven,'Temperature',12,0,110,36);child(oven,'Heat',130,0,right-142,40)
    child(oven,'PowerSlider',22,54,right-44,28);child(oven,'TemperatureTrack',16,96,right-32,14)
    child(oven,'Cool',12,120,(right-34)/2,44);child(oven,'Hot',22+(right-34)/2,120,(right-34)/2,44)
    box(refs.pizzaHolder,6,0,left-12,math.max(32,bh-84));refs.pizzaHeight=math.max(32,bh-84)
    full(board,'BakeHint',bh-82,40,left);full(board,'BakeProgress',bh-38,6,left)
    local timing=page.TurnWindow;box(timing,12,bh-24,left,18)
    box(timing.Good,left*.36,0,left*.28,18);box(timing.Perfect,left*.445,0,left*.111,18);refs.turnTrackWidth=left-4
    refs.turnNeedle.Size=UDim2.fromOffset(4,24)
    page.CanvasSize=UDim2.fromOffset(0,math.max(available,166))
   else page.CanvasSize=UDim2.fromOffset(0,available) end
  end
 end
end

function Layout.Modal(modal,w,h)
 local card=modal:FindFirstChildWhichIsA('Frame');if not card then return end
 local cw=math.min(w-24,540);local ch=math.max(150,h-24)
 box(card,(w-cw)/2,12,cw,ch)
 if card.Name=='RecipeBook' then
  full(card,'Title',12,38,cw);textSize(card.Title,23);child(card,'Close',cw-60,8,48,48)
  child(card,'Title',16,10,cw-84,42);full(card,'Subtitle',62,54,cw)
  local list=card.RecipeList;box(list,12,126,cw-24,ch-138)
  local index=0
  for _,row in list:GetChildren() do if row:IsA('Frame') then
   box(row,0,index*182,cw-30,170);index+=1
   full(row,'Name',8,30,cw-30);full(row,'Recipe',42,40,cw-30);full(row,'Mastery',86,26,cw-30);full(row,'Choose',118,44,cw-30)
  end end
  list.CanvasSize=UDim2.fromOffset(0,index*182)
 elseif card.Name=='Languages' then
  child(card,'Title',16,10,cw-84,42);textSize(card.Title,23);child(card,'Close',cw-60,8,48,48)
  full(card,'Hint',64,58,cw)
  local scroll=Instance.new('ScrollingFrame');scroll.Name='Choices';scroll.BackgroundTransparency=1;scroll.BorderSizePixel=0;scroll.ScrollBarThickness=3;scroll.Parent=card
  box(scroll,12,132,cw-24,ch-144)
  local n=0
  for _,o in card:GetChildren() do if o:IsA('TextButton') and o.Name~='Close' then
   o.Parent=scroll;box(o,0,n*54,cw-30,46);n+=1
  end end
  scroll.CanvasSize=UDim2.fromOffset(0,n*54)
 elseif card.Name=='RecordCard' then
  -- The record is scrollable even on short landscape screens.
  local scroll=Instance.new('ScrollingFrame');scroll.Name='RecordContent';scroll.BackgroundTransparency=1;scroll.BorderSizePixel=0;scroll.ScrollBarThickness=3;scroll.Parent=card
  box(scroll,0,0,cw,ch);scroll.CanvasSize=UDim2.fromOffset(0,604)
  for _,o in card:GetChildren() do if o:IsA('GuiObject') and o~=scroll then o.Parent=scroll end end
  full(scroll,'Brand',16,38,cw);full(scroll,'Name',64,54,cw);full(scroll,'Score',128,110,cw)
  full(scroll,'Stars',246,50,cw);full(scroll,'Recipe',306,58,cw);full(scroll,'Numbers',376,54,cw);full(scroll,'Hint',442,40,cw)
  full(scroll,'Invite',492,44,cw);full(scroll,'Close',548,44,cw)
 end
end
return Layout
