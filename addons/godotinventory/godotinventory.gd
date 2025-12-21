@tool
extends EditorPlugin

const INVENTORY_MANAGER_PATH : String = "res://addons/godotinventory/inventory/inventory_manager.tscn"
func _enable_plugin() -> void:
	# Add autoloads here.
	print("You activate the godot inventory!")
	add_autoload_singleton("InventoryManager", INVENTORY_MANAGER_PATH)

func _disable_plugin() -> void:
	# Remove autoloads here.
	print("You disable the godot inventory!")
	remove_autoload_singleton("InventoryManager")
