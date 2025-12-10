extends Control
class_name Inventory

@export var slot_container : GridContainer
var slots : Array = []
@export var max_slots : int = 40:
	set(value):
		max_slots = value
		if slots.size() < max_slots:
			create_new_slot(max_slots - slots.size())
var slot = preload("res://inventory/slot.tscn")

func _ready() -> void:
	create_new_slot(max_slots)
	max_slots += 5
func create_new_slot(quantity : int) -> void:
	for i in range(quantity):
		var new_slot = slot.instantiate()
		slot_container.add_child(new_slot)
		slots.append(new_slot)
