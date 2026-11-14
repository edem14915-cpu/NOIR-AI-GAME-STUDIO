extends Node3D

@onready var player = $Player
@onready var main_menu = $UI/MainMenu
@onready var hud = $UI/HUD
@onready var start_button = $UI/MainMenu/StartButton
@onready var jump_button = $UI/HUD/JumpButton
@onready var interact_button = $UI/HUD/InteractButton
@onready var info_label = $UI/HUD/InfoLabel

func _ready() -> void:
	hud.visible = false
	main_menu.visible = true
	player.is_active = false
	start_button.pressed.connect(_on_start_pressed)
	jump_button.pressed.connect(_on_jump_pressed)
	interact_button.pressed.connect(_on_interact_pressed)

func _on_start_pressed() -> void:
	main_menu.visible = false
	hud.visible = true
	player.is_active = true
	info_label.text = "Swipe Right = Look | Touch Left = Move"
	var timer = get_tree().create_timer(4.0)
	timer.timeout.connect(func(): if is_instance_valid(info_label) and info_label.text.begins_with("Swipe"): info_label.text = "")

func _on_jump_pressed() -> void:
	player.do_jump()

func _on_interact_pressed() -> void:
	var text = player.do_interact()
	info_label.text = text
	var timer = get_tree().create_timer(2.0)
	timer.timeout.connect(func(): if is_instance_valid(info_label) and info_label.text == text: info_label.text = "")
