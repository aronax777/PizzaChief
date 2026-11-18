"""Validate local storefront copy and export UTF-8 text. Does not call Roblox."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
directory = ROOT / 'assets/marketing/localization'
copy = json.loads((directory / 'store-copy.json').read_text())
locales = {p.stem for p in (ROOT / 'localization').glob('*.json')}
assert set(copy) == locales, 'Store copy must cover every game locale'
for locale, entry in copy.items():
    assert set(entry) == {'title', 'description'}, locale
    assert entry['title'].startswith('PIZZA CHIEF'), locale
    assert 0 < len(entry['title']) <= 50, (locale, 'title too long')
    assert entry['description'].strip() and '{' not in entry['description'], locale
    (directory / f'{locale}.txt').write_text(entry['title'] + '\n\n' + entry['description'] + '\n', encoding='utf-8')
print(f'Exported {len(copy)} local titles and descriptions; nothing uploaded.')
