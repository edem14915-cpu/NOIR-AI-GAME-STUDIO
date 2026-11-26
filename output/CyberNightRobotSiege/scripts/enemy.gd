extends CharacterBody3D

@export var speed: float = 3.5
@export var health: int = 50
@export var attack_damage: int = 15
@export var attack_rate: float = 1.0

var player: Node3D = null
var attack_cooldown: float = 0.0
var is_dead: bool = false

@onready var mesh = $CSGMesh3D

func _ready():
	add_to_group("enemies")
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]

func _physics_process(delta):
	if is_dead or GameManager.current_state != GameManager.State.PLAYING: return
	
	if not player:
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0: player = players[0]
		return
	
	var dir = (player.global_position - global_position)
	dir.y = 0
	var dist = dir.length()
	dir = dir.normalized()
	
	# Look at player
	if dist > 0.2:
		look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
	
	# Move
	if dist > 1.8:
		velocity.x = dir.x * speed
		velocity.z = dir.z * speed
	else:
		velocity.x = 0
		velocity.z = 0
		# Attack
		attack_cooldown -= delta
		if attack_cooldown <= 0:
			attack_cooldown = attack_rate
			GameManager.take_player_damage(attack_damage)
	
	move_and_slide()

func take_damage(amount: int):
	if is_dead: return
	health -= amount
	
	# Damage flash visual effect
	if mesh:
		var mat = mesh.material_override
		if mat is StandardMaterial3D:
			mat.albedo_color = Color(1, 1, 1)
			get_tree().create_timer(0.08).timeout.connect(func(): if is_instance_valid(mat): mat.albedo_color = Color(0.8, 0.1, 0.1))
	
	if health <= 0:
		die()

func die():
	is_dead = true
	GameManager.register_enemy_killed()
	queue_free()
