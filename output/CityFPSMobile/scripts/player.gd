extends CharacterBody3D

@export var speed: float = 8.0
@export var jump_velocity: float = 5.0
@export var sensitivity: float = 0.004

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity", 9.8)
var move_vector: Vector2 = Vector2.ZERO
var touch_move_id: int = -1
var touch_look_id: int = -1
var touch_start_pos: Vector2 = Vector2.ZERO

@onready var head: Node3D = $Head
@onready var raycast: RayCast3D = $Head/RayCast3D

var is_active: bool = false

func _input(event: InputEvent) -> void:
	if not is_active:
		return

	if event is InputEventScreenTouch:
		if event.pressed:
			if event.position.x < get_viewport().size.x / 2.0 and touch_move_id == -1:
				touch_move_id = event.index
				touch_start_pos = event.position
			elif event.position.x >= get_viewport().size.x / 2.0 and touch_look_id == -1:
				touch_look_id = event.index
		else:
			if event.index == touch_move_id:
				touch_move_id = -1
				move_vector = Vector2.ZERO
			elif event.index == touch_look_id:
				touch_look_id = -1

	elif event is InputEventScreenDrag:
		if event.index == touch_move_id:
			var diff = event.position - touch_start_pos
			if diff.length() > 60.0:
				diff = diff.normalized() * 60.0
			move_vector = diff / 60.0
		elif event.index == touch_look_id:
			rotate_y(-event.relative.x * sensitivity)
			head.rotate_x(-event.relative.y * sensitivity)
			head.rotation.x = clamp(head.rotation.x, deg_to_rad(-80), deg_to_rad(80))

func _physics_process(delta: float) -> void:
	if not is_active:
		return

	if not is_on_floor():
		velocity.y -= gravity * delta

	var direction = (transform.basis * Vector3(move_vector.x, 0, move_vector.y)).normalized()
	if direction != Vector3.ZERO:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()

func do_jump() -> void:
	if is_active and is_on_floor():
		velocity.y = jump_velocity

func do_interact() -> String:
	if not is_active:
		return ""
	if raycast.is_colliding():
		var target = raycast.get_collider()
		return "Interacted with: " + target.name
	return "Nothing nearby to interact"
