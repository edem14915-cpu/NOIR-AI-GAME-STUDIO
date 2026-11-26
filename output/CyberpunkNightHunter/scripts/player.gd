extends CharacterBody3D

@export var move_speed: float = 6.0
@export var mouse_sensitivity: float = 0.003
@export var touch_sensitivity: float = 0.005

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var raycast: RayCast3D = $Head/Camera3D/RayCast3D
@onready var muzzle_flash: OmniLight3D = $Head/Camera3D/Gun/Muzzle/MuzzleFlash

var pitch: float = 0.0
var yaw: float = 0.0
var is_reloading: bool = false

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	if GameManager.current_state != GameManager.State.PLAYING:
		return
	
	# Gravity
	if not is_on_floor():
		velocity.y -= 9.8 * delta
	else:
		velocity.y = 0.0
	
	# Input direction
	var joy_vec = Vector2.ZERO
	var ui_node = get_node_or_null("../UI")
	if ui_node:
		joy_vec = ui_node.get_joystick_vector()
	
	var input_dir = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)
	
	if joy_vec.length() > 0.1:
		input_dir = joy_vec
	
	var dir = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	velocity.x = dir.x * move_speed
	velocity.z = dir.z * move_speed
	
	move_and_slide()

func add_look_rotation(delta_x: float, delta_y: float) -> void:
	yaw -= delta_x * touch_sensitivity
	pitch -= delta_y * touch_sensitivity
	pitch = clamp(pitch, deg_to_rad(-80), deg_to_rad(80))
	
	rotation.y = yaw
	head.rotation.x = pitch

func shoot() -> void:
	if GameManager.current_state != GameManager.State.PLAYING: return
	if is_reloading: return
	
	if not GameManager.consume_ammo():
		reload()
		return
	
	# Visual Flash
	muzzle_flash.visible = true
	get_tree().create_timer(0.05).timeout.connect(func(): muzzle_flash.visible = false)
	
	# Raycast hit
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		if collider and collider.is_in_group("enemy"):
			if collider.has_method("take_damage"):
				collider.take_damage(35)
	
	if GameManager.player_ammo <= 0:
		reload()

func reload() -> void:
	if is_reloading: return
	is_reloading = true
	get_tree().create_timer(1.2).timeout.connect(func():
		GameManager.reload_ammo()
		is_reloading = false
	)
