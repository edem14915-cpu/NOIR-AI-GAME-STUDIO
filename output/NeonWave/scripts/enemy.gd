extends CharacterBody3D

@onready var nav = NavigationAgent3D.new()
@onready var player = null
var speed = 3.0
var hp = 50

func _ready():
    add_child(nav)
    nav.target_position = Vector3.ZERO
    player = get_tree().get_root().find_node("Player", true, false)
    set_physics_process(true)
    add_to_group("enemies")

func _physics_process(delta):
    if not player:
        return
    nav.target_position = player.global_transform.origin
    var dir = (nav.get_next_path_position() - global_transform.origin).normalized()
    velocity = dir * speed
    velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta
    move_and_slide()

func take_damage(amount):
    hp -= amount
    if hp <= 0:
        queue_free()
        GameManager.enemy_killed()
