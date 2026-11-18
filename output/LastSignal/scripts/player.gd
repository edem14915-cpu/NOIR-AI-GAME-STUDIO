extends CharacterBody3D

const SPEED = 5.0
const RUN_MULTIPLIER = 1.5
const MOUSE_SENSITIVITY = 0.003

var velocity: Vector3 = Vector3.ZERO
var look_yaw: float = 0.0
var look_pitch: float = 0.0

func _ready():
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta):
    _handle_touch_input(delta)
    _update_camera(delta)

func _physics_process(delta):
    var input_dir = Vector3.ZERO
    if Input.is_action_pressed("move_forward"):
        input_dir -= transform.basis.z
    if Input.is_action_pressed("move_back"):
        input_dir += transform.basis.z
    if Input.is_action_pressed("move_left"):
        input_dir -= transform.basis.x
    if Input.is_action_pressed("move_right"):
        input_dir += transform.basis.x
    input_dir = input_dir.normalized()
    var speed = SPEED
    if Input.is_action_pressed("run"):
        speed *= RUN_MULTIPLIER
    velocity.x = input_dir.x * speed
    velocity.z = input_dir.z * speed
    velocity = move_and_slide(velocity, Vector3.UP)

func _handle_touch_input(delta):
    # Simple touch look: first finger drags to rotate camera
    if Input.get_touch_count() > 0:
        var touch = Input.get_touch(0)
        if touch.pressed:
            look_yaw -= touch.delta.x * MOUSE_SENSITIVITY
            look_pitch -= touch.delta.y * MOUSE_SENSITIVITY
            look_pitch = clamp(look_pitch, deg_to_rad(-80), deg_to_rad(80))

func _update_camera(delta):
    var cam = $Camera
    cam.rotation = Vector3(look_pitch, look_yaw, 0)
    rotation.y = look_yaw
