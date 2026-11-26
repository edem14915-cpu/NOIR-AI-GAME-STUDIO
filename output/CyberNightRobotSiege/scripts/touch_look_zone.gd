extends Control

signal camera_rotated(delta: Vector2)

var touch_index: int = -1
var last_pos: Vector2 = Vector2.ZERO

func _gui_input(event):
	if event is InputEventScreenTouch:
		if event.pressed and touch_index == -1:
			touch_index = event.index
			last_pos = event.position
		elif not event.pressed and event.index == touch_index:
			touch_index = -1
	elif event is InputEventScreenDrag and event.index == touch_index:
		var diff = event.position - last_pos
		last_pos = event.position
		camera_rotated.emit(diff)
