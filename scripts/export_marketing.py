"""Export exact Roblox marketing sizes using Blender's native image API.
Run Blender --background --python scripts/export_marketing.py.
Source artwork is generated with the built-in imagegen tool; prompts are saved.
Gameplay sources are unaltered Roblox Studio viewport captures.
"""
from pathlib import Path
import bpy
import json
import sys

root=Path(__file__).resolve().parents[1]
out=root/'assets/marketing'
exports=[('source/icon-original.png','game-icon-512.png',512,512),
         ('source/icon-original.png','game-icon-1024.png',1024,1024),
         ('source/hero-original.png','thumbnail-hero-1920x1080.png',1920,1080)]
for source,target in [('source/gameplay-prep.jpg','preview-gameplay-1920x1080.png'),
                      ('source/gameplay-oven.jpg','preview-oven-1920x1080.png'),
                      ('source/gameplay-prep-en.jpg','preview-gameplay-en-1920x1080.png'),
                      ('source/gameplay-oven-en.jpg','preview-oven-en-1920x1080.png')]:
    if (out/source).exists():exports.append((source,target,1920,1080))
manifest=[]
if '--only-english' in sys.argv:
    exports=[entry for entry in exports if '-en-' in entry[1]]
    manifest_path=out/'manifest.json'
    if manifest_path.exists():
        manifest=[entry for entry in json.loads(manifest_path.read_text()) if '-en-' not in entry['file']]
for source,name,w,h in exports:
    img=bpy.data.images.load(str(out/source),check_existing=False)
    original=list(img.size)
    # Only resampling; no invented UI, repainting or gameplay alteration.
    img.scale(w,h)
    img.file_format='PNG';img.filepath_raw=str(out/name);img.save()
    manifest.append({'file':name,'width':w,'height':h,'source':source,'sourceSize':original,
                     'kind':'actual-gameplay' if 'gameplay-' in source else 'illustrated-cover'})
    bpy.data.images.remove(img)
(out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
print('MARKETING_EXPORTS_READY',len(exports))
