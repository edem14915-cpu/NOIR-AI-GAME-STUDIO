extends CanvasLayer

@onready var hud: Control = $HUD
@onready var score_label: Label = $HUD/ScoreLabel
@onready var hp_label: Label = $HUD/HPLabel
@onready var level_label: Label = $HUD/LevelLabel
@onready var menu_screen: Control = $MenuScreen
@onready var game_over_screen: Control = $GameOverScreen
@onready var victory_screen: Control = $VictoryScreen

@onready var start_button: Button = $MenuScreen/StartButton
@onready var restart_button: Button = $GameOverScreen/RestartButton
@onready var win_restart_button: Button = $VictoryScreen/WinRestartButton

func _ready() -> void:
	GameManager.score_changed.connect(_on_score_changed)
	GameManager.hp_changed.connect(_on_hp_changed)
	GameManager.state_changed.connect(_on_state_changed)
	
	start_button.pressed.connect(_on_start_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	win_restart_button.pressed.connect(_on_restart_pressed)
	
	_on_state_changed(GameManager.current_state)
	_on_score_changed(GameManager.score)
	_on_hp_changed(GameManager.current_hp)

func _on_score_changed(new_score: int) -> void:
	score_label.text = "SCORE: " + str(new_score)

func _on_hp_changed(new_hp: int) -> void:
	hp_label.text = "HP: " + str(new_hp)

func _on_state_changed(new_state: int) -> void:
	hud.visible = (new_state == GameManager.State.PLAYING)
	menu_screen.visible = (new_state == GameManager.State.MENU)
	game_over_screen.visible = (new_state == GameManager.State.GAMEOVER)
	victory_screen.visible = (new_state == GameManager.State.VICTORY)
	
	if new_state == GameManager.State.PLAYING:
		level_label.text = "LEVEL " + str(GameManager.current_level)

func _on_start_pressed() -> void:
	GameManager.start_game()

func _on_restart_pressed() -> void:
	GameManager.start_game()
	get_tree().reload_current_scene()
