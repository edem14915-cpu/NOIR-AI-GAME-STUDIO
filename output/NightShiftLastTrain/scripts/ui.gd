extends CanvasLayer

var stamina_bar
var task_label
var inventory_panel
var inventory_visible = false

func setup_ui():
    stamina_bar = $"StaminaBar"
    task_label = $"TaskLabel"
    inventory_panel = $"InventoryPanel"
    inventory_panel.visible = false

func update_stamina(ratio):
    stamina_bar.value = ratio * 100

func update_task(text):
    task_label.text = text

func toggle_inventory():
    inventory_visible = not inventory_visible
    inventory_panel.visible = inventory_visible

func _process(delta):
    # Update any UI animations if needed
    pass
