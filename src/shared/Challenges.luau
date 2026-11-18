-- Challenge codes carry identity only. Conditions and scores come from server storage.
local Challenges = {}
Challenges.Version = 1
Challenges.OutcomeMessage = {won='@challenge.won', tied='@challenge.tied', lost='@challenge.lost'}
-- Bump when scoring, turn windows, or oven simulation change incompatibly.
Challenges.RulesVersion = 'oven-turn-speed-v1'
Challenges.Lifetime = 7 * 86400

local function finite(n) return type(n)=='number' and n==n and math.abs(n)<math.huge end
local function range(n,low,high) return finite(n) and n>=low and n<=high end
function Challenges.Code(value)
 if type(value)~='string' or #value>32 then return nil end
 local code=value:upper():gsub('[%s%-]','')
 return #code==12 and code:match('^[0-9A-F]+$') and code or nil
end
function Challenges.LaunchCode(value)
 if type(value)~='string' or #value>32 or value:sub(1,4)~='pc1:' then return nil end
 return Challenges.Code(value:sub(5))
end
function Challenges.LaunchData(code)
 local clean=Challenges.Code(code)
 return clean and ('pc1:'..clean) or nil
end
function Challenges.Score(value) return math.floor(math.clamp(value,0,100)*10+.5)/10 end
function Challenges.CanShareResult(result,mode)
 return mode~='tutorial' and result~=nil and result.total>=50 and result.recipeScore>=50 and result.elapsed<=86400
end
function Challenges.Outcome(value,target)
 local score=Challenges.Score(value)
 return score>target and 'won' or (score==target and 'tied' or 'lost'),score
end
function Challenges.RecipeSignature(recipe)
 local parts={recipe.id,tostring(recipe.temperature),tostring(recipe.bakeTime)}
 local ids={};for id in pairs(recipe.ingredients) do table.insert(ids,id) end;table.sort(ids)
 for _,id in ipairs(ids) do table.insert(parts,id..'='..recipe.ingredients[id]) end
 return table.concat(parts,'|')
end
function Challenges.Validate(raw,Recipes,epoch)
 if type(raw)~='table' then return nil,'@challenge.not_found' end
 if raw.version~=Challenges.Version or raw.rulesVersion~=Challenges.RulesVersion then return nil,'@challenge.outdated' end
 local recipe=Recipes.ById[raw.recipeId]
 if not recipe or raw.recipeSignature~=Challenges.RecipeSignature(recipe) then return nil,'@challenge.outdated' end
 if not Challenges.Code(raw.id) or raw.id~=Challenges.Code(raw.id)
  or not range(raw.createdAt,1,epoch+60) or not range(raw.expiresAt,raw.createdAt+1,raw.createdAt+Challenges.Lifetime)
  or not finite(raw.creatorId) or raw.creatorId%1~=0 or raw.creatorId==0 or math.abs(raw.creatorId)>9007199254740991
  or type(raw.creatorName)~='string' or #raw.creatorName<1 or #raw.creatorName>100 or not utf8.len(raw.creatorName)
  or not range(raw.score,0,100) or not range(raw.quality,0,100) or not range(raw.bakeScore,0,100)
  or not range(raw.recipeScore,50,100) or not range(raw.elapsed,0,86400)
  or not range(raw.stars,0,3) or raw.stars%1~=0
  or not range(raw.duration,0,600) or not range(raw.heatMultiplier,.5,3) or not range(raw.temperatureBand,5,60)
  or type(raw.ingredients)~='table' then return nil,'@challenge.not_found' end
 if raw.expiresAt<=epoch then return nil,'@challenge.expired' end
 local ingredients={};local portions=0
 for id,n in pairs(raw.ingredients) do
  if not Recipes.IngredientById[id] or not range(n,1,3) or n%1~=0 then return nil,'@challenge.not_found' end
  ingredients[id]=n;portions+=n
 end
 if portions<1 or portions>20 then return nil,'@challenge.not_found' end
 return {version=raw.version,rulesVersion=raw.rulesVersion,id=raw.id,recipeId=raw.recipeId,recipeSignature=raw.recipeSignature,
  createdAt=raw.createdAt,expiresAt=raw.expiresAt,creatorId=raw.creatorId,creatorName=raw.creatorName,
  score=Challenges.Score(raw.score),quality=raw.quality,recipeScore=raw.recipeScore,bakeScore=raw.bakeScore,
  elapsed=raw.elapsed,stars=raw.stars,ingredients=ingredients,turned=raw.turned==true,
  duration=raw.duration,heatMultiplier=raw.heatMultiplier,temperatureBand=raw.temperatureBand}
end
return Challenges
