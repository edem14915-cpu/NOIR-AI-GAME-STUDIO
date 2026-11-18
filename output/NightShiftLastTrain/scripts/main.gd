extends Node2D

func _ready():
    # Initialize game state
    var player = $Player
    player.initialize()
    $UI.setup_ui()
    # Load first mission
    GameState.current_mission = "restore_power"
    $UI.update_task("Восстановить питание станции")
