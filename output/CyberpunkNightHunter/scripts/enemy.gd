extends CharacterBody3D

@export var speed: float = 3.5
@export var max_hp: int = 50
@export var attack_damage: int = 15
@export var attack_cooldown: float = 1.0

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D

var hp: int = 50
var player: Node3D = null
var can_attack: bool = true

func _ready() -> void:
	hp = max_hp
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	if GameManager.current_state != GameManager.State.PLAYING: return
	if not player: return
	
	if not is_on_floor():
		velocity.y -= 9.8 * delta
	
	nav_agent.target_position = player.global_position
	var current_pos = global_position
	var next_pos = nav_agent.get_next_path_position()
	
	var dir = (next_pos - current_pos).normalized()
	dir.y = 0
	
	velocity.x = dir.x * speed
	velocity.z = dir.z * speed
	
	if dir.length() > 0.01:
		look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
	
	move_and_slide()
	
	# Melee attack logic
	var dist = global_position.distance_to(player.global_position)
	if dist < 1.6 and can_attack:
		attack_player()

func attack_player() -> void:
	can_attack = false
	GameManager.damage_player(attack_damage)
	get_tree().create_timer(attack_cooldown).timeout.connect(func(): can_attack = true)

func take_damage(amount: int) -> void:
	hp -= amount
	# Flashing red visual when damaged
	var visor = get_node_or_null("MeshInstance3D/Visor")
	if visor:
		visor.scale = Vector3(1.3, 1.3, 1.3)
		get_tree().create_timer(0.1).timeout.connect(func(): visor.scale = Vector3(1, 1, 1))
	
	if hp <= 0:
		die()

func die() -> void:
	GameManager.on_enemy_killed()
	queue_free()
