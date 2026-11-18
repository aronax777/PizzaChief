"""Original ingredient sprites. Run with Blender --background --python this_file.

Creates the editable .blend source, transparent PNGs and a 7x4 atlas. No downloads.
"""
import bpy
import math
import random
import json
from pathlib import Path
from mathutils import Vector

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'assets' / 'ingredients'
OUT.mkdir(parents=True, exist_ok=True)
random.seed(17)
bpy.context.preferences.filepaths.save_version=0
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete(use_global=False)
scene = bpy.context.scene
scene.render.engine = 'CYCLES'
scene.cycles.samples = 24
scene.cycles.use_denoising = True
scene.render.resolution_x = scene.render.resolution_y = 256
scene.render.resolution_percentage = 100
scene.render.film_transparent = True
scene.render.image_settings.file_format = 'PNG'
scene.render.image_settings.color_mode = 'RGBA'
scene.view_settings.view_transform = 'AgX'
scene.world.color = (.32, .32, .32)

def material(name, rgb, rough=.42):
    m = bpy.data.materials.new(name)
    m.diffuse_color = (*rgb, 1)
    m.use_nodes = True
    shader = next(n for n in m.node_tree.nodes if n.type == 'BSDF_PRINCIPLED')
    shader.inputs['Base Color'].default_value = (*rgb, 1)
    shader.inputs['Roughness'].default_value = rough
    return m

M = {k: material(k, c) for k,c in {
 'red':(.63,.025,.012), 'tomato':(.87,.055,.018), 'cream':(.95,.86,.61),
 'white':(.99,.96,.83), 'green':(.07,.39,.055), 'leaf':(.17,.56,.055),
 'olive':(.21,.29,.035), 'dark':(.045,.035,.022), 'pink':(.78,.26,.21),
 'fat':(.98,.68,.49), 'tan':(.49,.28,.12), 'brown':(.22,.065,.018),
 'gold':(1,.56,.025), 'purple':(.48,.055,.29), 'pale':(.87,.6,.76),
 'blue':(.13,.32,.20), 'meat':(.69,.38,.18), 'ceramic':(.80,.87,.73),
}.items()}
objects=[]
def finish(o, mat):
    o.data.materials.append(M[mat])
    for p in o.data.polygons: p.use_smooth=True
    objects.append(o)
    return o
def ball(loc, scale, mat):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=24, ring_count=12, location=loc)
    o=bpy.context.object; o.scale=scale
    return finish(o,mat)
def cube(loc, scale, mat, angle=0, bevel=.08):
    bpy.ops.mesh.primitive_cube_add(size=1, location=loc)
    o=bpy.context.object; o.scale=scale; o.rotation_euler[2]=angle
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    mod=o.modifiers.new('Soft edges','BEVEL');mod.width=bevel;mod.segments=3
    o.modifiers.new('Normals','WEIGHTED_NORMAL')
    return finish(o,mat)
def disc(loc, radius, depth, mat):
    bpy.ops.mesh.primitive_cylinder_add(vertices=48, radius=radius, depth=depth, location=loc)
    o=bpy.context.object
    mod=o.modifiers.new('Rounded rim','BEVEL');mod.width=.045;mod.segments=3
    o.modifiers.new('Normals','WEIGHTED_NORMAL')
    return finish(o,mat)
def ring(loc, radius, thickness, mat, scale=(1,1,1)):
    bpy.ops.mesh.primitive_torus_add(major_segments=40,minor_segments=12,location=loc,major_radius=radius,minor_radius=thickness)
    o=bpy.context.object;o.scale=scale
    return finish(o,mat)
def leaf(loc, scale=1, angle=0, mat='green'):
    o=ball(loc,(.24*scale,.53*scale,.07*scale),mat);o.rotation_euler[2]=angle
    vein=cube((loc[0],loc[1],loc[2]+.065*scale),(.025*scale,.74*scale,.018),'leaf',angle,.01)
    return o
def bowl(sauce):
    ball((0,0,.01),(.86,.86,.16),'ceramic')
    disc((0,0,.19),.77,.12,sauce)
    ring((0,0,.24),.79,.055,'white')
    for n in range(5):
        a=n*2.4;ball((math.cos(a)*.43,math.sin(a)*.43,.28),(.10,.08,.025),'leaf' if sauce=='green' else 'tomato' if sauce=='red' else 'tan')
def slices(mat, flecks=False):
    for j,(x,y,z) in enumerate([(-.30,.26,.08),(.35,.14,.17),(-.12,-.34,.26)]):
        disc((x,y,z),.53,.13,mat)
        if flecks:
            for n in range(9):
                a=n*2.4+j;r=.13+(n%3)*.10
                ball((x+math.cos(a)*r,y+math.sin(a)*r,z+.08),(.045,.032,.015),'fat')
def chunks(mat):
    for j,(x,y) in enumerate([(-.45,.3),(.23,.37),(-.28,-.29),(.42,-.25)]):
        cube((x,y,.17+(j%2)*.07),(.60,.44,.32),mat,j*.6)
def wedge(mat):
    verts=[(-.7,-.52,0),(.7,-.52,0),(0,.65,0),(-.7,-.52,.40),(.7,-.52,.40),(0,.65,.40)]
    mesh=bpy.data.meshes.new('Cheese wedge');mesh.from_pydata(verts,[],[(0,2,1),(3,4,5),(0,1,4,3),(1,2,5,4),(2,0,3,5)])
    o=bpy.data.objects.new('Handmade wedge',mesh);scene.collection.objects.link(o);finish(o,mat)
    b=o.modifiers.new('Soft cut','BEVEL');b.width=.055;b.segments=3;o.modifiers.new('Normals','WEIGHTED_NORMAL')

def ingredient(id):
    if id in ('tomato','bbq','pesto','olive_oil'):
        bowl({'tomato':'red','bbq':'brown','pesto':'green','olive_oil':'gold'}[id])
        if id=='tomato':leaf((.36,.23,.36),.43,-.7)
        if id=='olive_oil':
            for x,y in [(-.25,.04),(.25,-.12)]:ball((x,y,.3),(.16,.22,.09),'olive')
    elif id=='mozzarella':
        for x,y,z,s in [(-.30,.25,.23,.52),(.32,-.1,.20,.50),(-.36,-.37,.17,.32)]:ball((x,y,z),(s,s,s*.65),'white')
        leaf((.49,.35,.12),.5,-.8)
    elif id=='rocket':
        for j in range(3):
            a=j*2.1
            for k in range(4):
                y=-.4+k*.22;x=(j-1)*.35
                leaf((x,y,.12+j*.03),.30,a+(-.6 if k%2 else .6))
            cube(((j-1)*.35,-.15,.1),(.025,.95,.025),'leaf',0,.01)
    elif id in ('basil','oregano'):
        for j in range(3 if id!='oregano' else 7):
            a=j*2.4;leaf((math.cos(a)*.34,math.sin(a)*.34,.12+j*.045),.8 if id=='basil' else .65 if id=='rocket' else .40,a,'leaf' if j%2 else 'green')
    elif id=='garlic':
        for j in range(6):
            a=j*math.pi/3;ball((math.cos(a)*.28,math.sin(a)*.28,.22),(.27,.27,.35),'white')
        ball((0,0,.56),(.12,.12,.22),'cream');ball((.65,-.45,.14),(.18,.34,.14),'cream')
    elif id in ('parmesan','gorgonzola'):
        wedge('cream' if id=='parmesan' else 'white')
        for j in range(15):
            x=random.uniform(-.49,.49);y=random.uniform(-.43,.21)
            if abs(x)<(.65-y)*.55:
                ball((x,y,.415),(.055,.028,.012),'gold' if id=='parmesan' else 'blue')
    elif id=='ricotta':
        bowl('white')
        for j in range(20):
            a=j*2.4;r=.58*math.sqrt(j/20);ball((math.cos(a)*r,math.sin(a)*r,.30+.12*(1-r)),(.14,.14,.12),'white')
    elif id=='pepperoni':slices('red',True)
    elif id=='ham':
        for j in range(3):
            o=cube((-.25+j*.25,.28-j*.28,.12+j*.08),(.95,.65,.09),'pink',j*.30)
            cube((-.25+j*.25,-.02-j*.28,.19+j*.08),(.90,.065,.04),'fat',j*.30,.02)
    elif id=='mushroom':
        for x,y,s in [(-.36,.2,.85),(.35,-.18,.72)]:
            ball((x,y-.19,.23),(.19*s,.19*s,.38*s),'cream')
            ball((x,y,.48),(.55*s,.50*s,.28*s),'tan')
            ball((x-.14,y-.15,.65),(.14*s,.12*s,.025),'cream')
    elif id=='olive':
        for j,(x,y) in enumerate([(-.4,.29),(.31,.26),(-.24,-.35),(.47,-.29)]):ring((x,y,.18),.23,.105,'dark',(1,1,.8))
    elif id=='artichoke':
        for j in range(10):
            a=j*2.4;r=.24 if j<6 else .12
            o=ball((math.cos(a)*r,math.sin(a)*r,.24+j*.025),(.25,.48,.14),'olive' if j%2 else 'cream');o.rotation_euler=(.4,0,a)
    elif id=='anchovy':
        for j in range(3):
            o=ball((-.40+j*.40,0,.15+j*.055),(.14,.72,.10),'tan');o.rotation_euler[2]=-.3
            cube((-.4+j*.4,0,.25+j*.055),(.025,1.1,.018),'cream',-.3,.01)
    elif id in ('caper','black_pepper'):
        for j in range(12):
            a=j*2.4;r=.6*math.sqrt(j/12);s=.16 if id=='caper' else .12
            ball((math.cos(a)*r,math.sin(a)*r,s), (s,s,s),'olive' if id=='caper' else 'dark')
    elif id=='tuna':
        for j in range(9):
            a=j*2.4;r=.5*math.sqrt(j/9)
            o=ball((math.cos(a)*r,math.sin(a)*r,.14+j*.015),(.28,.12,.09),'pink' if j%2 else 'fat');o.rotation_euler[2]=a
    elif id in ('chicken','pineapple'):
        chunks({'tuna':'pink','chicken':'meat','pineapple':'gold'}[id])
        if id=='chicken':
            for j in range(3):cube((-.48+j*.18,.3,.345),(.035,.32,.012),'brown',-.2,.005)
    elif id=='onion':
        for j,(x,y,z) in enumerate([(-.28,.18,.1),(.29,.12,.21),(-.04,-.35,.31)]):
            for r in (.27,.38,.49):ring((x,y,z),r,.034,'purple' if r!=.38 else 'pale',(1,.85,1))
    elif id=='pepper':
        for j,(x,y) in enumerate([(-.35,.25),(.32,.1),(-.12,-.38)]):
            ring((x,y,.12+j*.09),.34,.095,'gold',(.9,1,.65))
    elif id=='bacon':
        for j in range(3):
            for n in range(6):
                x=-.43+j*.40;y=-.65+n*.24;z=.12+math.sin(n*1.4)*.06+j*.05
                cube((x,y,z),(.31,.29,.09),'red',.12,.04)
                cube((x+.07,y,z+.055),(.07,.29,.025),'fat',.12,.015)
    elif id=='egg':
        ball((0,0,.1),(.80,.67,.11),'white');ball((.06,.03,.24),(.34,.34,.20),'gold')
        ball((-.06,-.1,.4),(.08,.05,.015),'cream')
    elif id=='sausage':
        slices('meat',True)
        for j in range(3):ball((-.40+j*.35,.20-j*.24,.40),(.035,.035,.025),'dark')
    else:raise ValueError(id)

bpy.ops.object.camera_add(location=(2.1,-3.2,5.8))
camera=bpy.context.object;camera.rotation_euler=(Vector((0,0,.16))-camera.location).to_track_quat('-Z','Y').to_euler()
camera.data.type='ORTHO';camera.data.ortho_scale=2.65;scene.camera=camera
for name,loc,energy,size in [('Softbox',(-3,-4,7),500,5),('Rim',(3,2,5),350,4)]:
    bpy.ops.object.light_add(type='AREA',location=loc)
    light=bpy.context.object;light.name=name;light.data.energy=energy;light.data.shape='DISK';light.data.size=size
    light.rotation_euler=(-light.location).to_track_quat('-Z','Y').to_euler()

ids=['tomato','mozzarella','basil','garlic','oregano','olive_oil','parmesan','gorgonzola','ricotta','pepperoni','ham','mushroom','olive','artichoke','anchovy','caper','tuna','onion','pepper','pineapple','chicken','bbq','bacon','egg','black_pepper','pesto','rocket','sausage']
collections=[]
for idx,id in enumerate(ids):
    objects=[];ingredient(id)
    group=bpy.data.collections.new(id);scene.collection.children.link(group)
    for o in objects:
        for c in list(o.users_collection):c.objects.unlink(o)
        group.objects.link(o)
    for old in collections:old.hide_render=True
    collections.append(group)
    scene.render.filepath=str(OUT/(id+'.png'))
    bpy.ops.render.render(write_still=True)
    print('SPRITE_READY '+id,flush=True)
for c in collections:c.hide_render=c.name!='pepperoni'
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'ingredients.blend'))

# Blender's image API packs the already-rendered sprites without changing their alpha.
atlas=bpy.data.images.new('Ingredient atlas',width=1792,height=1024,alpha=True)
pixels=[0.0]*(1792*1024*4)
manifest={}
for idx,id in enumerate(ids):
    img=bpy.data.images.load(str(OUT/(id+'.png')),check_existing=False)
    buf=list(img.pixels[:]);x=(idx%7)*256;y=(3-idx//7)*256
    for row in range(256):
        start=((y+row)*1792+x)*4
        pixels[start:start+1024]=buf[row*1024:(row+1)*1024]
    manifest[id]={'x':x,'y':(idx//7)*256,'width':256,'height':256}
    bpy.data.images.remove(img)
atlas.pixels[:]=pixels
atlas.filepath_raw=str(OUT/'atlas.png');atlas.file_format='PNG';atlas.save()
(OUT/'manifest.json').write_text(json.dumps({'width':1792,'height':1024,'sprites':manifest},indent=2)+'\n')
print('ALL_SPRITES_READY',flush=True)

# Portable, offline sprite pixels. This is serialization of our own render, not
# a Roblox upload. The UI can show these even before cloud assets are approved.
encoded=[]
for id in ids:
    img=bpy.data.images.load(str(OUT/(id+'.png')),check_existing=False)
    img.scale(64,64)
    rgba=list(img.pixels[:]);palette=[(0,0,0,0)];indices=[]
    for y in range(63,-1,-1):
        for x in range(64):
            i=(y*64+x)*4
            a=round(rgba[i+3]*15)*17
            # These loaded PNG pixels retain their display RGB values.
            rgb=tuple(round(v*31)*255//31 for v in rgba[i:i+3])
            col=(*rgb,a) if a>=34 else (0,0,0,0)
            if col not in palette:palette.append(col)
            indices.append(palette.index(col))
    runs=[]
    for row in range(64):
        x=0
        while x<64:
            n=1;v=indices[row*64+x]
            while x+n<64 and indices[row*64+x+n]==v:n+=1
            runs.extend((n,v));x+=n
    colors=','.join(str((r<<24)|(g<<16)|(b<<8)|a) for r,g,b,a in palette)
    encoded.append('["'+id+'"]={palette={'+colors+'},runs={'+','.join(map(str,runs))+'}}')
    bpy.data.images.remove(img)
(ROOT/'src/shared/IngredientPixels.luau').write_text('-- Generated by scripts/render_ingredients.py. Original Blender artwork, 64px portable previews.\nreturn {\n'+',\n'.join(encoded)+'\n}\n')
