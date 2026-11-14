extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var joystick: Control = $UI/Joystick
@onready var score_label: Label = $UI/HUD/ScoreLabel
@onready var win_panel: PanelContainer = $UI/WinPanel
@onready var btn_restart: Button = $UI/WinPanel/VBox/BtnRestart
@onready var btn_menu: Button = $UI/WinPanel/VBox/BtnMenu
@onready var coins_container: Node2D = $Coins

@export var total_coins: int = 10
var current_score: int = 0
var coin_scene_script = preload("res://scripts/coin.gd")

func _ready() -> void:
	win_panel.hide()
	joystick.joystick_vector_changed.connect(player.update_joystick_input)
	btn_restart.pressed.connect(_on_restart_pressed)
	btn_menu.pressed.connect(_on_menu_pressed)
	
	spawn_coins()
	update_score_ui()

func spawn_coins() -> void:
	var spawn_margin = 60.0
	var min_x = spawn_margin
	var max_x = 540.0 - spawn_margin
	var min_y = 120.0
	var max_y = 720.0
	
	for i in range(total_coins):
		var coin = Area2D.new()
		coin.set_script(coin_scene_script)
		
		# Collision shape
		var col = CollisionShape2D.new()
		var shape = CircleShape2D.new()
		shape.radius = 16.0
		col.shape = shape
		coin.add_child(col)
		
		# Random Position
		var random_pos = Vector2(
			randi_range(min_x, max_x),
			randi_range(min_y, max_y)
		)
		coin.position = random_pos
		coin.collected.connect(_on_coin_collected)
		coins_container.add_child(coin)

func _on_coin_collected() -> void:
	current_score += 1
	update_score_ui()
	
	if current_score >= total_coins:
		show_win_screen()

func update_score_ui() -> void:
	score_label.text = "МОНЕТЫ: %d / %d" % [current_score, total_coins]

func show_win_screen() -> void:
	win_panel.show()
	win_panel.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(win_panel, "modulate:a", 1.0, 0.4)

func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()

func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
