import bpy
import os
import sys
import math

# =====================================
# NOIR AI — 3D MODEL GENERATOR
# =====================================

kind = "building"

if "--" in sys.argv:
    extra = sys.argv[sys.argv.index("--") + 1:]
    if extra:
        kind = extra[0].lower()


# =====================================
# MATERIALS
# =====================================

def mat(name, color, metallic=0.0, roughness=0.7):
    material = bpy.data.materials.new(name)
    material.diffuse_color = (*color, 1)
    material.use_nodes = True

    bsdf = material.node_tree.nodes.get("Principled BSDF")
    bsdf.inputs["Base Color"].default_value = (*color, 1)
    bsdf.inputs["Metallic"].default_value = metallic
    bsdf.inputs["Roughness"].default_value = roughness

    return material


# =====================================
# OBJECT CREATION
# =====================================

def cube(name, loc, scale, material):
    bpy.ops.mesh.primitive_cube_add(
        size=1,
        location=loc
    )

    obj = bpy.context.object
    obj.name = name
    obj.dimensions = scale

    bpy.ops.object.transform_apply(
        location=False,
        rotation=False,
        scale=True
    )

    obj.data.materials.append(material)
    return obj


# =====================================
# BUILDING
# =====================================

def make_building():
    concrete = mat(
        "NOIR_Concrete",
        (0.38, 0.42, 0.48),
        roughness=0.9
    )

    glass = mat(
        "NOIR_Blue_Glass",
        (0.015, 0.12, 0.28),
        metallic=0.4,
        roughness=0.2
    )

    roof = mat(
        "NOIR_Roof",
        (0.08, 0.1, 0.14),
        metallic=0.3
    )

    door = mat(
        "NOIR_Door",
        (0.12, 0.07, 0.04)
    )

    cube(
        "Building_Main",
        (0, 0, 2.5),
        (6, 5, 5),
        concrete
    )

    cube(
        "Building_Roof",
        (0, 0, 5.1),
        (6.4, 5.4, 0.3),
        roof
    )

    for z in [1.5, 3.2, 4.3]:
        for x in [-2, 0, 2]:
            cube(
                "Building_Window",
                (x, -2.56, z),
                (0.9, 0.1, 0.9),
                glass
            )

    cube(
        "Building_Door",
        (0, -2.56, 0.9),
        (1.2, 0.12, 1.8),
        door
    )


# =====================================
# CAR
# =====================================

def make_car():
    body = mat(
        "NOIR_Car_Paint",
        (0.015, 0.06, 0.65),
        metallic=0.75,
        roughness=0.25
    )

    glass = mat(
        "NOIR_Car_Glass",
        (0.015, 0.09, 0.15),
        metallic=0.3,
        roughness=0.15
    )

    rubber = mat(
        "NOIR_Rubber",
        (0.012, 0.012, 0.012),
        roughness=0.95
    )

    lights = mat(
        "NOIR_Headlights",
        (0.9, 0.85, 0.55),
        roughness=0.2
    )

    cube(
        "Car_Body",
        (0, 0, 0.8),
        (4.5, 1.8, 0.8),
        body
    )

    cube(
        "Car_Cabin",
        (-0.2, 0, 1.45),
        (2.2, 1.55, 0.9),
        glass
    )

    for x in [-1.4, 1.4]:
        for y in [-0.95, 0.95]:
            bpy.ops.mesh.primitive_cylinder_add(
                vertices=32,
                radius=0.48,
                depth=0.25,
                location=(x, y, 0.55),
                rotation=(math.pi / 2, 0, 0)
            )

            wheel = bpy.context.object
            wheel.name = "Car_Wheel"
            wheel.data.materials.append(rubber)

            for polygon in wheel.data.polygons:
                polygon.use_smooth = True

    cube(
        "Car_Headlight_Left",
        (2.26, -0.55, 0.95),
        (0.08, 0.35, 0.2),
        lights
    )

    cube(
        "Car_Headlight_Right",
        (2.26, 0.55, 0.95),
        (0.08, 0.35, 0.2),
        lights
    )


# =====================================
# TREE
# =====================================

def make_tree():
    wood = mat(
        "NOIR_Wood",
        (0.25, 0.09, 0.025),
        roughness=0.95
    )

    leaves = mat(
        "NOIR_Leaves",
        (0.025, 0.28, 0.045),
        roughness=0.9
    )

    bpy.ops.mesh.primitive_cylinder_add(
        vertices=32,
        radius=0.25,
        depth=3,
        location=(0, 0, 1.5)
    )

    trunk = bpy.context.object
    trunk.name = "Tree_Trunk"
    trunk.data.materials.append(wood)

    for z, radius in [
        (3, 1.2),
        (3.9, 0.9),
        (4.6, 0.6)
    ]:
        bpy.ops.mesh.primitive_ico_sphere_add(
            subdivisions=2,
            radius=radius,
            location=(0, 0, z)
        )

        leaf = bpy.context.object
        leaf.name = "Tree_Leaves"
        leaf.data.materials.append(leaves)


# =====================================
# GENERATION
# =====================================

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


# =====================================
# GLB EXPORT
# =====================================

output = os.path.abspath("output/noir_models")
os.makedirs(output, exist_ok=True)

filepath = os.path.join(output, kind + ".glb")

bpy.ops.export_scene.gltf(
    filepath=filepath,
    export_format="GLB"
)

print("================================")
print("NOIR AI 3D GENERATOR: SUCCESS")
print("MODEL:", kind)
print("FILE:", filepath)
print("================================")
