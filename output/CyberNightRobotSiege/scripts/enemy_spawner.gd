extends Node3D

@export var enemy_scene: PackedScene
@export var spawn_interval: float = 2.5
var timer: float = 0.0
var spawn_points: Array[Node] = []

func _ready():
	spawn_points = get_children()

func _process(delta):
	if GameManager.current_state != GameManager.State.PLAYING: return
	if GameManager.enemies_spawned >= GameManager.wave_enemy_counts[clamp(GameManager.current_wave - 1, 0, 2)]:
		return
	
	timer += delta
	if timer >= spawn_interval:
		timer = 0.0
		spawn_enemy()

func spawn_enemy():
	if spawn_points.size() == 0 or not enemy_scene: return
	var point = spawn_points.pick_random()
	var enemy = enemy_scene.instantiate()
	enemy.global_position = point.global_position
	get_parent().add_child(enemy)
	GameManager.enemies_spawned += 1
