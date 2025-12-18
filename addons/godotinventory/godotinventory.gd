@tool
extends EditorPlugin
## There's nothing here.

func _enable_plugin() -> void:
	# Add autoloads here.
	print("You activate the godot inventory!")

func _disable_plugin() -> void:
	# Remove autoloads here.
	print("You disable the godot inventory!")

func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	pass


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass
