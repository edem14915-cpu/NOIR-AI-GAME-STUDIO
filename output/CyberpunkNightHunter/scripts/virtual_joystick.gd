extends Control

@onready var knob: ColorRect = $Base/Knob
@onready var base: ColorRect = $Base

var touch_index: int = -1
var center: Vector2
var radius: float = 60.0
var output_vector: Vector2 = Vector2.ZERO

func _ready() -> void:
	center = base.size / 2.0
	reset_knob()

func reset_knob() -> void:
	knob.position = center - knob.size / 2.0
	output_vector = Vector2.ZERO

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and touch_index == -1:
			touch_index = event.index
			_update_joystick(event.position)
		elif not event.pressed and event.index == touch_index:
			touch_index = -1
			reset_knob()
	
	elif event is InputEventScreenDrag and event.index == touch_index:
		_update_joystick(event.position)

func _update_joystick(touch_pos: Vector2) -> void:
	var diff = touch_pos - center
	if diff.length() > radius:
		diff = diff.normalized() * radius
	knob.position = center + diff - knob.size / 2.0
	output_vector = diff / radius

func get_output() -> Vector2:
	return output_vector
