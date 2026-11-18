extends Control

# Simple virtual joystick for left side of screen
var _dragging = false
var _input_vector = Vector2.ZERO

func _gui_input(event):
    if event is InputEventScreenTouch:
        if event.pressed:
            _dragging = true
            _update_input(event.position)
        else:
            _dragging = false
            _input_vector = Vector2.ZERO
    elif event is InputEventScreenDrag and _dragging:
        _update_input(event.position)

func _update_input(pos):
    var radius = 100.0
    var center = Vector2(150, get_viewport_rect().size.y - 150)
    var delta = pos - center
    _input_vector = delta.clamped(radius) / radius

func get_input():
    return _input_vector
