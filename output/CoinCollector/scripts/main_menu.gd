extends Control

@onready var btn_play: Button = $MarginContainer/VBoxContainer/BtnPlay
@onready var btn_exit: Button = $MarginContainer/VBoxContainer/BtnExit

func _ready() -> void:
	btn_play.pressed.connect(_on_play_pressed)
	btn_exit.pressed.connect(_on_exit_pressed)

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()
