import bpy
import os

# Очистка сцены
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete(use_global=False)

# Создание куба
bpy.ops.mesh.primitive_cube_add(size=2, location=(0, 0, 1))
cube = bpy.context.object
cube.name = "NOIR_AI_Cube"

# Создание материала
material = bpy.data.materials.new(name="NOIR_Blue")
material.diffuse_color = (0.02, 0.15, 0.8, 1)
cube.data.materials.append(material)

# Создание папки и экспорт
output = os.path.abspath("output/blender_test")
os.makedirs(output, exist_ok=True)

bpy.ops.export_scene.gltf(
    filepath=os.path.join(output, "NOIR_Test.glb"),
    export_format='GLB'
)

print("NOIR AI: 3D MODEL CREATED SUCCESSFULLY")
