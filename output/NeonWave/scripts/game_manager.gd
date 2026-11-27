extends Node

signal state_changed(new_state)
signal hp_changed(value)
signal ammo_changed(value)
signal wave_started(wave_number)

enum State { MENU, PLAY, PAUSE, GAMEOVER, VICTORY }
var state = State.MENU
var hp = 100
var ammo = 30
var wave = 0
var wave_enemies = [5,10,15]
var enemies_alive = 0

func _ready():
    emit_signal("state_changed", state)
    emit_signal("hp_changed", hp)
    emit_signal("ammo_changed", ammo)

func start_game():
    state = State.PLAY
    hp = 100
    ammo = 30
    wave = 0
    emit_signal("state_changed", state)
    start_next_wave()

func start_next_wave():
    if wave >= wave_enemies.size():
        state = State.VICTORY
        emit_signal("state_changed", state)
        return
    wave += 1
    enemies_alive = wave_enemies[wave-1]
    emit_signal("wave_started", wave)
    # spawn enemies via Level1 spawner (simple call)
    var level = get_tree().get_root().find_node("Level1", true, false)
    if level:
        level.call("spawn_enemies", enemies_alive)

func enemy_killed():
    enemies_alive -= 1
    if enemies_alive <= 0:
        start_next_wave()

func player_hit(damage):
    hp = max(hp - damage, 0)
    emit_signal("hp_changed", hp)
    if hp <= 0:
        state = State.GAMEOVER
        emit_signal("state_changed", state)

func use_ammo(amount):
    ammo = max(ammo - amount, 0)
    emit_signal("ammo_changed", ammo)
    if ammo == 0:
        # auto reload (simple)
        reload_ammo()

func reload_ammo():
    ammo = 30
    emit_signal("ammo_changed", ammo)
