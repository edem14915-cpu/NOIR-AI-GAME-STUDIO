extends CharacterBody3D
@onready var gm = get_node("/root/GameManager")
var speed = 4.0
var health = 50
func _ready():
    add_to_group("enemies")
func _physics_process(delta):
    var player = get_tree().get_root().get_node("Main/Player")
    if not player:
        return
    var dir = (player.global_transform.origin - global_transform.origin).normalized()
    velocity = dir * speed
    move_and_slide()
    if global_transform.origin.distance_to(player.global_transform.origin) < 1.5:
        gm.player_hit(10)
func take_damage(d):
    health -= d
    if health <= 0:
        queue_free()