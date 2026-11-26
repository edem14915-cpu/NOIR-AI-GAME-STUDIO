extends CanvasLayer

@onready var start_menu: Control = $StartMenu
@onready var game_over_menu: Control = $GameOverMenu
@onready var victory_menu: Control = $VictoryMenu
@onready var hud: Control = $HUD

@onready var hp_label: Label = $HUD/TopBar/HPLabel
@onready var ammo_label: Label = $HUD/TopBar/AmmoLabel
@onready var wave_label: Label = $HUD/TopBar/WaveLabel

@onready var start_btn: Button = $StartMenu/VBox/StartBtn
@onready var restart_go_btn: Button = $GameOverMenu/VBox/RestartBtnGO
@onready var restart_vic_btn: Button = $VictoryMenu/VBox/RestartBtnVic
@onready var shoot_btn: Button = $HUD/ShootBtn
@onready var joystick: Control = $HUD/VirtualJoystick
@onready var touch_look_zone: Control = $HUD/TouchZoneLook

var look_touch_index: int = -1
var last_touch_pos: Vector2 = Vector2.ZERO
var player: Node3D = null

func _ready() -> void:
	start_btn.pressed.connect(_on_start_pressed)
	restart_go_btn.pressed.connect(_on_start_pressed)
	restart_vic_btn.pressed.connect(_on_start_pressed)
	
	shoot_btn.pressed.connect(_on_shoot_pressed)
	
	GameManager.hp_changed.connect(_on_hp_changed)
	GameManager.ammo_changed.connect(_on_ammo_changed)
	GameManager.wave_changed.connect(_on_wave_changed)
	GameManager.enemy_count_changed.connect(_on_enemy_count_changed)
	GameManager.game_over.connect(_on_game_over)
	GameManager.victory.connect(_on_victory)
	
	show_menu()

func _input(event: InputEvent) -> void:
	if GameManager.current_state != GameManager.State.PLAYING: return
	
	if event is InputEventScreenTouch:
		if event.pressed:
			# If touch on right half of screen and not on buttons
			if event.position.x > get_viewport().size.x * 0.45 and look_touch_index == -1:
				look_touch_index = event.index
				last_touch_pos = event.position
		else:
			if event.index == look_touch_index:
				look_touch_index = -1
	
	elif event is InputEventScreenDrag:
		if event.index == look_touch_index:
			var delta = event.position - last_touch_pos
			last_touch_pos = event.position
			get_player().add_look_rotation(delta.x, delta.y)

func get_player() -> Node3D:
	if not player:
		player = get_tree().get_first_node_in_group("player")
	return player

func get_joystick_vector() -> Vector2:
	return joystick.get_output()

func show_menu() -> void:
	hud.visible = false
	start_menu.visible = true
	game_over_menu.visible = false
	victory_menu.visible = false

func _on_start_pressed() -> void:
	start_menu.visible = false
	game_over_menu.visible = false
	victory_menu.visible = false
	hud.visible = true
	GameManager.start_game()

func _on_shoot_pressed() -> void:
	get_player().shoot()

func _on_hp_changed(hp: int, _max_hp: int) -> void:
	hp_label.text = "ЗДОРОВЬЕ: %d" % hp

func _on_ammo_changed(current: int, max_ammo: int) -> void:
	ammo_label.text = "ПАТРОНЫ: %d/%d" % [current, max_ammo]

func _on_wave_changed(current_wave: int, total_waves: int, _total_enemies: int) -> void:
	wave_label.text = "ВОЛНА: %d/%d (ВРАГОВ: %d)" % [current_wave, total_waves, GameManager.enemies_alive]

func _on_enemy_count_changed(remaining: int) -> void:
	wave_label.text = "ВОЛНА: %d/%d (ВРАГОВ: %d)" % [GameManager.current_wave, GameManager.total_waves, remaining]

func _on_game_over() -> void:
	hud.visible = false
	game_over_menu.visible = true

func _on_victory() -> void:
	hud.visible = false
	victory_menu.visible = true
