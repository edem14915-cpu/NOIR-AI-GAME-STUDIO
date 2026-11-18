extends CharacterBody3D

const SPEED = 5.0
const RUN_MULTIPLIER = 1.5
const JUMP_VELOCITY = 4.5

var velocity = Vector3.ZERO
var is_running = false

onready var cam = $Camera3D
onready var joystick = $JoystickUI

func _physics_process(delta):
    var input_dir = Vector2.ZERO
    # Mobile joystick provides a Vector2 via a custom signal
    if joystick.has_method("get_input"):
        input_dir = joystick.get_input()
    var direction = (cam.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
    var speed = SPEED * (RUN_MULTIPLIER if is_running else 1)
    velocity.x = direction.x * speed
    velocity.z = direction.z * speed
    if not is_on_floor():
        velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta
    else:
        if Input.is_action_just_pressed("jump"):
            velocity.y = JUMP_VELOCITY
    move_and_slide()

func _input(event):
    if event.is_action_pressed("run"):
        is_running = true
    elif event.is_action_released("run"):
        is_running = false
