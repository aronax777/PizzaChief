-- Locale-neutral server tokens are resolved independently by each client.
-- Pure API: no network calls, profile changes, global current locale or scores.
local Catalog = require(script.Parent:WaitForChild('LocaleCatalog'))
local Localization = {}
Localization.Locales = {
 {id='en',name='English',roblox='en-us'}, {id='uk',name='Українська',roblox='uk-ua'},
 {id='es',name='Español',roblox='es-es'}, {id='pt-br',name='Português (Brasil)',roblox='pt-br'},
 {id='fr',name='Français',roblox='fr-fr'}, {id='de',name='Deutsch',roblox='de-de'},
 {id='it',name='Italiano',roblox='it-it'}, {id='id',name='Bahasa Indonesia',roblox='id-id'},
 {id='ja',name='日本語',roblox='ja-jp'}, {id='ko',name='한국어',roblox='ko-kr'},
 {id='tr',name='Türkçe',roblox='tr-tr'}, {id='vi',name='Tiếng Việt',roblox='vi-vn'},
 {id='th',name='ไทย',roblox='th-th'}, {id='zh-hans',name='简体中文',roblox='zh-cn'},
 {id='zh-hant',name='繁體中文',roblox='zh-tw'}, {id='ar',name='العربية',roblox='ar-001'},
 {id='hi',name='हिन्दी',roblox='hi-in'},
}
function Localization.Normalize(locale)
 if type(locale)~='string' then return 'en' end
 local id=string.lower(locale):gsub('_','-')
 if id=='zh-tw' or id=='zh-hk' or id:match('^zh%-hant') then return 'zh-hant' end
 if id=='zh' or id=='zh-cn' or id=='zh-sg' or id:match('^zh%-hans') then return 'zh-hans' end
 local language=id:match('^[^-]+')
 if language=='pt' then return 'pt-br' end
 if Catalog[id] then return id end
 return Catalog[language] and language or 'en'
end
-- Literal parameters (e.g. display names) must never be interpreted as keys.
function Localization.Literal(value) return {literal=tostring(value or '')} end
function Localization.Text(locale, message, params)
 local id=Localization.Normalize(locale)
 local function render(value,arguments,depth)
  if depth>8 then return '' end
  if type(value)=='table' then
   if value.literal~=nil then return tostring(value.literal) end
   return render(value.key,value.params,depth+1)
  end
  if value==nil then return '' end
  if type(value)~='string' then return tostring(value) end
  local key=value:gsub('^@','')
  local template=(Catalog[id] or {})[key] or Catalog.en[key]
  if not template then return value:sub(1,1)=='@' and Catalog.en['message.unavailable'] or value end
  return (template:gsub('{([%w_]+)}',function(name)
   local argument=arguments and arguments[name]
   if argument==nil then return '—' end
   local rendered=render(argument,nil,depth+1)
   -- Isolate substitutions so Latin names and numbers keep their internal order in RTL.
   return id=='ar' and (utf8.char(0x2068)..rendered..utf8.char(0x2069)) or rendered
  end))
 end
 return render(message,params,0)
end
function Localization.IsRTL(locale) return Localization.Normalize(locale)=='ar' end
return Localization
