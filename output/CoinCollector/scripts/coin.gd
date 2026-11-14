extends Area2D

signal collected

var is_collected: bool = false
var float_offset: float = 0.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_start_hover_animation()

func _draw() -> void:
	# Outer gold circle
	draw_circle(Vector2.ZERO, 16.0, Color(1, 0.84, 0.0))
	# Inner dark gold ring
	draw_circle(Vector2.ZERO, 12.0, Color(0.9, 0.7, 0.0))
	# Shine highlight
	draw_circle(Vector2(-4, -4), 4.0, Color(1, 1, 0.6))

func _start_hover_animation() -> void:
	var tween = create_tween().set_loops()
	tween.tween_property(self, "position:y", position.y - 6.0, 0.6).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "position:y", position.y + 6.0, 0.6).set_trans(Tween.TRANS_SINE)

func _on_body_entered(body: Node2D) -> void:
	if is_collected or not body.is_in_group("player"):
		return
	
	is_collected = true
	collected.emit()
	
	# Collection Animation: scale up and fade out
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "scale", Vector2(1.8, 1.8), 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 0.0, 0.25)
	tween.chain().tween_callback(queue_free)
