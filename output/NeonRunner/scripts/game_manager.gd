extends Node

signal score_changed(new_score)
signal hp_changed(new_hp)
signal state_changed(new_state)

enum State { MENU, PLAYING, GAMEOVER, VICTORY }

var current_state: int = State.MENU
var score: int = 0
var max_hp: int = 3
var current_hp: int = 3
var current_level: int = 1
var max_levels: int = 3

func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	change_state(State.MENU)

func start_game() -> void:
	score = 0
	current_hp = max_hp
	current_level = 1
	score_changed.emit(score)
	hp_changed.emit(current_hp)
	change_state(State.PLAYING)

func add_score(amount: int) -> void:
	if current_state != State.PLAYING:
		return
	score += amount
	score_changed.emit(score)

func take_damage(amount: int) -> void:
	if current_state != State.PLAYING:
		return
	current_hp -= amount
	if current_hp < 0:
		current_hp = 0
	hp_changed.emit(current_hp)
	if current_hp <= 0:
		change_state(State.GAMEOVER)

func level_completed() -> void:
	if current_state != State.PLAYING:
		return
	if current_level < max_levels:
		current_level += 1
		get_tree().reload_current_scene()
	else:
		change_state(State.VICTORY)

func change_state(new_state: int) -> void:
	current_state = new_state
	state_changed.emit(current_state)
