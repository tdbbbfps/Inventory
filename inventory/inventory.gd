extends Control
class_name Inventory

@export var slot_container : GridContainer
var slots : Array = []
var max_slots : int = 16
var slot = preload("res://inventory/slot.tscn")

func _ready() -> void:
	for i in range(max_slots):
		var new_slot = slot.instantiate()
		slot_container.add_child(new_slot)
		slots.append(new_slot)
