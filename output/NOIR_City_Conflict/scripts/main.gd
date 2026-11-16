extends Node3D

@onready var main_menu = $CanvasLayer/MainMenu
@onready var hud = $CanvasLayer/HUD
@onready var settings_menu = $CanvasLayer/SettingsMenu
@onready var about_menu = $CanvasLayer/AboutMenu
@onready var player = $Player
@onready var dir_light = $DirectionalLight3D

var is_in_game = false

func _ready():
	$CanvasLayer/MainMenu/VBox/BtnPlay.pressed.connect(_start_game)
	$CanvasLayer/MainMenu/VBox/BtnSettings.pressed.connect(_open_settings)
	$CanvasLayer/MainMenu/VBox/BtnAbout.pressed.connect(_open_about)
	$CanvasLayer/MainMenu/VBox/BtnExit.pressed.connect(func(): get_tree().quit())
	
	$CanvasLayer/HUD/BtnPause.pressed.connect(_open_menu)
	$CanvasLayer/SettingsMenu/VBox/BtnBackSettings.pressed.connect(_close_settings)
	$CanvasLayer/AboutMenu/BtnBackAbout.pressed.connect(func(): about_menu.hide())
	
	$CanvasLayer/SettingsMenu/VBox/BtnPresetLow.pressed.connect(func(): set_graphics(0))
	$CanvasLayer/SettingsMenu/VBox/BtnPresetMed.pressed.connect(func(): set_graphics(1))
	$CanvasLayer/SettingsMenu/VBox/BtnPresetHigh.pressed.connect(func(): set_graphics(2))

func _start_game():
	is_in_game = true
	main_menu.hide()
	hud.show()
	player.set_controls_active(true)

func _open_menu():
	is_in_game = false
	hud.hide()
	main_menu.show()
	player.set_controls_active(false)

func _open_settings():
	settings_menu.show()

func _close_settings():
	settings_menu.hide()

func _open_about():
	about_menu.show()

func set_graphics(level: int):
	match level:
		0: # Low (High FPS Target)
			dir_light.shadow_enabled = false
			get_viewport().scaling_3d_scale = 0.75
		1: # Med
			dir_light.shadow_enabled = true
			get_viewport().scaling_3d_scale = 0.9
		2: # High
			dir_light.shadow_enabled = true
			get_viewport().scaling_3d_scale = 1.0
	_close_settings()
