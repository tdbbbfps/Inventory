extends Control
class_name Inventory

@export var actor : CharacterBody2D
@export var slot_container : GridContainer
var slots : Array = [] # Store slots.
var empty_slots : Array = [] # Store empty slots.
var occupied_slots : Array = [] # Store occupaied slots.
@export var max_slots : int = 20:
	set(value):
		max_slots = value
		if slots.size() < max_slots:
			create_new_slot(max_slots - slots.size())
var slot = preload("uid://dnpm2dwueyth7")
var item1 = preload("res://items/resources/water.tres")
var item2 = preload("res://items/resources/sword.tres")

func _ready() -> void:
	create_new_slot(max_slots)
	max_slots += 5

func create_new_slot(quantity : int) -> void:
	for i in range(quantity):
		var slot_instance : Slot = slot.instantiate()
		slot_container.add_child(slot_instance)
		slots.append(slot_instance)
		empty_slots.append(slot_instance)
		# Connect signals.
		slot_instance._on_slot_occupied.connect(_on_slot_occupied.bind(slot_instance))
		slot_instance._on_slot_cleared.connect(_on_slot_cleared.bind(slot_instance))

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		add_item(item1, 3)
	if event.is_action_pressed("ui_cancel"):
		add_item(item2, 4)

## Add slot into occupied_slots and remove from empty_slots when slot is occupied.
func _on_slot_occupied(slot : Slot) -> void:
	if empty_slots.has(slot):
		empty_slots.erase(slot)
	if not occupied_slots.has(slot):
		occupied_slots.append(slot)

## Add slot into empty_slots and remove from occupied_slots when slot is cleared.
func _on_slot_cleared(slot : Slot) -> void:
	if occupied_slots.has(slot):
		occupied_slots.erase(slot)
	if not empty_slots.has(slot):
		empty_slots.append(slot)

## Add item into inventory.
## 1. Try to stack item into slot that has the same item.
## 2. Try to stack item into empty slot.
## If inventory is fulled, please write the logic to return the rest item.
## @param item: item resource.
## @param quantity: item quantity.
func add_item(item : Item, quantity : int) -> void:
	# 1. Try to stack item into slot that has the same item.
	if not occupied_slots.is_empty():
		for occupied_slot in occupied_slots:
			if quantity == 0:
				return
			# Continue if the slot don't have the same item.
			if not occupied_slot.item == item:
				continue
			var total_quantity : int = occupied_slot.quantity + quantity
			# Continue if ths slot is fulled.
			if occupied_slot.quantity == item.max_stack:
				continue
			# Stack all if the slot has enough stack amount.
			if item.max_stack >= total_quantity:
				occupied_slot.quantity = total_quantity
				return
			else:
				occupied_slot.quantity = item.max_stack
				quantity = total_quantity - item.max_stack
				continue
	if quantity == 0:
		return
	# Add item to empty slot if there's any empty slots and remainder.
	if empty_slots.is_empty() and quantity > 0:
		print("Inventory fulled!")
		## Return the rest item here. (Maybe create a pickable item, send it to mailbox whatever fit your game.)
		return
	# 2. Try to stack item into empty slot.
	for empty_slot in slots:
		if not empty_slot.item:
			empty_slot.item = item
			if quantity > item.max_stack:
				empty_slot.quantity = item.max_stack
				quantity -= item.max_stack
				continue
			else:
				empty_slot.quantity = quantity
				return
