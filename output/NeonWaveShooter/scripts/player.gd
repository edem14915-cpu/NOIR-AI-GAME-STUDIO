extends CharacterBody3D
@onready var cam = $Camera3D
@onready var gm = get_node("/root/GameManager")
var speed = 8.0
var rot_speed = 0.005
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
func _physics_process(delta):
    var dir = Vector3.ZERO
    if Input.is_action_pressed("ui_left"):
        dir.x -= 1
    if Input.is_action_pressed("ui_right"):
        dir.x += 1
    if Input.is_action_pressed("ui_up"):
        dir.z -= 1
    if Input.is_action_pressed("ui_down"):
        dir.z += 1
    dir = dir.normalized()
    var velocity = dir * speed
    velocity.y -= gravity * delta
    move_and_slide()
func _unhandled_input(event):
    if event is InputEventScreenDrag:
        if event.position.x > get_viewport().size.x/2:
            rotate_y(-event.relative.x * rot_speed)
    if event is InputEventScreenTouch and not event.pressed:
        pass
func fire():
    if gm.ammo<=0:
        return
    gm.consume_ammo(1)
    # simple raycast
    var from = cam.global_transform.origin
    var to = from + -cam.global_transform.basis.z * 100
    var space = get_world_3d().direct_space_state
    var result = space.intersect_ray(from,to, [self])
    if result and result.collider.is_in_group("enemies"):
        result.collider.take_damage(50)
func reload():
    gm.reload()