extends Node2D

@export var coin_scene: PackedScene
@onready var score_label: Label = $CanvasLayer/ScoreLabel
@onready var timer: Timer = $SpawnTimer
@onready var player: CharacterBody2D = $Player

var score: int = 0
var screen_size: Vector2

func _ready() -> void:
	screen_size = get_viewport_rect().size
	player.add_to_group("player")
	timer.timeout.connect(_on_spawn_timer_timeout)
	update_score_ui()
	
	for i in range(6):
		spawn_coin()

func spawn_coin() -> void:
	if coin_scene == null:
		return
	var coin = coin_scene.instantiate()
	var margin := 60.0
	coin.position = Vector2(
		randf_range(margin, screen_size.x - margin),
		randf_range(margin + 120.0, screen_size.y - margin - 100.0)
	)
	coin.collected.connect(_on_coin_collected)
	add_child(coin)

func _on_coin_collected(_coin: Node2D) -> void:
	score += 1
	update_score_ui()
	spawn_coin()

func _on_spawn_timer_timeout() -> void:
	if get_tree().get_nodes_in_group("coins").size() < 12:
		spawn_coin()

func update_score_ui() -> void:
	score_label.text = "Монеты: " + str(score)
