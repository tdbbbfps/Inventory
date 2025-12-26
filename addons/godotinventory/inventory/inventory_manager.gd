extends Node

const SAVE_PATH : String = "user://inventory_data.res"
@export var max_slots : int = 20
var slots : Array[ItemData]
var occupied_slots : Array[int] = [] # Store the indexs of the slots thar are occupied.
var empty_slots : Array[int] = [] # Store thex indexs of the slows that are empty.
@export var autosave_on_quit : bool = true
var inventory : Inventory

signal item_added(index : int)
signal item_removed(index : int)
signal inventory_saved
signal inventory_loaded

func _ready() -> void:
	ProjectSettings.set_setting("application/config/auto_accept_quit", !autosave_on_quit)

#region Inventory main logics
func initialize_slots() -> void:
	slots
## Register inventory to inventory manager.
func register_inventory(inventory : Inventory) -> void:
	self.inventory = inventory

## Expand inventory max slot size.
func expand_inventory(quantity : int) -> void:
	inventory.max_slots += quantity

## Add slot index into occupied_slots and remove it from empty_slots.
func _on_slot_occupied(index : int) -> void:
	if not occupied_slots.has(index):
		occupied_slots.append(index)
		occupied_slots.sort()
	if empty_slots.has(index):
		empty_slots.erase(index)
## Add slot index into empty_slots and remove it from occupied_slots.
func _on_slot_cleared(index : int) -> void:
	if not empty_slots.has(index):
		empty_slots.append(index)
		empty_slots.sort()
	if occupied_slots.has(index):
		occupied_slots.erase(index)
## Add item to the inventory.
## Frist, try to stack item into existing slots with the same item.
## Second, try to fill item into empty slots
## If there's any reamining quantity, drop the remaining item to the ground.
func add_item(item_data : ItemData) -> void:
	if item_data.quantity <= 0: return
	for idx in occupied_slots:
		if slots[idx].item == item_data.item and slots[idx].quantity < item_data.item.max_stack:
			var available_space : int = item_data.item.max_stack - slots[idx].quantity # Target slot's available quantity space.
			var amount_to_add : int = min(item_data.quantity, available_space) # Add all item_data's quantity or fill with slot's remaining space.
			slots[idx].quantity += amount_to_add
			item_data.quantity -= amount_to_add
			if item_data.quantity == 0:
				return
	while item_data.quantity > 0 and not empty_slots.is_empty():
		var target_slot = slots[empty_slots[0]]
		var amount_to_add : int = min(item_data.quantity, item_data.item.max_stack)
		target_slot.quantity = amount_to_add
		item_data.quantity -= amount_to_add
	if item_data.quantity > 0:
		drop_remaining_items(item_data)

func add_item_at_index(item_data : ItemData, index : int) -> void:
	slots[index] = item_data

func drop_remaining_items(item_data : ItemData) -> void:
	pass
	
func sort_inventory_by_name(ascending : bool = true) -> void:
	var items_to_sort : Array[ItemData] = []
	for index in occupied_slots:
		items_to_sort.append(occupied_slots[index])
	items_to_sort.sort_custom(func(a, b): return convert_comparison_result(a.item.name.naturalnocasecmp_to(b.item.name), ascending))
	
func convert_comparison_result(n : int, ascending : bool) -> bool:
	if ascending:
		return true if n <= 0 else false
	return false if n <= 0 else true

#region
#region Inventory save and load logics.
## Load inventory data from a resource file.
func load_inventory_data() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		push_error("File doesn't exist!")
		return
	var file = ResourceLoader.load(SAVE_PATH) as InventorySave
	inventory.max_slots = file.max_slots
	var temp : Array[ItemData] = file.inventory
	for i in range(temp.size()):
		add_item_at_index(temp[i], i)
	emit_signal("inventory_loaded")

## Save data in a resource file. Store slots' item_data, max_slots.
func save_inventory_data() -> void:
	var file_to_save : InventorySave = InventorySave.new()
	var data_to_save : Array[Dictionary]
	for slot in slots:
		data_to_save.append(slot)
	file_to_save.max_slots = inventory.max_slots
	file_to_save.inventory = data_to_save
	var result = ResourceSaver.save(file_to_save, SAVE_PATH)
	if result == OK:
		emit_signal("inventory_saved")
	else:
		push_error("Failed to save inventory!")

func _notification(what: int) -> void:
	## Automatically save inventory data when receiving close request.
	if what == NOTIFICATION_WM_CLOSE_REQUEST and autosave_on_quit:
		save_inventory_data()
		get_tree().quit()
#endregion
