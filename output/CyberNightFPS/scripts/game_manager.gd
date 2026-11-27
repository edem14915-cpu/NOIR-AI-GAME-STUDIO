extends Node

signal state_changed(new_state)
signal hp_changed(hp, max_hp)
signal ammo_changed(ammo, reserve)
signal wave_started(wave_num)
signal wave_ended(wave_num)
signal enemy_killed()

enum State { MENU, PLAYING, GAMEOVER, VICTORY }

var current_state: State = State.MENU
var current_wave: int = 0
var total_waves: int = 3
var enemies_alive: int = 0
var enemies_remaining_to_spawn: int = 0

var player_max_hp: float = 100.0
var player_hp: float = 100.0
var magazine_size: int = 30
var current_ammo: int = 30
var reserve_ammo: int = 120

func _ready() -> void:
	pass

func start_game() -> void:
	player_hp = player_max_hp
	current_ammo = magazine_size
	reserve_ammo = 120
	current_wave = 0
	set_state(State.PLAYING)
	start_next_wave()

func set_state(new_state: State) -> void:
	current_state = new_state
	emit_signal("state_changed", current_state)

func start_next_wave() -> void:
	if current_wave >= total_waves:
		set_state(State.VICTORY)
		return
	
	current_wave += 1
	switch current_wave:
		1:
			enemies_remaining_to_spawn = 5
		2:
			enemies_remaining_to_spawn = 10
		3:
			enemies_remaining_to_spawn = 15
	
	enemies_alive = 0
	emit_signal("wave_started", current_wave)
	emit_signal("hp_changed", player_hp, player_max_hp)
	emit_signal("ammo_changed", current_ammo, reserve_ammo)

func on_enemy_spawned() -> void:
	enemies_alive += 1
	enemies_remaining_to_spawn -= 1

func on_enemy_died() -> void:
	enemies_alive = max(0, enemies_alive - 1)
	emit_signal("enemy_killed")
	if enemies_alive == 0 and enemies_remaining_to_spawn <= 0:
		emit_signal("wave_ended", current_wave)
		if current_wave >= total_waves:
			set_state(State.VICTORY)
		else:
			call_deferred("_delay_next_wave")

func _delay_next_wave() -> void:
	await get_tree().create_timer(3.0).timeout
	if current_state == State.PLAYING:
		start_next_wave()

func damage_player(amount: float) -> void:
	if current_state != State.PLAYING:
		return
	player_hp = max(0.0, player_hp - amount)
	emit_signal("hp_changed", player_hp, player_max_hp)
	if player_hp <= 0:
		set_state(State.GAMEOVER)

func consume_ammo() -> bool:
	if current_ammo > 0:
		current_ammo -= 1
		emit_signal("ammo_changed", current_ammo, reserve_ammo)
		return true
	return false

func reload_weapon() -> void:
	if current_ammo >= magazine_size or reserve_ammo <= 0:
		return
	var needed = magazine_size - current_ammo
	var to_load = min(needed, reserve_ammo)
	current_ammo += to_load
	reserve_ammo -= to_load
	emit_signal("ammo_changed", current_ammo, reserve_ammo)
