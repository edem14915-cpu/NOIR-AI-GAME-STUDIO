extends CharacterBody2D

@export var speed: float = 320.0
var joystick_input: Vector2 = Vector2.ZERO

func _ready() -> void:
	pass

func _draw() -> void:
	# Player Visual representation (Hero Circle with eyes)
	draw_circle(Vector2.ZERO, 24.0, Color(0.2, 0.7, 1.0))
	draw_circle(Vector2.ZERO, 20.0, Color(0.3, 0.8, 1.0))
	# Eyes
	draw_circle(Vector2(-7, -6), 5.0, Color.WHITE)
	draw_circle(Vector2(7, -6), 5.0, Color.WHITE)
	draw_circle(Vector2(-6, -6), 2.5, Color.BLACK)
	draw_circle(Vector2(8, -6), 2.5, Color.BLACK)

func _physics_process(_delta: float) -> void:
	var move_dir = joystick_input
	
	# Fallback keyboard input for desktop testing
	if move_dir == Vector2.ZERO:
		move_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	velocity = move_dir * speed
	move_and_slide()
	
	# Clamp player inside screen limits
	position.x = clamp(position.x, 30.0, 510.0)
	position.y = clamp(position.y, 100.0, 750.0)

func update_joystick_input(vec: Vector2) -> void:
	joystick_input = vec
