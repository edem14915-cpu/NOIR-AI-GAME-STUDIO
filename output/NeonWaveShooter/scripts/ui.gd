extends CanvasLayer

@onready var hp_bar = $HUD/HPBar
@onready var ammo_label = $HUD/AmmoLabel
@onready var wave_label = $HUD/WaveLabel
@onready var menu = $MenuScreen

func _ready():
    GameManager.connect("hp_changed", self, "_on_hp_changed")
    GameManager.connect("ammo_changed", self, "_on_ammo_changed")
    GameManager.connect("wave_started", self, "_on_wave_started")
    GameManager.connect("state_changed", self, "_on_state_changed")
    _update_all()

func _on_hp_changed(value):
    hp_bar.value = value

func _on_ammo_changed(value):
    ammo_label.text = "AMMO: %d" % value

func _on_wave_started(wave):
    wave_label.text = "WAVE: %d" % wave

func _on_state_changed(state):
    match state:
        GameManager.State.MENU:
            menu.visible = true
        GameManager.State.PLAY:
            menu.visible = false
        GameManager.State.GAMEOVER:
            _show_game_over()
        GameManager.State.VICTORY:
            _show_victory()

func _show_game_over():
    var go = Label.new()
    go.text = "GAME OVER\nTap to Restart"
    go.anchor_center()
    add_child(go)
    go.connect("gui_input", self, "_on_restart_input")

func _show_victory():
    var vic = Label.new()
    vic.text = "VICTORY!\nTap to Restart"
    vic.anchor_center()
    add_child(vic)
    vic.connect("gui_input", self, "_on_restart_input")

func _on_restart_input(event):
    if event is InputEventScreenTouch and event.pressed:
        get_tree().reload_current_scene()

func _update_all():
    hp_bar.max_value = 100
    hp_bar.value = GameManager.hp
    ammo_label.text = "AMMO: %d" % GameManager.ammo
    wave_label.text = "WAVE: %d" % GameManager.wave