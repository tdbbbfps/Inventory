extends Node

const SAVE_PATH : String = "user://inventory_data.res"
@export var max_slots : int = 20
var slots : Array[ItemData] = []
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
	slots.resize(max_slots)

#region Inventory main logics
## Register inventory to inventory manager.
func register_inventory(inventory : Inventory) -> void:
	self.inventory = inventory

## Expand inventory max slot size.
func expand_inventory(quantity : int) -> void:
	inventory.max_slots += quantity
	
func add_item(item_data : ItemData) -> void:
	if item_data.quantity <= 0: return
	for idx in occupied_slots:
		if slots[idx].item == item_data.item and slots[idx].quantity < item_data.item.max_stack:
			var available_space : int = item_data.item.max_stack - slots[idx].quantity
			var amount_to_add : int = min(quantity, available_space) # Add the minimum amount

#func add_item(item_data : ItemData) -> void:
	#if quantity <= 0: return
	#for slot in occupied_slots:
		#if slot.item == item and slot.quantity < item.max_stack:
			#var available_space : int = item.max_stack - slot.quantity
			#var amount_to_add : int = min(quantity, available_space)
			#slot.quantity += amount_to_add
			#quantity -= amount_to_add
			#if quantity == 0: return
	#while quantity > 0 and not empty_slots.is_empty():
		#var target_slot: Slot = empty_slots[0] 
		#target_slot.item = item
		#var amount_to_add: int = min(quantity, item.max_stack)
		#target_slot.quantity = amount_to_add
		#quantity -= amount_to_add
	#if quantity > 0:
		#drop_remaining_item(item, quantity)

func add_item_at_index(item_data : ItemData, index : int) -> void:
	slots[index] = item_data

#region
#region Inventory save and load logics.
## Load inventory data.
func load_inventory_data() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		push_error("File doesn't exist!")
		return
	var file = ResourceLoader.load(SAVE_PATH) as InventorySave
	inventory.max_slots = file.max_slots
	var temp : Array[Dictionary] = file.inventory
	for i in range(temp.size()):
		if temp[i]["item"] != null:
			inventory.add_item_to_index(i, temp[i]["item"], temp[i]["quantity"])
	
	emit_signal("inventory_loaded")

func save_inventory_data() -> void:
	var file_to_save : InventorySave = InventorySave.new()
	var data_to_save : Array[Dictionary]
	for slot in inventory.slots:
		data_to_save.append({
			"item": slot.item,
			"quantity": slot.quantity
		})
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
