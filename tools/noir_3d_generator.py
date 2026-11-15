import bpy
import os
import sys
import math

# ==========================================
# NOIR AI — UNIVERSAL 3D MODEL GENERATOR
# ==========================================

kind = "building"

if "--" in sys.argv:
    extra = sys.argv[sys.argv.index("--") + 1:]
    if extra:
        kind = extra[0].lower()


# ==========================================
# MATERIALS
# ==========================================

def mat(name, color, metallic=0.0, roughness=0.7):
    material = bpy.data.materials.new(name)
    material.diffuse_color = (*color, 1)
    material.use_nodes = True

    bsdf = material.node_tree.nodes.get("Principled BSDF")
    bsdf.inputs["Base Color"].default_value = (*color, 1)
    bsdf.inputs["Metallic"].default_value = metallic
    bsdf.inputs["Roughness"].default_value = roughness

    return material


# ==========================================
# GEOMETRY HELPERS
# ==========================================

def cube(name, loc, scale, material, bevel=0.025, rotation=(0, 0, 0)):
    bpy.ops.mesh.primitive_cube_add(
        size=1,
        location=loc,
        rotation=rotation
    )

    obj = bpy.context.object
    obj.name = name
    obj.dimensions = scale

    bpy.ops.object.transform_apply(
        location=False,
        rotation=False,
        scale=True
    )

    if material:
        obj.data.materials.append(material)

    if bevel > 0:
        modifier = obj.modifiers.new("NOIR_Edge_Detail", "BEVEL")
        modifier.width = bevel
        modifier.segments = 2

    return obj


def cylinder(name, loc, radius, depth, material,
             rotation=(0, 0, 0), vertices=32):
    bpy.ops.mesh.primitive_cylinder_add(
        vertices=vertices,
        radius=radius,
        depth=depth,
        location=loc,
        rotation=rotation
    )

    obj = bpy.context.object
    obj.name = name

    if material:
        obj.data.materials.append(material)

    for polygon in obj.data.polygons:
        polygon.use_smooth = True

    return obj


def sphere(name, loc, scale, material, subdivisions=2):
    bpy.ops.mesh.primitive_ico_sphere_add(
        subdivisions=subdivisions,
        radius=1,
        location=loc
    )

    obj = bpy.context.object
    obj.name = name
    obj.scale = scale

    if material:
        obj.data.materials.append(material)

    return obj


# ==========================================
# BUILDING
# ==========================================

def make_building():
    concrete = mat(
        "NOIR_Concrete",
        (0.34, 0.37, 0.42),
        roughness=0.88
    )

    concrete_dark = mat(
        "NOIR_Dark_Concrete",
        (0.12, 0.14, 0.18),
        roughness=0.9
    )

    glass = mat(
        "NOIR_Architectural_Glass",
        (0.018, 0.13, 0.24),
        metallic=0.55,
        roughness=0.16
    )

    frame = mat(
        "NOIR_Window_Frame",
        (0.045, 0.055, 0.07),
        metallic=0.65,
        roughness=0.35
    )

    roof = mat(
        "NOIR_Roof",
        (0.055, 0.065, 0.085),
        metallic=0.25
    )

    door = mat(
        "NOIR_Entrance",
        (0.10, 0.065, 0.04),
        metallic=0.2
    )

    metal = mat(
        "NOIR_Facade_Metal",
        (0.22, 0.25, 0.29),
        metallic=0.75,
        roughness=0.35
    )

    # Main building
    cube(
        "Building_Main",
        (0, 0, 3.5),
        (6, 5, 7),
        concrete,
        bevel=0.04
    )

    cube(
        "Building_Roof",
        (0, 0, 7.08),
        (6.35, 5.35, 0.22),
        roof
    )

    # Floor divisions
    for z in [2.3, 4.6]:
        cube(
            "Building_Floor_Band",
            (0, -2.54, z),
            (6.05, 0.09, 0.12),
            metal
        )

    # Front and rear windows
    for side in [-1, 1]:
        y = side * 2.535

        for z in [1.25, 3.5, 5.75]:
            for x in [-2.0, 0.0, 2.0]:

                cube(
                    "Window_Glass",
                    (x, y, z),
                    (1.25, 0.055, 1.35),
                    glass
                )

                # Vertical frames
                for dx in [-0.66, 0.66]:
                    cube(
                        "Window_Vertical_Frame",
                        (x + dx, y - side * 0.045, z),
                        (0.075, 0.075, 1.48),
                        frame
                    )

                # Horizontal frames
                for dz in [-0.72, 0.72]:
                    cube(
                        "Window_Horizontal_Frame",
                        (x, y - side * 0.045, z + dz),
                        (1.38, 0.075, 0.075),
                        frame
                    )

                cube(
                    "Window_Center_Bar",
                    (x, y - side * 0.05, z),
                    (0.045, 0.08, 1.35),
                    metal
                )

    # Side windows
    for side in [-1, 1]:
        x = side * 3.035

        for z in [1.25, 3.5, 5.75]:
            for y in [-1.5, 0, 1.5]:
                cube(
                    "Side_Window",
                    (x, y, z),
                    (0.055, 1.0, 1.35),
                    glass
                )

                for dy in [-0.54, 0.54]:
                    cube(
                        "Side_Window_Frame",
                        (x + side * 0.045, y + dy, z),
                        (0.075, 0.07, 1.48),
                        frame
                    )

    # Entrance
    cube(
        "Building_Entrance",
        (0, -2.56, 0.95),
        (1.35, 0.10, 1.9),
        door
    )

    cube(
        "Entrance_Glass",
        (0, -2.625, 1.25),
        (0.8, 0.035, 1.0),
        glass
    )

    # Entrance columns
    for x in [-0.85, 0.85]:
        cube(
            "Entrance_Column",
            (x, -2.58, 1.1),
            (0.12, 0.18, 2.2),
            metal
        )

    # Roof equipment
    cube(
        "Roof_Machine",
        (1.8, 1.2, 7.5),
        (1.1, 0.9, 0.65),
        concrete_dark
    )

    for x in [-1.5, -0.5, 0.5, 1.5]:
        cube(
            "Roof_Railing",
            (x, 2.3, 7.3),
            (0.08, 0.08, 0.45),
            metal
        )


# ==========================================
# CAR
# ==========================================

def make_car():
    body = mat(
        "NOIR_Car_Paint",
        (0.018, 0.065, 0.48),
        metallic=0.72,
        roughness=0.23
    )

    glass = mat(
        "NOIR_Car_Glass",
        (0.012, 0.045, 0.07),
        metallic=0.5,
        roughness=0.12
    )

    rubber = mat(
        "NOIR_Rubber",
        (0.012, 0.012, 0.014),
        roughness=0.95
    )

    chrome = mat(
        "NOIR_Chrome",
        (0.48, 0.52, 0.58),
        metallic=0.9,
        roughness=0.22
    )

    headlight = mat(
        "NOIR_Headlights",
        (0.95, 0.85, 0.55),
        metallic=0.15,
        roughness=0.2
    )

    tail_light = mat(
        "NOIR_Tail_Lights",
        (0.65, 0.012, 0.008),
        roughness=0.25
    )

    # Main body
    cube(
        "Car_Body",
        (0, 0, 0.82),
        (4.5, 1.85, 0.78),
        body,
        bevel=0.22
    )

    # Hood and trunk
    cube(
        "Car_Hood",
        (1.42, 0, 1.12),
        (1.35, 1.78, 0.22),
        body,
        bevel=0.12
    )

    cube(
        "Car_Trunk",
        (-1.72, 0, 1.1),
        (0.85, 1.78, 0.20),
        body,
        bevel=0.1
    )

    # Cabin
    cube(
        "Car_Cabin",
        (-0.25, 0, 1.48),
        (2.15, 1.48, 0.82),
        body,
        bevel=0.2
    )

    # Side windows
    for side in [-1, 1]:
        y = side * 0.755

        for x in [-0.75, 0.25]:
            cube(
                "Car_Side_Window",
                (x, y, 1.55),
                (0.88, 0.035, 0.48),
                glass,
                bevel=0.045
            )

        cube(
            "Car_Window_Pillar",
            (-0.25, y, 1.53),
            (0.07, 0.07, 0.65),
            chrome
        )

        # Mirrors
        cube(
            "Car_Mirror",
            (0.72, side * 0.98, 1.48),
            (0.28, 0.22, 0.16),
            body,
            bevel=0.06
        )

    # Front and rear windows
    cube(
        "Car_Windshield",
        (0.83, 0, 1.52),
        (0.035, 1.22, 0.52),
        glass,
        bevel=0.04
    )

    cube(
        "Car_Rear_Window",
        (-1.33, 0, 1.52),
        (0.035, 1.18, 0.48),
        glass,
        bevel=0.04
    )

    # Wheels and rims
    for x in [-1.4, 1.4]:
        for y in [-0.96, 0.96]:

            cylinder(
                "Car_Tire",
                (x, y, 0.57),
                0.48,
                0.28,
                rubber,
                rotation=(math.pi / 2, 0, 0),
                vertices=40
            )

            cylinder(
                "Car_Rim",
                (x, y + (0.15 if y > 0 else -0.15), 0.57),
                0.27,
                0.035,
                chrome,
                rotation=(math.pi / 2, 0, 0)
            )

            cylinder(
                "Car_Wheel_Hub",
                (x, y + (0.175 if y > 0 else -0.175), 0.57),
                0.09,
                0.045,
                frame if False else chrome,
                rotation=(math.pi / 2, 0, 0)
            )

    # Front lights and grille
    for y in [-0.62, 0.62]:
        cube(
            "Car_Headlight",
            (2.27, y, 0.96),
            (0.08, 0.42, 0.22),
            headlight,
            bevel=0.07
        )

    cube(
        "Car_Front_Grille",
        (2.30, 0, 0.76),
        (0.08, 0.72, 0.25),
        chrome
    )

    # Rear lights
    for y in [-0.65, 0.65]:
        cube(
            "Car_Tail_Light",
            (-2.27, y, 0.96),
            (0.07, 0.34, 0.2),
            tail_light
        )

    # Bumpers
    cube(
        "Car_Front_Bumper",
        (2.28, 0, 0.55),
        (0.18, 1.9, 0.17),
        chrome
    )

    cube(
        "Car_Rear_Bumper",
        (-2.28, 0, 0.55),
        (0.18, 1.9, 0.17),
        chrome
    )

    # Door handles
    for side in [-1, 1]:
        for x in [-0.9, 0.35]:
            cube(
                "Car_Door_Handle",
                (x, side * 0.94, 1.15),
                (0.22, 0.035, 0.055),
                chrome
            )


# ==========================================
# TREE
# ==========================================

def make_tree():
    wood = mat(
        "NOIR_Wood",
        (0.20, 0.075, 0.025),
        roughness=0.95
    )

    leaves_dark = mat(
        "NOIR_Leaves_Dark",
        (0.018, 0.13, 0.025),
        roughness=0.92
    )

    leaves = mat(
        "NOIR_Leaves",
        (0.035, 0.28, 0.045),
        roughness=0.9
    )

    leaves_light = mat(
        "NOIR_Leaves_Light",
        (0.12, 0.34, 0.055),
        roughness=0.9
    )

    # Trunk
    cylinder(
        "Tree_Trunk",
        (0, 0, 1.6),
        0.28,
        3.2,
        wood,
        vertices=16
    )

    # Branches
    for angle in [0, 2.1, 4.2]:
        x = math.cos(angle) * 0.45
        y = math.sin(angle) * 0.45

        branch = cylinder(
            "Tree_Branch",
            (x * 0.55, y * 0.55, 2.65),
            0.11,
            1.3,
            wood,
            vertices=12
        )

        branch.rotation_euler[1] = angle
        branch.rotation_euler[0] = 0.35

    # Crown
    clusters = [
        (0, 0, 3.5, 1.25, leaves_dark),
        (-0.65, 0, 3.8, 0.95, leaves),
        (0.65, 0.1, 3.85, 0.95, leaves_light),
        (0, -0.65, 4.0, 0.9, leaves),
        (0.1, 0.65, 4.0, 0.9, leaves_dark),
        (0, 0, 4.65, 0.78, leaves_light),
    ]

    for x, y, z, radius, material in clusters:
        sphere(
            "Tree_Crown",
            (x, y, z),
            (radius, radius, radius * 1.1),
            material,
            subdivisions=2
        )


# ==========================================
# GENERATION
# ==========================================

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


# ==========================================
# GLB EXPORT
# ==========================================

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
