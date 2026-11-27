extends CharacterBody3D

@onready var cam = $Camera3D
@onready var ui = get_tree().get_root().find_node("UI", true, false)
@onready var joystick = ui.get_node("Joystick")
@onready var fire_btn = ui.get_node("FireButton")
@onready var reload_btn = ui.get_node("ReloadButton")

var speed = 5.0
var look_sensitivity = 0.003
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
    fire_btn.pressed.connect(_on_fire_pressed)
    reload_btn.pressed.connect(_on_reload_pressed)
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
    var dir = Vector3.ZERO
    # joystick handling (simple: use Input.get_vector for now)
    var joy_x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
    var joy_z = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
    dir = (global_transform.basis.x * joy_x) + (global_transform.basis.z * joy_z)
    dir = dir.normalized()
    velocity.x = dir.x * speed
    velocity.z = dir.z * speed
    velocity.y -= gravity * delta
    move_and_slide()
    _handle_look()

func _handle_look():
    var ev = get_viewport().get_mouse_position()
    var rel = get_viewport().get_mouse_motion()
    if Input.is_action_pressed("ui_touch"):
        rotate_y(-rel.x * look_sensitivity)
        cam.rotate_x(-rel.y * look_sensitivity)
        cam.rotation.x = clamp(cam.rotation.x, deg_to_rad(-80), deg_to_rad(80))

func _on_fire_pressed():
    if GameManager.ammo <= 0:
        return
    GameManager.use_ammo(1)
    var ray = RayCast3D.new()
    add_child(ray)
    ray.target_position = Vector3(0,0,-100)
    ray.enabled = true
    ray.force_raycast_update()
    if ray.is_colliding():
        var obj = ray.get_collider()
        if obj.has_method("take_damage"):
            obj.take_damage(25)
    ray.queue_free()

func _on_reload_pressed():
    GameManager.reload_ammo()

func _on_body_entered(body):
    if body.is_in_group("enemies"):
        GameManager.player_hit(20)
