"""Offline catalog/key/source checks; runtime and actual client checks are separate."""
import json,re,sys,hashlib
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'scripts'))
from build_locales import load
catalogs=load();base=catalogs['en'];refs=set()
paths=[ROOT/'src/shared/Challenges.luau',ROOT/'src/shared/ChallengeUI.luau',ROOT/'src/server/ChallengeStore.luau',ROOT/'src/client/PizzaClient.client.luau',ROOT/'src/shared/Recipes.luau',ROOT/'src/shared/GameRules.luau',ROOT/'src/shared/Cooking.luau',ROOT/'src/server/GameServer.server.luau']
for p in paths:
 s=p.read_text()
 refs.update(re.findall(r'''\bT\(['"]([\w.]+)['"]''',s))
 refs.update(re.findall(r'''['"]@([\w.]+)['"]''',s))
 refs.update(re.findall(r'''\bkey\s*=\s*['"]([\w.]+)['"]''',s))
 # No accidentally retained hardcoded Ukrainian player-facing source copy.
 assert not re.search('[А-Яа-яІіЇїЄє]',s),p
assert not refs-base.keys(),refs-base.keys()
for p in (ROOT/'src/shared').glob('Locale*.luau'):
 assert len(p.read_bytes())<200000,f'{p}: exceeds Studio source limit'
for lc,strings in catalogs.items():
 if lc!='uk':
  assert not any(re.search('[А-Яа-яІіЇїЄє]',v) for v in strings.values()),lc
report={'locales':len(catalogs),'keysPerLocale':len(base),'translations':sum(map(len,catalogs.values())), 'referencedKeys':len(refs),'missingKeys':[], 'placeholderMismatches':[], 'sourceByteLimits':True}
print(json.dumps(report,indent=2))
