extends Node3D

@onready var player: CharacterBody3D = $Player
@onready var head: Node3D = $Player/Head
@onready var main_menu: Control = $UI/MainMenu
@onready var hud: Control = $UI/HUD
@onready var play_btn: Button = $UI/MainMenu/PlayButton
@onready var jump_btn: Button = $UI/HUD/JumpButton

const SPEED: float = 6.0
const JUMP_VELOCITY: float = 5.0
const SENSITIVITY: float = 0.004

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var is_playing: bool = false

# Touch Controls Variables
var move_touch_id: int = -1
var move_touch_start: Vector2 = Vector2.ZERO
var move_vector: Vector2 = Vector2.ZERO

var look_touch_id: int = -1
var look_last_pos: Vector2 = Vector2.ZERO

func _ready() -> void:
	hud.visible = false
	main_menu.visible = true
	play_btn.pressed.connect(_on_play_pressed)
	jump_btn.pressed.connect(_on_jump_pressed)
	_load_generated_models()

func _on_play_pressed() -> void:
	main_menu.visible = false
	hud.visible = true
	is_playing = true

func _on_jump_pressed() -> void:
	if is_playing and player.is_on_floor():
		player.velocity.y = JUMP_VELOCITY

func _unhandled_input(event: InputEvent) -> void:
	if not is_playing:
		return

	if event is InputEventScreenTouch:
		if event.pressed:
			# Left screen zone for Joystick
			if event.position.x < get_viewport().get_visible_rect().size.x * 0.5:
				if move_touch_id == -1:
					move_touch_id = event.index
					move_touch_start = event.position
			else:
				# Right screen zone for Camera Swipe Look
				if look_touch_id == -1:
					look_touch_id = event.index
					look_last_pos = event.position
		else:
			if event.index == move_touch_id:
				move_touch_id = -1
				move_vector = Vector2.ZERO
			elif event.index == look_touch_id:
				look_touch_id = -1

	elif event is InputEventScreenDrag:
		if event.index == move_touch_id:
			var diff = event.position - move_touch_start
			var max_len = 80.0
			if diff.length() > max_len:
				diff = diff.normalized() * max_len
			move_vector = diff / max_len
		elif event.index == look_touch_id:
			var delta = event.position - look_last_pos
			look_last_pos = event.position
			player.rotate_y(-delta.x * SENSITIVITY)
			head.rotate_x(-delta.y * SENSITIVITY)
			head.rotation.x = clamp(head.rotation.x, deg_to_rad(-80), deg_to_rad(80))

func _physics_process(delta: float) -> void:
	if not is_playing:
		return

	if not player.is_on_floor():
		player.velocity.y -= gravity * delta

	var input_dir = move_vector
	var direction = (player.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		player.velocity.x = direction.x * SPEED
		player.velocity.z = direction.z * SPEED
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, SPEED)
		player.velocity.z = move_toward(player.velocity.z, 0, SPEED)

	player.move_and_slide()


# NOIR AI: Generated 3D models
func _load_generated_models() -> void:
	_add_generated_model("building.glb", Vector3(-20, 0, -12))
	_add_generated_model("car.glb", Vector3(4, 0, -8))
	_add_generated_model("tree.glb", Vector3(12, 0, -12))


func _add_generated_model(file_name: String, spawn_position: Vector3) -> void:
	var model_path = "res://assets/models/" + file_name
	var model_resource = load(model_path)

	if model_resource == null:
		push_warning("NOIR AI: Model not found: " + model_path)
		return

	if not model_resource is PackedScene:
		push_warning("NOIR AI: Invalid model: " + model_path)
		return

	var model = model_resource.instantiate()
	add_child(model)
	model.position = spawn_position
	print("NOIR AI: Model loaded: ", file_name)
