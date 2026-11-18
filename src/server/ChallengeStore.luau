-- Immutable seven-day challenges. Studio stays in memory; published servers use DataStore.
local Challenges = require(game:GetService('ReplicatedStorage'):WaitForChild('PizzaChief'):WaitForChild('Challenges'))
local Recipes = require(game:GetService('ReplicatedStorage'):WaitForChild('PizzaChief'):WaitForChild('Recipes'))
local Store = {}
function Store.New(deps)
 deps=deps or {}
 local epoch=deps.now or os.time
 local localOnly=deps.localOnly
 if localOnly==nil then localOnly=game:GetService('RunService'):IsStudio() or game.GameId==0 end
 local newId=deps.newId or function()return game:GetService('HttpService'):GenerateGUID(false):gsub('%-',''):sub(1,12):upper()end
 local getStore=deps.getStore or function()return game:GetService('DataStoreService'):GetDataStore('PizzaChiefChallenges_v1')end
 local records,order={},{}
 local dataStore
 local api={localOnly=localOnly}
 local function cache(record)
  if not records[record.id] then table.insert(order,record.id) end
  records[record.id]=record
  while #order>128 do records[table.remove(order,1)]=nil end
 end
 function api:Create(source)
  for _=1,3 do
   local raw=table.clone(source)
   raw.id=newId();raw.createdAt=epoch();raw.expiresAt=raw.createdAt+Challenges.Lifetime
   raw.version=Challenges.Version;raw.rulesVersion=Challenges.RulesVersion
   local clean,err=Challenges.Validate(raw,Recipes,epoch())
   if not clean then return nil,err end
   local stored
   if localOnly then
    if not records[clean.id] then stored=clean end
   else
    local wrote=false
    local ok,value=pcall(function()
     dataStore=dataStore or getStore()
     return dataStore:UpdateAsync('challenge_'..clean.id,function(old)
      wrote=false
      if old~=nil then return nil end
      wrote=true;return clean
     end)
    end)
    if not ok then return nil,'@challenge.unavailable' end
    if wrote and type(value)=='table' and value.id==clean.id then stored=value end
   end
   if stored then cache(clean);return Challenges.Validate(clean,Recipes,epoch()) end
  end
  return nil,'@challenge.unavailable'
 end
 function api:Load(code)
  local id=Challenges.Code(code)
  if not id then return nil,'@challenge.invalid_code' end
  local raw=records[id]
  if not raw and not localOnly then
   local ok,value=pcall(function()dataStore=dataStore or getStore();return dataStore:GetAsync('challenge_'..id)end)
   if not ok then return nil,'@challenge.unavailable' end
   raw=value
  end
  local clean,err=Challenges.Validate(raw,Recipes,epoch())
  if not clean then records[id]=nil;return nil,err end
  if clean.id~=id then return nil,'@challenge.not_found' end
  cache(clean)
  return Challenges.Validate(clean,Recipes,epoch())
 end
 return api
end
return Store
