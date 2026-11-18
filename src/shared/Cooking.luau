-- Pure rules shared by server, HUD and isolated gameplay tests.
local Cooking = {}
Cooking.TurnCenter = .5
Cooking.TurnWindow = .14
Cooking.PerfectWindow = .055
Cooking.MaxTurnBonus = 6

function Cooking.Turn(elapsed, duration, alreadyTurned)
 if alreadyTurned or type(elapsed)~='number' or type(duration)~='number'
  or elapsed~=elapsed or duration~=duration or duration<=0 or duration==math.huge then return nil end
 local distance=math.abs(elapsed/duration-Cooking.TurnCenter)
 if distance>Cooking.TurnWindow then return nil end
 local perfect=distance<=Cooking.PerfectWindow
 return {perfect=perfect,bonus=perfect and Cooking.MaxTurnBonus or 3,label=perfect and "@turn.perfect" or "@turn.good"}
end

function Cooking.Checklist(required, selected)
 local needed,placed,complete,total,extra=0,0,0,0,0
 for id,n in pairs(required) do
  needed+=n;placed+=math.min(n,selected[id] or 0);total+=1
  if (selected[id] or 0)==n then complete+=1 end
 end
 for id,n in pairs(selected) do extra+=math.max(0,n-(required[id] or 0)) end
 return {needed=needed,placed=placed,complete=complete,total=total,extra=extra,ready=placed==needed and extra==0}
end
return Cooking
