extends CharacterBody3D

@export var speed: float = 7.0
@export var mouse_sensitivity: float = 0.003
@export var touch_sensitivity: float = 0.15

var move_input: Vector2 = Vector2.ZERO
var look_delta: Vector2 = Vector2.ZERO
var gravity: float = 18.0
var shoot_cooldown: float = 0.12
var time_since_last_shot: float = 0.0
var is_shooting_held: bool = false

@onready var camera = $Camera3D
@onready var raycast = $Camera3D/RayCast3D
@onready var muzzle_flash = $Camera3D/GunMesh/MuzzleFlash
@onready var gun_mesh = $Camera3D/GunMesh

func _ready():
	if muzzle_flash:
		muzzle_flash.visible = false

func _unhandled_input(event):
	if GameManager.current_state != GameManager.State.PLAYING: return
	
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_rotate_camera(Vector2(-event.relative.x * mouse_sensitivity * 50.0, -event.relative.y * mouse_sensitivity * 50.0))

func _physics_process(delta):
	if GameManager.current_state != GameManager.State.PLAYING: return
	
	time_since_last_shot += delta
	
	# Gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# Keyboard input backup for PC testing
	var keyboard_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var input_vec = move_input if move_input.length() > 0.1 else keyboard_dir
	
	var direction = (transform.basis * Vector3(input_vec.x, 0, input_vec.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	
	move_and_slide()
	
	# Shooting logic
	if is_shooting_held and time_since_last_shot >= shoot_cooldown:
		shoot()

func _rotate_camera(delta_vec: Vector2):
	rotate_y(deg_to_rad(delta_vec.x * touch_sensitivity))
	camera.rotate_x(deg_to_rad(delta_vec.y * touch_sensitivity))
	camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(85))

func on_joystick_moved(dir: Vector2):
	move_input = dir

func on_touch_look(delta_vec: Vector2):
	_rotate_camera(Vector2(-delta_vec.x, -delta_vec.y))

func set_shooting(shooting: bool):
	is_shooting_held = shooting
	if shooting and time_since_last_shot >= shoot_cooldown:
		shoot()

func shoot():
	if not GameManager.consume_ammo(): return
	time_since_last_shot = 0.0
	
	# Gun Recoil visual
	if gun_mesh:
		var tween = create_tween()
		tween.tween_property(gun_mesh, "position:z", 0.1, 0.04)
		tween.tween_property(gun_mesh, "position:z", 0.0, 0.08)
	
	# Flash
	if muzzle_flash:
		muzzle_flash.visible = true
		get_tree().create_timer(0.04).timeout.connect(func(): muzzle_flash.visible = false)
	
	# Raycast Hit
	if raycast.is_colliding():
		var target = raycast.get_collider()
		if target and target.has_method("take_damage"):
			target.take_damage(25)
