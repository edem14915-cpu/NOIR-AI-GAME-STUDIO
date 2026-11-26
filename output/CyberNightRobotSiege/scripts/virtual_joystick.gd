extends Control

signal joystick_moved(dir: Vector2)

@export var max_distance: float = 60.0
var is_touching: bool = false
var touch_index: int = -1
var center_pos: Vector2 = Vector2.ZERO
var current_dir: Vector2 = Vector2.ZERO

@onready var knob = $Knob

func _ready():
	center_pos = size / 2.0
	_reset_knob()

func _gui_input(event):
	if event is InputEventScreenTouch:
		if event.pressed and not is_touching:
			is_touching = true
			touch_index = event.index
			_update_position(event.position)
		elif not event.pressed and event.index == touch_index:
			_reset_knob()
	elif event is InputEventScreenDrag and event.index == touch_index:
		_update_position(event.position)

func _update_position(pos: Vector2):
	var offset = pos - center_pos
	if offset.length() > max_distance:
		offset = offset.normalized() * max_distance
	if knob:
		knob.position = center_pos + offset - (knob.size / 2.0)
	current_dir = offset / max_distance
	joystick_moved.emit(current_dir)

func _reset_knob():
	is_touching = false
	touch_index = -1
	current_dir = Vector2.ZERO
	if knob:
		knob.position = center_pos - (knob.size / 2.0)
	joystick_moved.emit(Vector2.ZERO)
