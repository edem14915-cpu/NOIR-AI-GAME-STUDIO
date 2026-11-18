extends CharacterBody2D

const SPEED = 120.0
const SPRINT_MULTIPLIER = 1.5
const MAX_STAMINA = 100.0
const STAMINA_RECOVER_RATE = 20.0
const STAMINA_DRAIN_RATE = 30.0

var stamina = MAX_STAMINA
var is_sprinting = false

func initialize():
    # Called from main scene
    set_process(true)
    set_physics_process(true)

func _physics_process(delta):
    var input_vector = Vector2.ZERO
    input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
    input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
    if input_vector != Vector2.ZERO:
        input_vector = input_vector.normalized()
        var current_speed = SPEED
        if is_sprinting and stamina > 0:
            current_speed *= SPRINT_MULTIPLIER
            stamina = max(stamina - STAMINA_DRAIN_RATE * delta, 0)
        else:
            is_sprinting = false
        velocity = input_vector * current_speed
    else:
        velocity = Vector2.ZERO
        if stamina < MAX_STAMINA:
            stamina = min(stamina + STAMINA_RECOVER_RATE * delta, MAX_STAMINA)
    move_and_slide()
    $"../UI".update_stamina(stamina / MAX_STAMINA)

func _input(event):
    if event.is_action_pressed("sprint"):
        is_sprinting = true
    elif event.is_action_released("sprint"):
        is_sprinting = false
    if event.is_action_pressed("interact"):
        _interact()
    if event.is_action_pressed("inventory"):
        $"../UI".toggle_inventory()

func _interact():
    var space_state = get_world_2d().direct_space_state
    var result = space_state.intersect_ray(global_position, global_position + Vector2(0,0), [], 1)
    # Placeholder for interaction logic
    pass
