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
var item1 = preload("res://items/resources/water.tres")
var item2 = preload("res://items/resources/sword.tres")

func _ready() -> void:
	create_new_slot(max_slots)
	max_slots += 5

func create_new_slot(quantity : int) -> void:
	for i in range(quantity):
		var new_slot = slot.instantiate()
		slot_container.add_child(new_slot)
		slots.append(new_slot)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		add_item(item1, 3)
	if event.is_action_pressed("ui_cancel"):
		add_item(item2, 4)

func add_item(item : Item, quantity : int) -> void:
	for empty_slot in slots:
		if empty_slot.item == null:
			empty_slot.item = item
			empty_slot.quantity = quantity
			return
