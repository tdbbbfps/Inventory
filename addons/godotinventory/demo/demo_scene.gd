extends Node2D

func _on_add_slot_button_pressed() -> void:
	InventoryManager.expand_inventory(1)
