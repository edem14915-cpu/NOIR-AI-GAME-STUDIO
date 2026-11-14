extends Node3D

func _ready() -> void:
	generate_city()

func generate_city() -> void:
	var ground_mesh := PlaneMesh.new()
	ground_mesh.size = Vector2(300, 300)
	var ground_inst := MeshInstance3D.new()
	ground_inst.mesh = ground_mesh
	
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.12, 0.12, 0.14)
	mat.roughness = 0.9
	ground_inst.material_override = mat
	
	var static_body := StaticBody3D.new()
	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(300, 0.1, 300)
	col.shape = shape
	col.position.y = -0.05
	static_body.add_child(col)
	ground_inst.add_child(static_body)
	add_child(ground_inst)
	
	var grid_size := 6
	var block_spacing := 35.0
	var offset := (grid_size * block_spacing) / 2.0
	
	for x in range(grid_size):
		for z in range(grid_size):
			var pos := Vector3((x * block_spacing) - offset, 0, (z * block_spacing) - offset)
			if pos.length() > 10.0:
				spawn_building_block(pos)
				spawn_props(pos)

func spawn_building_block(pos: Vector3) -> void:
	var b_height := randf_range(12.0, 28.0)
	var b_width := randf_range(10.0, 16.0)
	var b_depth := randf_range(10.0, 16.0)
	
	var box := CSGBox3D.new()
	box.size = Vector3(b_width, b_height, b_depth)
	box.position = pos + Vector3(0, b_height / 2.0, 0)
	box.use_collision = true
	
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(randf_range(0.2, 0.35), randf_range(0.2, 0.35), randf_range(0.2, 0.35))
	mat.roughness = 0.7
	box.material = mat
	add_child(box)

func spawn_props(pos: Vector3) -> void:
	for i in range(2):
		var car_box := CSGBox3D.new()
		car_box.size = Vector3(2.0, 1.2, 4.0)
		car_box.position = pos + Vector3(randf_range(-12, 12), 0.6, randf_range(-12, 12))
		car_box.rotation.y = randf_range(0, PI * 2)
		car_box.use_collision = true
		var car_mat := StandardMaterial3D.new()
		car_mat.albedo_color = Color(randf_range(0.1, 0.8), 0.1, 0.1)
		car_box.material = car_mat
		add_child(car_box)
	
	for i in range(3):
		var tree_trunk := CSGCylinder3D.new()
		tree_trunk.radius = 0.3
		tree_trunk.height = 3.0
		tree_trunk.position = pos + Vector3(randf_range(-15, 15), 1.5, randf_range(-15, 15))
		tree_trunk.use_collision = true
		
		var foliage := CSGSphere3D.new()
		foliage.radius = 1.8
		foliage.position = Vector3(0, 2.0, 0)
		var fol_mat := StandardMaterial3D.new()
		fol_mat.albedo_color = Color(0.1, randf_range(0.25, 0.4), 0.15)
		foliage.material = fol_mat
		tree_trunk.add_child(foliage)
		add_child(tree_trunk)
