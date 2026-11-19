extends CharacterBody3D

@export var speed: float = 22.0
@export var turn_speed: float = 14.0

func _physics_process(delta: float) -> void:
	var input_x := 0.0
	if Input.is_action_pressed("ui_left"):
		input_x -= 1.0
	if Input.is_action_pressed("ui_right"):
		input_x += 1.0

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var touch_pos = get_viewport().get_mouse_position()
		if touch_pos.x < get_viewport().size.x / 2.0:
			input_x -= 1.0
		else:
			input_x += 1.0

	velocity.x = input_x * turn_speed
	velocity.z = -speed
	move_and_slide()
	global_position.x = clamp(global_position.x, -8.0, 8.0)
