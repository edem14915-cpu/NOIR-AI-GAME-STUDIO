extends Node
signal state_changed(new_state)
signal hp_changed(value)
signal ammo_changed(value)
signal wave_started(num)
enum {MENU,PLAY,PAUSE,GAMEOVER,VICTORY}
var state = MENU
var hp = 100
var ammo = 30
var wave = 0
var enemies_per_wave = [5,10,15]
func _ready():
    emit_signal("state_changed",state)
    emit_signal("hp_changed",hp)
    emit_signal("ammo_changed",ammo)
func start_game():
    state = PLAY
    hp = 100
    ammo = 30
    wave = 0
    emit_signal("state_changed",state)
    next_wave()
func next_wave():
    wave += 1
    if wave > enemies_per_wave.size():
        state = VICTORY
        emit_signal("state_changed",state)
        return
    emit_signal("wave_started",wave)
    var count = enemies_per_wave[wave-1]
    for i in range(count):
        var e = load("res://scenes/Enemy.tscn").instantiate()
        e.global_transform.origin = Vector3(randf()*30-15,1,randf()*30-15)
        get_tree().current_scene.add_child(e)
func player_hit(damage):
    hp = max(hp-damage,0)
    emit_signal("hp_changed",hp)
    if hp==0:
        state=GAMEOVER
        emit_signal("state_changed",state)
func consume_ammo(amount):
    ammo = max(ammo-amount,0)
    emit_signal("ammo_changed",ammo)
func reload():
    ammo = 30
    emit_signal("ammo_changed",ammo)