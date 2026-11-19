extends Node3D

@onready var player: Node3D = $Player
@onready var score_label: Label = $CanvasLayer/ScoreLabel
var score: float = 0.0
var spawn_timer: float = 0.0

func _process(delta: float) -> void:
	if not is_instance_valid(player):
		return
	
	score += delta * 15.0
	score_label.text = "Счет: " + str(int(score))

	spawn_timer += delta
	if spawn_timer > 0.6:
		spawn_timer = 0.0
		_spawn_obstacle()

func _spawn_obstacle() -> void:
	var obs := CSGBox3D.new()
	obs.size = Vector3(randf_range(1.5, 3.0), randf_range(1.5, 3.0), 2.0)
	obs.position = Vector3(randf_range(-7.0, 7.0), obs.size.y / 2.0, player.position.z - 80.0)
	add_child(obs)
