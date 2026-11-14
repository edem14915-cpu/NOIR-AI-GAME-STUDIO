extends Area2D

signal collected(coin: Area2D)

var animation_time: float = 0.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	animation_time = randf_range(0.0, 6.28)

func _process(delta: float) -> void:
	animation_time += delta * 4.0
	queue_redraw()

func _draw() -> void:
	var pulse := 1.0 + sin(animation_time) * 0.12
	draw_circle(Vector2.ZERO, 20.0 * pulse, Color(1.0, 0.84, 0.0))
	draw_circle(Vector2.ZERO, 14.0 * pulse, Color(1.0, 0.96, 0.4))
	draw_circle(Vector2(0, 0), 6.0 * pulse, Color(0.9, 0.7, 0.0))

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		collected.emit(self)
		queue_free()
