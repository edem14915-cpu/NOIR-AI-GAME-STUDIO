extends CharacterBody3D

@onready var cam = $Camera3D
@onready var joystick = get_node("/root/Main/UI/Joystick")
@onready var fire_btn = get_node("/root/Main/UI/FireButton")
@onready var reload_btn = get_node("/root/Main/UI/ReloadButton")

var speed = 6.0
var look_sensitivity = 0.003
var velocity = Vector3.ZERO

func _ready():
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
    GameManager.connect("state_changed", self, "_on_state_changed")
    GameManager.connect("hp_changed", self, "_on_hp_changed")
    GameManager.connect("ammo_changed", self, "_on_ammo_changed")
    GameManager.connect("wave_started", self, "_on_wave_started")

func _process(delta):
    if GameManager.current_state != GameManager.State.PLAY:
        return
    _handle_movement(delta)
    _handle_look(delta)

func _handle_movement(delta):
    var input_dir = Vector2.ZERO
    input_dir.x = joystick.get_node("JoystickKnob").position.x / 100.0
    input_dir.y = joystick.get_node("JoystickKnob").position.y / 100.0
    var dir = Vector3(input_dir.x, 0, input_dir.y)
    if dir.length() > 1:
        dir = dir.normalized()
    var basis = cam.global_transform.basis
    var forward = -basis.z
    var right = basis.x
    var move = (forward * dir.z + right * dir.x) * speed
    velocity.x = move.x
    velocity.z = move.z
    velocity = move_and_slide(velocity, Vector3.UP)

func _handle_look(delta):
    if Input.is_action_pressed("ui_touch"):
        var ev = Input.get_last_mouse_speed()
        rotate_y(-ev.x * look_sensitivity)
        cam.rotate_x(-ev.y * look_sensitivity)
        cam.rotation_degrees.x = clamp(cam.rotation_degrees.x, -80, 80)

func _on_state_changed(state):
    set_process(state == GameManager.State.PLAY)

func _on_hp_changed(value):
    pass # HUD updates via UI script

func _on_ammo_changed(value):
    pass

func _on_wave_started(wave):
    pass