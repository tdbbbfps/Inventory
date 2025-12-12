extends Control
class_name Inventory

@export var actor : CharacterBody2D
@export var slot_container : GridContainer

@export var max_slots : int = 20:
	set(value):
		max_slots = value
		if slots.size() < max_slots:
			create_new_slot(max_slots - slots.size())
var slot = preload("uid://dnpm2dwueyth7")
var pickable_item = preload("uid://bqjkubbra5wp8")
# Inventory management
var slots : Array = [] # Store slots.
var empty_slots : Array = [] # Store empty slots.
var occupied_slots : Array = [] # Store occupaied slots.
# Example items.
var item1 = preload("res://items/resources/water.tres")
var item2 = preload("res://items/resources/sword.tres")

func _ready() -> void:
	# Initialize the inventory.
	create_new_slot(max_slots)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		add_item(item1, 3)
	if event.is_action_pressed("ui_cancel"):
		add_item(item2, 4)

## Instantiates new slots and connects signals for state tracking.
## @param quantity: The amount of slots to generate.
func create_new_slot(quantity : int) -> void:
	for i in range(quantity):
		var slot_instance : Slot = slot.instantiate()
		slot_container.add_child(slot_instance)
		slots.append(slot_instance)
		empty_slots.append(slot_instance)
		# Connect signals.
		slot_instance._on_slot_occupied.connect(_on_slot_occupied.bind(slot_instance))
		slot_instance._on_slot_cleared.connect(_on_slot_cleared.bind(slot_instance))

## FIXME:
## Callback: Moves slot from empty to occupied list.
func _on_slot_occupied(slot : Slot) -> void:
	if empty_slots.has(slot):
		empty_slots.erase(slot)
	if not occupied_slots.has(slot):
		occupied_slots.append(slot)
## FIXME: 當新的empty slot被加入後會被放在陣列最後面（導致空欄位可能變成 2, 3, 4, 1，加入時不會從最前面的第一格加入，而是從陣列第一個的2加入）
## Callback: Moves slot from occupied to empty list.
func _on_slot_cleared(slot : Slot) -> void:
	if occupied_slots.has(slot):
		occupied_slots.erase(slot)
	if not empty_slots.has(slot):
		empty_slots.append(slot)

## Main logic to add items to the inventory.
## Strategy:
## 1. Stack into existing slots with the same item.
## 2. Fill empty slots with remaining quantity.
## 3. Drop any remaining items if inventory is full.
## @param item: The Item resource to add.
## @param quantity: The amount to add.
func add_item(item : Item, quantity : int) -> void:
	if quantity <= 0: return
	# Step 1: Try to stack into existing occupied slots.
	for slot in occupied_slots:
		if slot.item == item and slot.quantity < item.max_stack:
			# The remaining space in the slot.
			var available_space : int = item.max_stack - slot.quantity
			# Determine how much to add into the slot.
			var amount_to_add : int = min(quantity, available_space)
			slot.quantity += amount_to_add
			quantity -= amount_to_add
			if quantity == 0: return
	# Step 2: Try to fill empty slots.
	# We use a while loop because modifying the slot (setting item) triggers
	# signals that modify the 'empty_slots' array immediately.
	while quantity > 0 and not empty_slots.is_empty():
		# Always take the first available empty slot.
		var target_slot: Slot = empty_slots[0] 
		# Set the item type first.
		target_slot.item = item
		# Calculate stack amount.
		var amount_to_add: int = min(quantity, item.max_stack)
		target_slot.quantity = amount_to_add
		quantity -= amount_to_add
	# Step 3: Handle overflow (Drop to ground).
	if quantity > 0:
		_drop_remaining_item(item, quantity)
## Handles logic when the inventory cannot fit all items.
func _drop_remaining_item(item: Item, quantity: int) -> void:
	print("Inventory full! Dropping %s x%d on the ground." % [item.name, quantity])
	
	# Instantiate a "WorldItem" or "Pickable" scene at the actor's position.
	# Assuming you have a PackedScene for world items, e.g., var world_item_scene
	# var world_item = world_item_scene.instantiate()
	# world_item.init(item, quantity)
	# get_tree().current_scene.add_child(world_item)
	# if actor:
	# 	world_item.global_position = actor.global_position
