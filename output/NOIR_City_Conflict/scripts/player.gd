extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
var gravity = 9.8

var health = 100
var armor = 50
var ammo = 30
var total_ammo = 90

var is_crouching = false
var active_controls = false

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var main_node = get_parent()

var touch_sens = 0.005
var touch_drag = Vector2.ZERO

func _ready():
	var hud = main_node.get_node("CanvasLayer/HUD")
	hud.get_node("TouchShoot").pressed.connect(shoot)
	hud.get_node("TouchJump").pressed.connect(jump)
	hud.get_node("TouchCrouch").pressed.connect(toggle_crouch)
	hud.get_node("TouchInteract").pressed.connect(interact)
	set_controls_active(false)

func set_controls_active(active: bool):
	active_controls = active
	set_process_input(active)
	set_physics_process(active)

func _input(event):
	if not active_controls:
		return
	if event is InputEventScreenDrag:
		# Touch Look Right side of screen
		if event.position.x > get_viewport().size.x * 0.4:
			rotate_y(-event.relative.x * touch_sens)
			head.rotate_x(-event.relative.y * touch_sens)
			head.rotation.x = clamp(head.rotation.x, deg_to_rad(-80), deg_to_rad(80))

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

	if active_controls:
		var input_dir = Vector2(0, -1) # Auto move forward gently for demo
		var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
	move_and_slide()

func jump():
	if is_on_floor() and active_controls:
		velocity.y = JUMP_VELOCITY

func toggle_crouch():
	is_crouching = not is_crouching
	head.position.y = 0.3 if is_crouching else 0.6

func interact():
	main_node.get_node("CanvasLayer/HUD/TaskLabel").text = "Задание: Точка достигнута!"

func shoot():
	if ammo > 0:
		ammo -= 1
		_update_ammo_ui()
		# Play visual recoil
		camera.position.z += 0.05
		get_tree().create_timer(0.05).timeout.connect(func(): camera.position.z = 0)

func _update_ammo_ui():
	var ammo_lbl = main_node.get_node_or_null("CanvasLayer/HUD/StatsContainer/AmmoLabel")
	if ammo_lbl:
		ammo_lbl.text = "Патроны: " + str(ammo) + " / " + str(total_ammo)
