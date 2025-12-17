@tool
extends EditorPlugin

const ITEM_MANAGER_PATH : String = "res://addons/godotinventory/items/item_manager/item_manager.gd"

func _enable_plugin() -> void:
	# Add autoloads here.
	print("You activate the godot inventory!")
	add_autoload_singleton("ItemManager", ITEM_MANAGER_PATH)

func _disable_plugin() -> void:
	# Remove autoloads here.
	print("You disable the godot inventory!")
	remove_autoload_singleton("ItemManager")

func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	pass


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass
