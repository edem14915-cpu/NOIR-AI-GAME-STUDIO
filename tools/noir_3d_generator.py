import bpy
import os
import sys
import math

kind = "building"
if "--" in sys.argv:
    extra = sys.argv[sys.argv.index("--") + 1:]
    if extra:
        kind = extra[0].lower()

def mat(name, color):
    m = bpy.data.materials.new(name)
    m.diffuse_color = (*color, 1)
    return m

def cube(name, loc, scale, material):
    bpy.ops.mesh.primitive_cube_add(size=1, location=loc)
    obj = bpy.context.object
    obj.name = name
    obj.dimensions = scale
    bpy.ops.object.transform_apply(
        location=False, rotation=False, scale=True
    )
    obj.data.materials.append(material)

def make_building():
    wall = mat("NOIR_Concrete", (0.45, 0.48, 0.53))
    glass = mat("NOIR_Glass", (0.02, 0.15, 0.3))
    roof = mat("NOIR_Roof", (0.1, 0.12, 0.16))

    cube("Building_Main", (0, 0, 2.5), (6, 5, 5), wall)
    cube("Building_Roof", (0, 0, 5.1), (6.4, 5.4, 0.3), roof)

    for z in [1.5, 3.2, 4.3]:
        for x in [-2, 0, 2]:
            cube("Building_Window", (x, -2.56, z),
                 (0.9, 0.1, 0.9), glass)

def make_car():
    body = mat("NOIR_CarPaint", (0.01, 0.08, 0.7))
    glass = mat("NOIR_CarGlass", (0.02, 0.12, 0.18))
    rubber = mat("NOIR_Rubber", (0.02, 0.02, 0.02))

    cube("Car_Body", (0, 0, 0.8), (4.5, 1.8, 0.8), body)
    cube("Car_Cabin", (-0.2, 0, 1.45), (2.2, 1.55, 0.9), glass)

    for x in [-1.4, 1.4]:
        for y in [-0.95, 0.95]:
            bpy.ops.mesh.primitive_cylinder_add(
                vertices=32, radius=0.48, depth=0.25,
                location=(x, y, 0.55),
                rotation=(math.pi / 2, 0, 0)
            )
            bpy.context.object.name = "Car_Wheel"
            bpy.context.object.data.materials.append(rubber)

def make_tree():
    wood = mat("NOIR_Wood", (0.25, 0.1, 0.03))
    leaves = mat("NOIR_Leaves", (0.03, 0.35, 0.07))

    bpy.ops.mesh.primitive_cylinder_add(
        vertices=24, radius=0.25, depth=3, location=(0, 0, 1.5)
    )
    bpy.context.object.name = "Tree_Trunk"
    bpy.context.object.data.materials.append(wood)

    for z, radius in [(3, 1.2), (3.9, 0.9), (4.6, 0.6)]:
        bpy.ops.mesh.primitive_ico_sphere_add(
            subdivisions=2, radius=radius, location=(0, 0, z)
        )
        bpy.context.object.name = "Tree_Leaves"
        bpy.context.object.data.materials.append(leaves)

bpy.ops.object.select_all(action="SELECT")
bpy.ops.object.delete(use_global=False)

if kind == "building":
    make_building()
elif kind == "car":
    make_car()
elif kind == "tree":
    make_tree()
else:
    raise ValueError("Unknown model type: " + kind)

output = os.path.abspath("output/noir_models")
os.makedirs(output, exist_ok=True)

bpy.ops.export_scene.gltf(
    filepath=os.path.join(output, kind + ".glb"),
    export_format="GLB"
)

print("NOIR 3D GENERATOR: SUCCESS")
