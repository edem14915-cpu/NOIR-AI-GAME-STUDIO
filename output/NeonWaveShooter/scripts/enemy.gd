extends CharacterBody3D

@onready var nav = $NavigationAgent3D
var hp = 50
var damage = 20
var player_path = "/root/Main/Player"

func _ready():
    add_to_group("enemies")
    nav.target_position = get_node(player_path).global_transform.origin
    set_process(true)
    GameManager.connect("state_changed", self, "_on_state_changed")

func _process(delta):
    if GameManager.current_state != GameManager.State.PLAY:
        return
    nav.target_position = get_node(player_path).global_transform.origin
    var direction = (nav.get_next_path_position() - global_transform.origin).normalized()
    velocity = direction * nav.max_speed
    move_and_slide()
    if global_transform.origin.distance_to(get_node(player_path).global_transform.origin) < 1.5:
        GameManager.player_hit(damage)

func take_damage(amount):
    hp -= amount
    if hp <= 0:
        queue_free()
        GameManager.enemy_killed()