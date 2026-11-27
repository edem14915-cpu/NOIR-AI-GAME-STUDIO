extends CharacterBody3D

@export var speed: float = 7.0
@export var jump_velocity: float = 4.5
@export var mouse_sensitivity: float = 0.003
@export var touch_sensitivity: float = 0.005

@onready var camera: Camera3D = $Head/Camera3D
@onready var gun_raycast: RayCast3D = $Head/Camera3D/RayCast3D
@onready var muzzle_flash: OmniLight3D = $Head/Camera3D/GunMesh/MuzzleFlash

var gravity: float = 9.8
var look_dir: Vector2 = Vector2.ZERO
var joystick_vector: Vector2 = Vector2.ZERO
var fire_pressed: bool = false
var fire_cooldown: float = 0.12
var fire_timer: float = 0.0

func _ready() -> void:
	muzzle_flash.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if GameManager.current_state != GameManager.State.PLAYING:
		return
		
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-85), deg_to_rad(85))

func apply_look_delta(delta: Vector2) -> void:
	rotate_y(-delta.x * touch_sensitivity)
	camera.rotate_x(-delta.y * touch_sensitivity)
	camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-85), deg_to_rad(85))

func _physics_process(delta: float) -> void:
	if GameManager.current_state != GameManager.State.PLAYING:
		return
		
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Input direction from keyboard or dynamic touch joystick
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if joystick_vector.length() > 0.1:
		input_dir = joystick_vector

	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()

	# Shooting handling
	fire_timer -= delta
	if fire_pressed and fire_timer <= 0.0:
		shoot()
		fire_timer = fire_cooldown

func shoot() -> void:
	if not GameManager.consume_ammo():
		return
	
	trigger_muzzle_flash()
	
	if gun_raycast.is_colliding():
		var collider = gun_raycast.get_collider()
		if collider and collider.has_method("take_damage"):
			collider.take_damage(25.0)

func trigger_muzzle_flash() -> void:
	muzzle_flash.visible = true
	await get_tree().create_timer(0.05).timeout
	muzzle_flash.visible = false

func take_damage(amount: float) -> void:
	GameManager.damage_player(amount)
