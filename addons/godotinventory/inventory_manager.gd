extends Node

var autosave_on_quit : bool = true
var autoload_inventory : bool = true
var inventory : Inventory

func _ready() -> void:
	inventory = get_tree().get_first_node_in_group("Inventory")
	ProjectSettings.set_setting("application/config/auto_accept_quit", !autosave_on_quit)
	if autoload_inventory:
		inventory.load_inventory()

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_WM_CLOSE_REQUEST:
			inventory.save_inventory()
			get_tree().quit()
