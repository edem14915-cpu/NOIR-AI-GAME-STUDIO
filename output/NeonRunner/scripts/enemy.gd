extends CharacterBody2D

@export var speed: float = 90.0
@export var patrol_distance: float = 140.0

var start_x: float = 0.0
var direction: int = 1

@onready var hitbox: Area2D = $Hitbox

func _ready() -> void:
	start_x = position.x
	hitbox.body_entered.connect(_on_hitbox_body_entered)

func _physics_process(delta: float) -> void:
	if GameManager.current_state != GameManager.State.PLAYING:
		return

	velocity.x = direction * speed
	if not is_on_floor():
		velocity.y += 980.0 * delta

	move_and_slide()

	if abs(position.x - start_x) >= patrol_distance or is_on_wall():
		direction *= -1

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		if body.global_position.y < global_position.y - 12:
			body.velocity.y = -380.0
			GameManager.add_score(100)
			queue_free()
		else:
			body.take_damage(1)
