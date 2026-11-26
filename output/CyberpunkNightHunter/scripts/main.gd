extends Node3D

@onready var enemy_scene: PackedScene = preload("res://scenes/Enemy.tscn")
@onready var spawners_container: Node3D = $Level1/Spawners

var spawned_in_wave: int = 0
var spawn_timer: Timer

func _ready() -> void:
	GameManager.game_started.connect(_on_game_started)
	GameManager.wave_changed.connect(_on_wave_changed)
	
	spawn_timer = Timer.new()
	spawn_timer.wait_time = 1.5
	spawn_timer.timeout.connect(_spawn_enemy_step)
	add_child(spawn_timer)

func _on_game_started() -> void:
	# Clear existing enemies
	for enemy in get_tree().get_nodes_in_group("enemy"):
		enemy.queue_free()

func _on_wave_changed(wave: int, _total_waves: int, total_enemies: int) -> void:
	spawned_in_wave = 0
	spawn_timer.start()

func _spawn_enemy_step() -> void:
	if GameManager.current_state != GameManager.State.PLAYING: return
	if spawned_in_wave >= GameManager.wave_total_enemies:
		spawn_timer.stop()
		return
	
	var spawners = spawners_container.get_children()
	if spawners.size() == 0: return
	var spawner = spawners[randi() % spawners.size()]
	
	var enemy = enemy_scene.instantiate()
	enemy.global_position = spawner.global_position
	add_child(enemy)
	spawned_in_wave += 1
