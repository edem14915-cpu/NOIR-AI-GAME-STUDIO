extends Node2D

var score = 0
@onready var score_label = $UI/ScoreLabel
@onready var game_over_panel = $UI/GameOverPanel
@onready var player = $Player

func _ready():
	game_over_panel.hide()
	update_score()
	for coin in $Coins.get_children():
		coin.collected.connect(_on_coin_collected)

func _on_coin_collected():
	score += 1
	update_score()

func update_score():
	score_label.text = "Coins: " + str(score)

func _on_fall_zone_body_entered(body):
	if body == player:
		game_over()

func game_over():
	player.set_physics_process(false)
	game_over_panel.show()

func _on_restart_button_pressed():
	get_tree().reload_current_scene()
