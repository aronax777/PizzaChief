-- Run against current modules in Studio Play (Server). No live DataStore access.
local p=game:GetService('ReplicatedStorage').PizzaChief
local L=require(p.Localization)
local C=require(p.LocaleCatalog)
local Recipes=require(p.Recipes)
local Rules=require(p.GameRules)
local passed=0
local function check(ok,message) assert(ok,message);passed+=1 end
for input,expected in pairs({['en-US']='en',['en_gb']='en',['es-mx']='es',['fr-ca']='fr',['pt-pt']='pt-br',['uk-UA']='uk',['zh-cn']='zh-hans',['zh-TW']='zh-hant',['zh-Hant-HK']='zh-hant',['ar-001']='ar',['hi-in']='hi',['xx-ZZ']='en'}) do
 check(L.Normalize(input)==expected,'Locale normalization: '..input)
end
check(L.Normalize(nil)=='en' and L.Normalize({})=='en','Invalid locales fall back safely')
local original=C.es['ingredient.tomato'];C.es['ingredient.tomato']=nil
check(L.Text('es','ingredient.tomato')==C.en['ingredient.tomato'],'Missing translation uses English')
C.es['ingredient.tomato']=original
check(L.Text('xx','@ingredient.tomato')=='Tomato sauce','Unknown locale uses English')
check(L.Text('en','@missing.key')==C.en['message.unavailable'],'Unknown message token never leaks a key')
check(L.Text('en','winner',{name=L.Literal('@rank.1'),score=100})=='WINNER: @rank.1 / 100 points','User names never resolve as catalog keys')
check(L.Text('en','winner',{name=L.Literal('Chef {score} 50% 🍕'),score=80})=='WINNER: Chef {score} 50% 🍕 / 80 points','Literal Unicode and percent are preserved without a second interpolation')
check(L.Text('en','goal',{score=85,xp=60})=='Goal: 85+ points · +60 XP','Named numeric parameters')
check(L.Text('uk','goal',{score=85,xp=60})=='Ціль: 85+ балів · +60 XP','Ukrainian retained')
check(L.Text('en','@goal')=='Goal: —+ points · +— XP','Missing parameters have a safe visible fallback')
local daily=Rules.Daily(123,Recipes)
check(type(daily.name)=='table' and not L.Text('en',daily.name):find('{',1,true),'Nested daily name resolves')
check(not L.Text('ar',daily.description):find('@',1,true),'Nested description resolves in Arabic')
local s=Recipes.Score('margherita',{},100,20)
check(s.total==0 and s.feedback=='@feedback.empty','Empty pizza score and feedback')
s=Recipes.Score('margherita',{tomato=2,mozzarella=2,olive_oil=1},100,20)
check(L.Text('en',s.feedback)=='Add the missing ingredient: Basil.','Ingredient feedback resolves recursively')
check(L.Text('es',s.feedback)=='Añade el ingrediente que falta: Albahaca.','Same result resolves independently per player')
local english=L.Text('en',s.feedback);L.Text('ja',s.feedback)
check(L.Text('en',s.feedback)==english,'No shared mutable current language')
check(L.IsRTL('ar-001') and not L.IsRTL('uk'),'Arabic RTL detection')
local keys=0;for _ in pairs(C.en) do keys+=1 end
local rendered=0
for _,locale in ipairs(L.Locales) do
 local count=0
 for key,template in pairs(C.en) do
  local params={};for name in template:gmatch('{([%w_]+)}') do params[name]=7 end
  local text=L.Text(locale.id,key,params)
  check(type(C[locale.id][key])=='string','Missing key: '..locale.id..':'..key)
  check(not text:find('{[%w_]+}') and text~='','Unresolved: '..locale.id..':'..key)
  count+=1;rendered+=1
 end
 check(count==keys,'Locale parity: '..locale.id)
end
-- Localizing feedback must not alter any scores or gameplay data.
local before=game:GetService('HttpService'):JSONEncode(s)
for _,locale in ipairs(L.Locales) do L.Text(locale.id,s.feedback) end
check(before==game:GetService('HttpService'):JSONEncode(s),'Input result is immutable')
return {passed=passed,locales=#L.Locales,keys=keys,rendered=rendered,liveDataStoreAccess=false}
