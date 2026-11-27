extends CharacterBody3D

@export var speed: float = 4.0
@export var hp: float = 50.0
@export var attack_damage: float = 10.0
@export var attack_rate: float = 1.0

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var mesh: Node3D = $RobotMesh

var player: Node3D = null
var attack_timer: float = 0.0

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	if GameManager.current_state != GameManager.State.PLAYING:
		return
		
	if not player:
		player = get_tree().get_first_node_in_group("player")
		if not player: return

	var dist = global_position.distance_to(player.global_position)
	look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
	
	if dist > 1.8:
		var dir = (player.global_position - global_position).normalized()
		velocity.x = dir.x * speed
		velocity.z = dir.z * speed
		if not is_on_floor():
			velocity.y -= 9.8 * delta
		move_and_slide()
	else:
		velocity.x = 0
		velocity.z = 0
		attack_timer -= delta
		if attack_timer <= 0.0:
			attack_player()
			attack_timer = attack_rate

func attack_player() -> void:
	if player and player.has_method("take_damage"):
		player.take_damage(attack_damage)

func take_damage(amount: float) -> void:
	hp -= amount
	# Flash bright red on hit
	var mat = $RobotMesh/Head.get_active_material(0) as StandardMaterial3D
	if mat:
		mat.albedo_color = Color(1, 1, 1)
		await get_tree().create_timer(0.05).timeout
		mat.albedo_color = Color(0.1, 0.1, 0.15)
	
	if hp <= 0.0:
		die()

func die() -> void:
	GameManager.on_enemy_died()
	queue_free()
