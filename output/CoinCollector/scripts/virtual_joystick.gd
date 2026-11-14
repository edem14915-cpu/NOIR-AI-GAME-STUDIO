extends Control

signal joystick_vector_changed(vector: Vector2)

var output_vector: Vector2 = Vector2.ZERO
var is_pressed: bool = false
var touch_index: int = -1

@export var radius: float = 80.0
@export var handle_radius: float = 30.0

var handle_pos: Vector2 = Vector2.ZERO

func _ready() -> void:
	size = Vector2(radius * 2, radius * 2)
	set_process_input(true)

func _draw() -> void:
	var center = size / 2.0
	# Base circle
	draw_circle(center, radius, Color(1, 1, 1, 0.2))
	draw_arc(center, radius, 0, TAU, 32, Color(1, 1, 1, 0.5), 3.0)
	# Handle circle
	draw_circle(center + handle_pos, handle_radius, Color(1, 0.84, 0.0, 0.8))
	draw_arc(center + handle_pos, handle_radius, 0, TAU, 24, Color(1, 1, 1, 0.9), 2.0)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and not is_pressed:
			is_pressed = true
			touch_index = event.index
			_update_handle(event.position)
		elif not event.pressed and event.index == touch_index:
			_reset_handle()
	
	elif event is InputEventScreenDrag and is_pressed and event.index == touch_index:
		_update_handle(event.position)

func _update_handle(touch_pos: Vector2) -> void:
	var center = size / 2.0
	var offset = touch_pos - center
	if offset.length() > radius:
		offset = offset.normalized() * radius
	handle_pos = offset
	output_vector = handle_pos / radius
	joystick_vector_changed.emit(output_vector)
	queue_redraw()

func _reset_handle() -> void:
	is_pressed = false
	touch_index = -1
	handle_pos = Vector2.ZERO
	output_vector = Vector2.ZERO
	joystick_vector_changed.emit(output_vector)
	queue_redraw()
