extends Node

signal state_changed(new_state)
signal hp_changed(value)
signal ammo_changed(value)
signal wave_started(wave_number)

enum State { MENU, PLAY, PAUSE, GAMEOVER, VICTORY }
var current_state = State.MENU
var hp = 100
var ammo = 30
var wave = 0
var enemies_remaining = 0

func _ready():
    emit_signal("state_changed", current_state)
    emit_signal("hp_changed", hp)
    emit_signal("ammo_changed", ammo)
    emit_signal("wave_started", wave)

func start_game():
    hp = 100
    ammo = 30
    wave = 0
    _next_wave()
    _set_state(State.PLAY)

func _set_state(state):
    current_state = state
    emit_signal("state_changed", current_state)

func _next_wave():
    wave += 1
    emit_signal("wave_started", wave)
    match wave:
        1:
            enemies_remaining = 5
        2:
            enemies_remaining = 10
        3:
            enemies_remaining = 15
        _:
            _set_state(State.VICTORY)
            return
    for i in enemies_remaining:
        var enemy_scene = preload("res://scenes/Enemy.tscn")
        var enemy = enemy_scene.instantiate()
        get_tree().root.get_node("/root/Main/Level1").add_child(enemy)
        enemy.global_transform.origin = Vector3(randi_range(-20,20),1,randi_range(-20,20))

func enemy_killed():
    enemies_remaining -= 1
    if enemies_remaining <= 0:
        _next_wave()

func player_hit(damage):
    hp -= damage
    emit_signal("hp_changed", hp)
    if hp <= 0:
        _set_state(State.GAMEOVER)

func fire_weapon():
    if ammo > 0:
        ammo -= 1
        emit_signal("ammo_changed", ammo)
        # spawn bullet (simple raycast)
        var from = get_tree().root.get_node("/root/Main/Player/Camera3D").global_transform.origin
        var to = from + -get_tree().root.get_node("/root/Main/Player/Camera3D").global_transform.basis.z * 100
        var space = get_world_3d().direct_space_state
        var result = space.intersect_ray(from, to, [], 1)
        if result and result.collider.is_in_group("enemies"):
            result.collider.take_damage(50)

func reload_weapon():
    ammo = 30
    emit_signal("ammo_changed", ammo)