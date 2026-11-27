extends CharacterBody2D

const SPEED = 280.0
const JUMP_VELOCITY = -520.0
const GRAVITY = 1200.0

var is_left_pressed: bool = false
var is_right_pressed: bool = false
var jump_requested: bool = false

func _ready() -> void:
	var ui = get_node_or_null("/root/Main/UI")
	if ui:
		var left_btn = ui.get_node_or_null("HUD/TouchControls/LeftBtn")
		var right_btn = ui.get_node_or_null("HUD/TouchControls/RightBtn")
		var jump_btn = ui.get_node_or_null("HUD/TouchControls/JumpBtn")
		if left_btn:
			left_btn.button_down.connect(func(): is_left_pressed = true)
			left_btn.button_up.connect(func(): is_left_pressed = false)
		if right_btn:
			right_btn.button_down.connect(func(): is_right_pressed = true)
			right_btn.button_up.connect(func(): is_right_pressed = false)
		if jump_btn:
			jump_btn.pressed.connect(func(): jump_requested = true)

func _physics_process(delta: float) -> void:
	if GameManager.current_state != GameManager.State.PLAYING:
		velocity = Vector2.ZERO
		return

	if not is_on_floor():
		velocity.y += GRAVITY * delta

	if (Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_up") or jump_requested) and is_on_floor():
		velocity.y = JUMP_VELOCITY
	jump_requested = false

	var direction := Input.get_axis("ui_left", "ui_right")
	if is_left_pressed:
		direction -= 1.0
	if is_right_pressed:
		direction += 1.0
	direction = clamp(direction, -1.0, 1.0)

	if direction != 0.0:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * 8.0 * delta)

	move_and_slide()

	if position.y > 1200:
		take_damage(3)

func take_damage(amount: int) -> void:
	GameManager.take_damage(amount)
	velocity.y = JUMP_VELOCITY * 0.4
