extends CanvasLayer

@onready var joystick_base: Control = $Control/TouchZoneLeft/JoystickBase
@onready var joystick_handle: Control = $Control/TouchZoneLeft/JoystickHandle
@onready var touch_left: Control = $Control/TouchZoneLeft
@onready var touch_right: Control = $Control/TouchZoneRight
@onready var jump_btn: Button = $Control/JumpButton

var player: CharacterBody3D = null
var joystick_touch_id: int = -1
var look_touch_id: int = -1
var joystick_center: Vector2
var max_radius: float = 50.0

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	jump_btn.pressed.connect(_on_jump_pressed)
	joystick_center = joystick_base.global_position + joystick_base.size / 2.0

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			if touch_left.get_global_rect().has_point(event.position) and joystick_touch_id == -1:
				joystick_touch_id = event.index
				_update_joystick(event.position)
			elif touch_right.get_global_rect().has_point(event.position) and look_touch_id == -1:
				look_touch_id = event.index
		else:
			if event.index == joystick_touch_id:
				joystick_touch_id = -1
				_reset_joystick()
			elif event.index == look_touch_id:
				look_touch_id = -1
	
	elif event is InputEventScreenDrag:
		if event.index == joystick_touch_id:
			_update_joystick(event.position)
		elif event.index == look_touch_id and player:
			player.camera_look_delta = event.relative

func _update_joystick(pos: Vector2) -> void:
	joystick_center = joystick_base.global_position + joystick_base.size / 2.0
	var offset := pos - joystick_center
	if offset.length() > max_radius:
		offset = offset.normalized() * max_radius
	joystick_handle.global_position = joystick_center + offset - (joystick_handle.size / 2.0)
	var dir := offset / max_radius
	if player:
		player.move_input_vector = Vector2(dir.x, dir.y)

func _reset_joystick() -> void:
	joystick_handle.position = (joystick_base.size - joystick_handle.size) / 2.0
	if player:
		player.move_input_vector = Vector2.ZERO

func _on_jump_pressed() -> void:
	if player:
		player.do_jump()
