extends CharacterBody2D

@export var speed: float = 450.0
var target_position: Vector2 = Vector2.ZERO
var is_touch_moving: bool = false

func _ready() -> void:
	target_position = position

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:
		target_position = event.position
		is_touch_moving = true
	elif event is InputEventScreenDrag:
		target_position = event.position
		is_touch_moving = true

func _physics_process(_delta: float) -> void:
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if input_dir != Vector2.ZERO:
		is_touch_moving = false
		velocity = input_dir * speed
	elif is_touch_moving:
		var distance := position.distance_to(target_position)
		if distance > 12.0:
			velocity = position.direction_to(target_position) * speed
		else:
			velocity = Vector2.ZERO
			is_touch_moving = false
	else:
		velocity = Vector2.ZERO

	move_and_slide()
	
	var viewport_size := get_viewport_rect().size
	position.x = clamp(position.x, 30.0, viewport_size.x - 30.0)
	position.y = clamp(position.y, 120.0, viewport_size.y - 30.0)
	
	queue_redraw()

func _draw() -> void:
	draw_circle(Vector2.ZERO, 28.0, Color(0.2, 0.65, 1.0))
	draw_circle(Vector2.ZERO, 22.0, Color(0.45, 0.85, 1.0))
