extends Node

signal hp_changed(hp: int, max_hp: int)
signal ammo_changed(current: int, max_ammo: int)
signal wave_changed(current_wave: int, total_waves: int, total_enemies: int)
signal enemy_count_changed(remaining: int)
signal game_over()
signal victory()
signal game_started()

enum State { MENU, PLAYING, GAME_OVER, VICTORY }
var current_state: State = State.MENU

var current_wave: int = 1
var total_waves: int = 3
var wave_total_enemies: int = 5
var enemies_alive: int = 0

var player_hp: int = 100
var max_hp: int = 100
var player_ammo: int = 30
var max_ammo: int = 30

func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS

func start_game() -> void:
	current_state = State.PLAYING
	player_hp = max_hp
	player_ammo = max_ammo
	current_wave = 1
	emit_signal("game_started")
	emit_signal("hp_changed", player_hp, max_hp)
	emit_signal("ammo_changed", player_ammo, max_ammo)
	start_wave(current_wave)

func start_wave(wave: int) -> void:
	current_wave = wave
	match wave:
		1: wave_total_enemies = 5
		2: wave_total_enemies = 8
		3: wave_total_enemies = 12
	enemies_alive = wave_total_enemies
	emit_signal("wave_changed", current_wave, total_waves, wave_total_enemies)
	emit_signal("enemy_count_changed", enemies_alive)

func on_enemy_killed() -> void:
	if current_state != State.PLAYING: return
	enemies_alive = max(0, enemies_alive - 1)
	emit_signal("enemy_count_changed", enemies_alive)
	if enemies_alive == 0:
		if current_wave < total_waves:
			current_wave += 1
			get_tree().create_timer(2.0).timeout.connect(func(): start_wave(current_wave))
		else:
			current_state = State.VICTORY
			emit_signal("victory")

func damage_player(amount: int) -> void:
	if current_state != State.PLAYING: return
	player_hp = max(0, player_hp - amount)
	emit_signal("hp_changed", player_hp, max_hp)
	if player_hp <= 0:
		current_state = State.GAME_OVER
		emit_signal("game_over")

func consume_ammo() -> bool:
	if player_ammo > 0:
		player_ammo -= 1
		emit_signal("ammo_changed", player_ammo, max_ammo)
		return true
	return false

func reload_ammo() -> void:
	player_ammo = max_ammo
	emit_signal("ammo_changed", player_ammo, max_ammo)
