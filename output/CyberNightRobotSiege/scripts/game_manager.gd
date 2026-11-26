extends Node

signal hp_changed(current_hp, max_hp)
signal ammo_changed(current_ammo, max_ammo)
signal wave_changed(current_wave, total_waves)
signal enemies_left_changed(count)
signal state_changed(new_state)

enum State { MENU, PLAYING, GAMEOVER, WIN }
var current_state: State = State.MENU

var player_hp: int = 100
var player_max_hp: int = 100
var ammo_in_clip: int = 30
var max_clip: int = 30
var reserve_ammo: int = 150

var current_wave: int = 0
var total_waves: int = 3
var enemies_remaining: int = 0
var enemies_spawned: int = 0
var wave_enemy_counts = [5, 8, 12]

func start_game():
	player_hp = player_max_hp
	ammo_in_clip = max_clip
	reserve_ammo = 150
	current_wave = 0
	set_state(State.PLAYING)
	hp_changed.emit(player_hp, player_max_hp)
	ammo_changed.emit(ammo_in_clip, max_clip)
	start_next_wave()

func set_state(new_state: State):
	current_state = new_state
	state_changed.emit(new_state)
	if new_state == State.PLAYING:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func start_next_wave():
	if current_state != State.PLAYING: return
	current_wave += 1
	if current_wave > total_waves:
		set_state(State.WIN)
		return
	
	enemies_remaining = wave_enemy_counts[current_wave - 1]
	enemies_spawned = 0
	wave_changed.emit(current_wave, total_waves)
	enemies_left_changed.emit(enemies_remaining)

func register_enemy_killed():
	if current_state != State.PLAYING: return
	enemies_remaining = max(0, enemies_remaining - 1)
	enemies_left_changed.emit(enemies_remaining)
	if enemies_remaining <= 0:
		get_tree().create_timer(2.0).timeout.connect(start_next_wave)

func take_player_damage(amount: int):
	if current_state != State.PLAYING: return
	player_hp = max(0, player_hp - amount)
	hp_changed.emit(player_hp, player_max_hp)
	if player_hp <= 0:
		set_state(State.GAMEOVER)

func consume_ammo() -> bool:
	if ammo_in_clip > 0:
		ammo_in_clip -= 1
		ammo_changed.emit(ammo_in_clip, max_clip)
		return true
	return false

func reload():
	if ammo_in_clip < max_clip and reserve_ammo > 0:
		var needed = max_clip - ammo_in_clip
		var reload_amount = min(needed, reserve_ammo)
		ammo_in_clip += reload_amount
		reserve_ammo -= reload_amount
		ammo_changed.emit(ammo_in_clip, max_clip)
