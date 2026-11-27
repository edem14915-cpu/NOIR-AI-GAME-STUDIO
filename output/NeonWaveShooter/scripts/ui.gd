extends CanvasLayer
@onready var hp_bar = $HUD/HPBar
@onready var ammo_label = $HUD/AmmoLabel
@onready var wave_label = $HUD/WaveLabel
@onready var menu = $MenuScreen
@onready var game_over = $GameOverScreen
@onready var victory = $VictoryScreen
@onready var start_btn = $MenuScreen/StartBtn
@onready var fire_btn = $FireBtn
@onready var reload_btn = $ReloadBtn
func _ready():
    var gm = get_node("/root/GameManager")
    gm.connect("hp_changed",Callable(self,"_on_hp_changed"))
    gm.connect("ammo_changed",Callable(self,"_on_ammo_changed"))
    gm.connect("wave_started",Callable(self,"_on_wave_started"))
    gm.connect("state_changed",Callable(self,"_on_state_changed"))
    start_btn.connect("pressed",Callable(gm,"start_game"))
    fire_btn.connect("pressed",Callable(get_node("/root/Main/Player"),"fire"))
    reload_btn.connect("pressed",Callable(get_node("/root/Main/Player"),"reload"))
    _on_state_changed(gm.state)
func _on_hp_changed(value):
    hp_bar.value = value
func _on_ammo_changed(value):
    ammo_label.text = "Ammo: %d" % value
func _on_wave_started(num):
    wave_label.text = "Wave: %d" % num
func _on_state_changed(state):
    menu.visible = state == gm.MENU
    game_over.visible = state == gm.GAMEOVER
    victory.visible = state == gm.VICTORY