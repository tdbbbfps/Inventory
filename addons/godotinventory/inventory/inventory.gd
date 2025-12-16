extends Control
class_name Inventory

@export_category("Node Reference")
@export var actor : CharacterBody2D
@export var ascending_sort_button : Button
@export var close_button : Button
@export var slot_container : GridContainer
@export var resource_preloader : ResourcePreloader
@export_category("Inventory Configuration")
@export var max_slots : int = 20:
	set(value):
		max_slots = value
		# Automatically update slots.
		if slot_container and slots.size() < max_slots:
			create_new_slot(max_slots - slots.size())
@export var columns_size : int = 10:
	set(value):
		columns_size = value
		if slot_container:
			slot_container.columns = value
@export_category("Key Binding")
@export var open_inventory_action_name : StringName
@export var close_inventory_action_name : StringName
var slots : Array = [] # Store slots.
var empty_slots : Array = [] # Store empty slots.
var occupied_slots : Array = [] # Store occupaied slots.
## Create array with null values in it. When add item into the inventory, we insert the node reference into empty_slots and occupied_slots by it's index.
func _ready() -> void:
	# Initialize the inventory.
	create_new_slot(max_slots)
	slot_container.columns = columns_size
	close_button.pressed.connect(hide)
	ascending_sort_button.pressed.connect(sort_inventory_by_name.bind(true))

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(open_inventory_action_name):
		show()
	if event.is_action_pressed(close_inventory_action_name):
		hide()

#region Main Inventory Logics
## Instantiates new slots and connects signals for state tracking.
## @param quantity: The amount of slots to generate.
func create_new_slot(quantity : int) -> void:
	for i in range(quantity):
		var slot_instance : Slot = resource_preloader.get_resource("slot").instantiate()
		slot_container.add_child(slot_instance)
		slots.append(slot_instance)
		slot_instance.name = str(slot_instance.get_index())
		empty_slots.append(slot_instance)
		# Connect signals.
		slot_instance._on_slot_occupied.connect(_on_slot_occupied.bind(slot_instance))
		slot_instance._on_slot_cleared.connect(_on_slot_cleared.bind(slot_instance))

## Inventory Cache Management.
## Callback: Moves slot from empty to occupied list.
func _on_slot_occupied(slot : Slot) -> void:
	if empty_slots.has(slot):
		empty_slots.erase(slot)
	if not occupied_slots.has(slot):
		occupied_slots.append(slot)

## Callback: Moves slot from occupied to empty list.
func _on_slot_cleared(slot : Slot) -> void:
	if occupied_slots.has(slot):
		occupied_slots.erase(slot)
	if not empty_slots.has(slot):
		insert_slot_sorted(slot)

## Insert the slot into empty slots by its index. Ensure the empty slots are always in ascending order.
func insert_slot_sorted(slot_to_insert : Slot) -> void:
	# Get slot's index in slots.
	var target_index = slot_to_insert.get_index()
	# Use binary serach to find the insert position in empty slots.
	var insert_pos = empty_slots.bsearch_custom(slot_to_insert, func(a, b): return a.get_index() < b.get_index())
	empty_slots.insert(insert_pos, slot_to_insert)

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
		drop_remaining_item(item, quantity)

## Drop a pickable item on actor's position.
func drop_remaining_item(item: Item, quantity: int) -> void:
	var collectible_item_instance : CollectibleItem = resource_preloader.get_resource("collectible_item").instantiate()
	collectible_item_instance.item = item
	collectible_item_instance.quantity = quantity
	collectible_item_instance.global_position = actor.global_position
	get_tree().current_scene.add_child(collectible_item_instance)

## Sort inventory by name.
## @param ascending: If true, sort by A-Z; otherwise, sort by Z-A. Default to true.
func sort_inventory_by_name(ascending : bool = true) -> void:
	var items_to_sort : Array = []
	for slot in occupied_slots:
		var item_data : ItemData = ItemData.new(slot.item, slot.quantity)
		items_to_sort.append(item_data)
	
	# Use naturalnocasecmp_to compare two string, -1 if less than, 1 if greater than, 0 if equal to.
	items_to_sort.sort_custom(func(a,b):
		return convert_comparison_result(a.item.name.naturalnocasecmp_to(b.item.name), ascending)
		)
	while not occupied_slots.is_empty():
		occupied_slots[0].clear_slot()
	for slot in items_to_sort:
		add_item(slot.item, slot.quantity)

## Convert naturalnocasecmp_to's result to bool.
## If ascending: n <= 0(less equal) true otherwise false
func convert_comparison_result(n : int, ascending : bool = true) -> bool:
	if ascending:
		return true if n <= 0 else false
	return false if n <= 0 else true
#endregion
