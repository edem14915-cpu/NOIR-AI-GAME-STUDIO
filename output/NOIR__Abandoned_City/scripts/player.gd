extends CharacterBody3D

@export var speed: float = 6.0
@export var jump_velocity: float = 4.5
@export var mouse_sensitivity: float = 0.003

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity", 9.8)
var camera_look_delta: Vector2 = Vector2.ZERO
var move_input_vector: Vector2 = Vector2.ZERO

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	var input_dir := move_input_vector
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	
	move_and_slide()
	_apply_camera_rotation()

func _apply_camera_rotation() -> void:
	if camera_look_delta != Vector2.ZERO:
		rotate_y(-camera_look_delta.x * mouse_sensitivity)
		head.rotate_x(-camera_look_delta.y * mouse_sensitivity)
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-80), deg_to_rad(85))
		camera_look_delta = Vector2.ZERO

func do_jump() -> void:
	if is_on_floor():
		velocity.y = jump_velocity
