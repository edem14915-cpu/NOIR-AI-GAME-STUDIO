extends Node3D

@export var enemy_scene: PackedScene
@onready var spawn_points: Node3D = $SpawnPoints
@onready var spawn_timer: Timer = $SpawnTimer

func _ready() -> void:
	GameManager.connect("state_changed", Callable(this_on_state_changed))
	spawn_timer.connect("timeout", Callable(this_on_spawn_timer_timeout))

func this_on_state_changed(state: int) -> void:
	if state == GameManager.State.PLAYING:
		spawn_timer.start()
	else:
		spawn_timer.stop()
		clear_enemies()

func this_on_spawn_timer_timeout() -> void:
	if GameManager.current_state != GameManager.State.PLAYING:
		return
	if GameManager.enemies_remaining_to_spawn > 0:
		spawn_enemy()

func spawn_enemy() -> void:
	if not enemy_scene:
		return
	var points = spawn_points.get_children()
	if points.size() == 0:
		return
	var random_point = points[randi() % points.size()] as Node3D
	var enemy = enemy_scene.instantiate() as Node3D
	enemy.global_position = random_point.global_position
	add_child(enemy)
	GameManager.on_enemy_spawned()

func clear_enemies() -> void:
	for child in get_children():
		if child.is_in_group("enemy"):
			child.queue_free()
