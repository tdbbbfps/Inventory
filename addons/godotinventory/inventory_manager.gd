extends Node

const SAVE_PATH : String = "user://inventory_data.res"
var autosave_on_quit : bool = true
var inventory : Inventory:
	set(value):
		inventory = value
signal inventory_saved
signal inventory_loaded

func _ready() -> void:
	ProjectSettings.set_setting("application/config/auto_accept_quit", !autosave_on_quit)

## Load inventory data.
func load_inventory() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		push_error("File doesn't exist!")
		return
	var file = ResourceLoader.load(SAVE_PATH) as InventorySave
	inventory.max_slots = file.max_slots
	var temp : Array[Dictionary] = file.inventory
	for i in range(temp.size()):
		if temp[i]["item"] != null:
			inventory.add_item_to_index(i, temp[i]["item"], temp[i]["quantity"])
	
	emit_signal("inventory_loaded")

func save_inventory() -> void:
	var file_to_save : InventorySave = InventorySave.new()
	var data_to_save : Array[Dictionary]
	for slot in inventory.slots:
		data_to_save.append({
			"item": slot.item,
			"quantity": slot.quantity
		})
	file_to_save.max_slots = inventory.max_slots
	file_to_save.inventory = data_to_save
	var result = ResourceSaver.save(file_to_save, SAVE_PATH)
	if result == OK:
		emit_signal("inventory_saved")
	else:
		push_error("Failed to save inventory!")

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_WM_CLOSE_REQUEST:
			inventory.save_inventory()
			get_tree().quit()
