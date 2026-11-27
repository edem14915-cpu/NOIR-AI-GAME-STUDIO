extends CanvasLayer

@onready var hp_bar = $HUD/HPBar
@onready var ammo_label = $HUD/AmmoLabel
@onready var wave_label = $HUD/WaveLabel
@onready var menu = $MenuScreen
@onready var start_btn = menu.get_node("StartButton")
@onready var game_over_lbl = menu.get_node("GameOverLabel")
@onready var victory_lbl = menu.get_node("VictoryLabel")

func _ready():
    GameManager.state_changed.connect(_on_state_changed)
    GameManager.hp_changed.connect(_on_hp_changed)
    GameManager.ammo_changed.connect(_on_ammo_changed)
    GameManager.wave_started.connect(_on_wave_started)
    start_btn.pressed.connect(_on_start_pressed)
    _update_ui()

func _on_start_pressed():
    GameManager.start_game()

func _on_state_changed(new_state):
    match new_state:
        GameManager.State.MENU:
            menu.visible = true
            game_over_lbl.visible = false
            victory_lbl.visible = false
        GameManager.State.PLAY:
            menu.visible = false
        GameManager.State.GAMEOVER:
            menu.visible = true
            game_over_lbl.visible = true
        GameManager.State.VICTORY:
            menu.visible = true
            victory_lbl.visible = true
        _:
            pass

func _on_hp_changed(value):
    hp_bar.value = value

func _on_ammo_changed(value):
    ammo_label.text = "Ammo: %d" % value

func _on_wave_started(wave_number):
    wave_label.text = "Wave: %d" % wave_number

func _update_ui():
    hp_bar.max_value = 100
    hp_bar.value = GameManager.hp
    ammo_label.text = "Ammo: %d" % GameManager.ammo
    wave_label.text = "Wave: %d" % GameManager.wave
