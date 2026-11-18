extends Node3D

func _ready():
    # Simple fog via environment
    var env = Environment.new()
    env.fog_enabled = true
    env.fog_color = Color(0.05,0.07,0.06)
    env.fog_depth_begin = 10.0
    env.fog_depth_end = 80.0
    get_viewport().environment = env
