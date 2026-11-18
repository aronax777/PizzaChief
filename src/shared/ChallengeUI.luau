-- Result posters and incoming challenges share one responsive, locale-aware presentation.
local UI = {}
function UI.Open(ctx,kind)
 local T,C=ctx.T,ctx.C
 local make,panel,label,button=ctx.make,ctx.panel,ctx.label,ctx.button
 local root=ctx.root
 local gui=game:GetService('GuiService')
 local previousSelection=gui.SelectedObject
 local backgroundSelection={}
 for _,o in root:GetDescendants() do
  if o:IsA('GuiObject') and o.Selectable then backgroundSelection[o]=true;o.Selectable=false end
 end
 local w,h=root.Size.X.Offset,root.Size.Y.Offset
 local compact=ctx.mobile
 local short=compact and (h<500 or (w>=650 and h<650))
 local narrow=compact and w<650
 local cw=compact and w-24 or 1000
 local ch=compact and h-24 or 760
 local overlay=make('Frame',root,{Name='ChallengeOverlay',Size=UDim2.fromScale(1,1),BackgroundColor3=C.ink,BackgroundTransparency=.08,BorderSizePixel=0,Active=true,ZIndex=40})
 overlay.SelectionGroup=true
 for _,direction in {'Up','Down','Left','Right'} do overlay['SelectionBehavior'..direction]=Enum.SelectionBehavior.Stop end
 overlay.Destroying:Connect(function()
  for o in pairs(backgroundSelection) do if o.Parent then o.Selectable=true end end
  if gui.SelectedObject and gui.SelectedObject:IsDescendantOf(overlay) then
   gui.SelectedObject=previousSelection and previousSelection.Parent and previousSelection or nil
  end
 end)
 local card=panel(overlay,'ChallengeCard',(w-cw)/2,(h-ch)/2,cw,ch,C.cream)
 local scroll=make('ScrollingFrame',card,{Name='Content',Size=UDim2.new(1,0,1,short and -58 or -164),CanvasSize=UDim2.new(),ScrollBarThickness=3,BackgroundTransparency=1,BorderSizePixel=0})
 scroll.Selectable=false
 local actions=make('Frame',card,{Name='Actions',Position=UDim2.new(0,12,1,short and -52 or -154),Size=UDim2.new(1,-24,0,short and 48 or 142),BackgroundTransparency=1})
 local currentKind=kind
 local initial=ctx.data()
 local result=initial.result
 local displayedRecord
 local requestRevision=0
 local requestedCode
 local requestAt=0
 local pendingIntent
 local busy=false
 local restoreCapture
 local poster
 local refs={}
 local controller={}
 local function focus(target,wasSelected)
  if wasSelected or gui.SelectedObject then gui.SelectedObject=target end
 end
 function controller:Close()
  pendingIntent=nil
  if restoreCapture then restoreCapture() end
  overlay:Destroy()
  ctx.close()
 end
 local function close() controller:Close() end
 local function action(name,text,index,fn,color)
  if short then
   local bw=(cw-48)/3
   return button(actions,name,text,(index-1)*(bw+12),0,bw,44,color or C.green,fn)
  end
  return button(actions,name,text,0,(index-1)*48,cw-24,44,color or C.green,fn)
 end
 local function styleTextBox(box)
  box.AutoLocalize=false;box.ClearTextOnFocus=false;box.Font=Enum.Font.GothamBold;box.TextSize=20;box.TextColor3=C.green;box.BackgroundColor3=C.paper;box.BorderSizePixel=0
 end
 local function conditions(record)
  local duration=record.duration==0 and T('challenge.untimed') or T('challenge.seconds',{seconds=math.floor(record.duration+.5)})
  return T('challenge.conditions',{time=duration,heat=string.format('%.2f',record.heatMultiplier),band=record.temperatureBand})
 end
 local function resultRecord(d)
  local r=d.result or {};local c=r.conditions or {duration=0,heatMultiplier=1,temperatureBand=25}
  return {creatorId=ctx.player.UserId,creatorName=ctx.player.DisplayName,recipeId=d.recipeId,ingredients=r.ingredients or d.ingredients or {},
   score=ctx.Challenges.Score(r.total or 0),quality=r.quality or 0,bakeScore=r.bakeScore or 0,elapsed=r.elapsed or 0,
   stars=r.reward and r.reward.stars or 0,turned=d.turned,duration=c.duration,heatMultiplier=c.heatMultiplier,temperatureBand=c.temperatureBand}
 end
 local function renderPoster(record)
  displayedRecord=record
  scroll:ClearAllChildren();refs={}
  local ph=short and 190 or (narrow and 478 or 570)
  poster=panel(scroll,'PizzaPoster',0,0,cw,ph,C.cream)
  panel(poster,'Accent',0,0,cw,5,C.orange)
  local brand=label(poster,'Brand',T('challenge.brand'),16,14,cw-32,26,18,C.green,Enum.Font.GothamBlack)
  local avatar=make('ImageLabel',poster,{Name='ChefAvatar',Position=UDim2.fromOffset(16,50),Size=UDim2.fromOffset(42,42),BackgroundColor3=C.sage,BorderSizePixel=0})
  make('UICorner',avatar,{CornerRadius=UDim.new(1,0)})
  label(poster,'Chef',record.creatorName,68,50,cw-84,42,18,C.green,Enum.Font.GothamBold)
  if record.creatorId>0 then task.spawn(function()
   local ok,url=pcall(function()return game:GetService('Players'):GetUserThumbnailAsync(record.creatorId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size100x100)end)
   if ok and avatar.Parent then avatar.Image=url end
  end) end
  local recipe=ctx.Recipes.ById[record.recipeId]
  local recipeName=recipe and recipe.name or ''
  local name=label(poster,'Recipe',recipeName,16,100,cw-32,46,32,C.green,Enum.Font.GothamBlack)
  local pizzaW=narrow and cw*.62 or cw*.54
  local pv=ctx.pizza(poster,6,146,pizzaW,narrow and 190 or 295,record.ingredients,true,record.turned)
  local sx=narrow and cw*.62 or cw*.58
  local sw=cw-sx-16
  label(poster,'Score',string.format('%.1f',record.score),sx,narrow and 174 or 200,sw,narrow and 72 or 112,narrow and 54 or 86,C.green,Enum.Font.GothamBlack).TextXAlignment=Enum.TextXAlignment.Center
  label(poster,'Points',T('result.points'),sx,narrow and 246 or 312,sw,24,14,C.muted).TextXAlignment=Enum.TextXAlignment.Center
  label(poster,'Stars',ctx.stars(record.stars),sx,narrow and 274 or 344,sw,40,31,C.orange).TextXAlignment=Enum.TextXAlignment.Center
  refs.stats=label(poster,'Stats',T('challenge.stats',{quality=math.floor(record.quality+.5),bake=math.floor(record.bakeScore+.5),seconds=string.format('%.1f',record.elapsed)}),16,narrow and 334 or 444,cw-32,38,16,C.green)
  refs.conditions=label(poster,'Conditions',conditions(record),16,narrow and 378 or 486,cw-32,42,14,C.muted)
  refs.code=label(poster,'Code','',16,narrow and 426 or 530,cw-32,36,18,C.orange,Enum.Font.GothamBold)
  if short then
   brand.Size=UDim2.fromOffset(cw*.45,24)
   avatar.Position=UDim2.fromOffset(16,45);avatar.Size=UDim2.fromOffset(32,32)
   poster.Chef.Position=UDim2.fromOffset(56,42);poster.Chef.Size=UDim2.fromOffset(cw*.38,36)
   name.Position=UDim2.fromOffset(cw*.50,12);name.Size=UDim2.fromOffset(cw*.48-16,34)
   pv.Position=UDim2.fromOffset(4,76);pv.Size=UDim2.fromOffset(cw*.35,105)
   poster.Score.Position=UDim2.fromOffset(cw*.36,80);poster.Score.Size=UDim2.fromOffset(cw*.22,64)
   poster.Points.Visible=false;poster.Stars.Position=UDim2.fromOffset(cw*.36,146);poster.Stars.Size=UDim2.fromOffset(cw*.22,32)
   refs.stats.Position=UDim2.fromOffset(cw*.61,54);refs.stats.Size=UDim2.fromOffset(cw*.37,42)
   refs.conditions.Position=UDim2.fromOffset(cw*.61,102);refs.conditions.Size=UDim2.fromOffset(cw*.37,44)
   refs.code.Position=UDim2.fromOffset(cw*.61,150);refs.code.Size=UDim2.fromOffset(cw*.37,34)
  end
  refs.notice=label(scroll,'Notice','',16,ph+6,cw-32,56,15,C.green)
  scroll.CanvasSize=UDim2.fromOffset(0,ph+70)
 end
 local function eligible(d)
  return d.phase=='result' and ctx.Challenges.CanShareResult(d.result,d.mode)
 end
 local function capture()
  if busy or not overlay.Parent then return end
  if game:GetService('RunService'):IsStudio() then ctx.notify(T('challenge.capture_studio'));return end
  busy=true
  local selected=gui.SelectedObject
  gui.SelectedObject=nil
  local captureSelection={}
  for _,o in overlay:GetDescendants() do
   if o:IsA('GuiObject') and o.Selectable then captureSelection[o]=true;o.Selectable=false end
  end
  local restore={}
  for _,o in root:GetChildren() do if o:IsA('GuiObject') and o~=overlay then restore[o]=o.Visible;o.Visible=false end end
  actions.Visible=false;refs.notice.Visible=false
  local previousPosition=scroll.CanvasPosition;scroll.CanvasPosition=Vector2.zero
  local restored=false
  local function finish()
   if restored then return end;restored=true;busy=false
   restoreCapture=nil
   for o,visible in pairs(restore) do if o.Parent then o.Visible=visible end end
   if actions.Parent then actions.Visible=true end
   if refs.notice and refs.notice.Parent then refs.notice.Visible=true end
   if scroll.Parent then scroll.CanvasPosition=previousPosition end
   for o in pairs(captureSelection) do if o.Parent then o.Selectable=true end end
   if selected and selected.Parent and overlay.Parent then gui.SelectedObject=selected end
  end
  -- Capture includes the complete poster, including on short landscape displays.
  local captureScale=Instance.new('UIScale');captureScale.Parent=poster
  captureScale.Scale=math.min(1,(ch-16)/poster.Size.Y.Offset)
  local oldScrollSize=scroll.Size;scroll.Size=UDim2.fromScale(1,1)
  local oldFinish=finish
  finish=function()oldFinish();if captureScale.Parent then captureScale:Destroy()end;if scroll.Parent then scroll.Size=oldScrollSize end end
  restoreCapture=finish
  task.delay(12,finish)
  task.spawn(function()
   game:GetService('RunService').RenderStepped:Wait();game:GetService('RunService').RenderStepped:Wait()
   if not overlay.Parent then finish();return end
   local ok=pcall(function()
    local service=game:GetService('CaptureService')
    service:TakeScreenshotCaptureAsync(function(status,captured)
     finish()
     if not overlay.Parent then return end
     if status==Enum.ScreenshotCaptureResult.Success and captured then
      local saved=pcall(function()service:PromptSaveCapturesToGallery({captured},function()end)end)
      if not saved then ctx.notify(T('challenge.capture_failed')) end
     else ctx.notify(T('challenge.capture_failed')) end
    end,{UICaptureMode=Enum.UICaptureMode.All})
   end)
   if not ok then finish();ctx.notify(T('challenge.capture_failed')) end
  end)
 end
 overlay.Destroying:Connect(function() if restoreCapture then restoreCapture() end end)
 local function perform(intent,record)
  if intent=='invite' then
   local target=result and result.challenge and result.challenge.creatorId
   ctx.invite(record.id,target~=ctx.player.UserId and target or nil)
  elseif intent=='capture' then capture() end
 end
 local function request(intent)
  local d=ctx.data()
  if busy or pendingIntent or not overlay.Parent then return end
  if not eligible(d) then if intent=='capture' then capture() else ctx.notify(T('challenge.ineligible')) end;return end
  if d.shareChallenge and d.shareChallenge.expiresAt>os.time() then perform(intent,d.shareChallenge);return end
  pendingIntent=intent;requestAt=os.clock();requestRevision=d.challengeRevision or 0;ctx.send('CreateChallenge')
 end
 local function offer(record)
  local wasSelected=gui.SelectedObject~=nil
  ctx.onOffer(record.id)
  currentKind='incoming';actions:ClearAllChildren();renderPoster(record)
  refs.notice.Text=T('challenge.from',{name=ctx.L.Literal(record.creatorName),score=string.format('%.1f',record.score)})
  local accept=action('Accept',T('challenge.accept'),1,function()ctx.send('AcceptChallenge',record.id)end,C.orange)
  action('OtherCode',T('challenge.enter_code'),2,function()controller:Lookup()end)
  action('Close',T('back'),3,close)
  focus(accept,wasSelected)
 end
 function controller:Lookup()
  local wasSelected=gui.SelectedObject~=nil
  currentKind='lookup';pendingIntent=nil;scroll:ClearAllChildren();actions:ClearAllChildren();refs={}
  label(scroll,'Title',T('challenge.title'),16,16,cw-32,44,28,C.green,Enum.Font.GothamBlack)
  label(scroll,'Hint',T('challenge.code_hint'),16,70,cw-32,60,17,C.green)
  local input=make('TextBox',scroll,{Name='ChallengeCode',Position=UDim2.fromOffset(16,142),Size=UDim2.fromOffset(cw-32,48),Text='',PlaceholderText='A1B2C3D4E5F'})
  styleTextBox(input)
  refs.notice=label(scroll,'Notice','',16,204,cw-32,64,16,C.orange)
  scroll.CanvasSize=UDim2.fromOffset(0,280)
  local function lookup()
   local code=ctx.Challenges.Code(input.Text)
   if not code then refs.notice.Text=T('challenge.invalid_code');return end
   if pendingIntent then return end
   pendingIntent='lookup';requestedCode=code;requestAt=os.clock();requestRevision=ctx.data().challengeRevision or 0;ctx.send('LookupChallenge',code)
  end
  input.FocusLost:Connect(function(enter)if enter then lookup()end end)
  action('Lookup',T('challenge.find'),1,lookup,C.orange)
  local hasPending=ctx.data().pendingChallenge~=nil
  if hasPending then
   action('Pending',T('challenge.open_invite'),2,function()local d=ctx.data();if d.pendingChallenge then offer(d.pendingChallenge)else refs.notice.Text=T('challenge.expired')end end)
  end
  action('Close',T('back'),hasPending and 3 or 2,close)
  focus(input,wasSelected)
 end
 if kind=='lookup' then controller:Lookup()
 elseif kind=='incoming' and initial.pendingChallenge then offer(initial.pendingChallenge)
 else
  currentKind='result';renderPoster(resultRecord(initial))
  local invite
  if eligible(initial) then invite=action('Invite',T(result and result.challenge and 'challenge.reply' or 'challenge.invite'),1,function()request('invite')end,C.orange) end
  local save=action('Save',T('challenge.save_image'),invite and 2 or 1,function()request('capture')end)
  action('Close',T('back'),invite and 3 or 2,close)
  focus(invite or save)
 end
 function controller:Update(d)
  if not overlay.Parent then return end
  local replied=(d.challengeRevision or 0)>requestRevision
  if pendingIntent and os.clock()-requestAt>15 then pendingIntent=nil;refs.notice.Text=T('challenge.unavailable') end
  if currentKind=='lookup' then
   if refs.notice and pendingIntent then refs.notice.Text=T(d.challengeStatus) end
   if replied and pendingIntent=='lookup' and d.challengeStatus=='@challenge.ready' and d.pendingChallenge and d.pendingChallenge.id==requestedCode then pendingIntent=nil;offer(d.pendingChallenge)
   elseif replied and pendingIntent=='lookup' and d.challengeStatus~='@challenge.loading' then pendingIntent=nil end
  elseif currentKind=='result' then
   local record=d.shareChallenge
   refs.code.Text=record and T('challenge.code',{code=record.id}) or (eligible(d) and T('challenge.same_rules') or '')
   refs.notice.Text=record and (d.challengeLocalOnly and T('challenge.local_only') or T('challenge.expires',{date=os.date('!%Y-%m-%d',record.expiresAt)})) or T(d.challengeStatus)
   if result and result.challenge and not pendingIntent and not record then
    refs.notice.Text=T(ctx.Challenges.OutcomeMessage[result.challenge.outcome],{name=ctx.L.Literal(result.challenge.creatorName),score=string.format('%.1f',result.challenge.score),target=string.format('%.1f',result.challenge.target)})
   end
   if pendingIntent and record then
    local intent=pendingIntent;pendingIntent=nil;task.defer(function()if overlay.Parent then perform(intent,record)end end)
   elseif replied and pendingIntent and d.challengeStatus~='' and d.challengeStatus~='@challenge.saving' and d.challengeStatus~='@challenge.saved' then pendingIntent=nil end
  elseif displayedRecord then
   refs.code.Text=T('challenge.code',{code=displayedRecord.id})
   if d.message and d.message~='' then refs.notice.Text=T(d.message) end
  end
 end
 controller:Update(initial)
 return overlay,controller
end
return UI
