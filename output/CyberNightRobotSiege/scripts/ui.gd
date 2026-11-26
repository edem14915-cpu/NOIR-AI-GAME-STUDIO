extends CanvasLayer

@onready var hp_label = $HUD/HPLabel
@onready var ammo_label = $HUD/AmmoLabel
@onready var wave_label = $HUD/WaveLabel
@onready var enemies_label = $HUD/EnemiesLabel

@onready var start_menu = $StartMenu
@onready var game_over_screen = $GameOverScreen
@onready var victory_screen = $VictoryScreen
@onready var hud = $HUD
@onready var touch_controls = $TouchControls

@onready var joystick = $TouchControls/VirtualJoystick
@onready var look_zone = $TouchControls/TouchLookZone
@onready var shoot_button = $TouchControls/ShootButton
@onready var reload_button = $TouchControls/ReloadButton

func _ready():
	GameManager.hp_changed.connect(_on_hp_changed)
	GameManager.ammo_changed.connect(_on_ammo_changed)
	GameManager.wave_changed.connect(_on_wave_changed)
	GameManager.enemies_left_changed.connect(_on_enemies_left_changed)
	GameManager.state_changed.connect(_on_state_changed)
	
	# Setup Mobile Shoot Button Touch handlers
	shoot_button.button_down.connect(func(): _on_shoot_down(true))
	shoot_button.button_up.connect(func(): _on_shoot_down(false))
	reload_button.pressed.connect(func(): GameManager.reload())
	
	$StartMenu/StartButton.pressed.connect(func(): GameManager.start_game())
	$GameOverScreen/RetryButton.pressed.connect(func(): GameManager.start_game())
	$VictoryScreen/RestartButton.pressed.connect(func(): GameManager.start_game())
	
	_on_state_changed(GameManager.State.MENU)

func _on_hp_changed(hp, max_hp):
	hp_label.text = "HP: %d / %d" % [hp, max_hp]

func _on_ammo_changed(ammo, max_clip):
	ammo_label.text = "AMMO: %d | %d" % [ammo, GameManager.reserve_ammo]

func _on_wave_changed(wave, total):
	wave_label.text = "WAVE: %d / %d" % [wave, total]

func _on_enemies_left_changed(count):
	enemies_label.text = "ROBOTS: %d" % count

func _on_state_changed(new_state):
	start_menu.visible = (new_state == GameManager.State.MENU)
	game_over_screen.visible = (new_state == GameManager.State.GAMEOVER)
	victory_screen.visible = (new_state == GameManager.State.WIN)
	hud.visible = (new_state == GameManager.State.PLAYING)
	touch_controls.visible = (new_state == GameManager.State.PLAYING)

func _on_shoot_down(pressed: bool):
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		players[0].set_shooting(pressed)
