extends PanelContainer
class_name Slot
## Slot store item and quantity.

## Resource of the item.
## Automatically updates the icon when set.
@export var item : Item:
	set(value):
		item = value
		if item:
			item = value
			icon.texture = item.icon
			_on_slot_occupied.emit()
		else:
			icon.texture = null
			# Force quantity set to 0.
			quantity = 0
			_on_slot_cleared.emit()
# Item's quantity of the slot. Update quantity label and visibility automatically when value changed.
var quantity : int = 0:
	set(value):
		if item:
			quantity = clamp(value, 0, item.max_stack)
			quantity_label.text = str(quantity)
			# Set quantity_label's visibility.
			if quantity > 0 and not quantity_label.visible:
				quantity_label.show()
		else:
			quantity = 0
			quantity_label.hide()
@export_category("Slot Configuration")
## Size of the slot. Update slot size automatically when set.
@export var slot_size : Vector2i:
	set(value):
		slot_size = value
		set_size(value)
@export_category("Child Reference")
@export var icon : TextureRect
@export var quantity_label : Label
signal _on_slot_occupied # Call when this slot occupied.
signal _on_slot_cleared # Call when this slot cleared.

func _ready() -> void:
	quantity_label.hide()

#region Drag and Drop
## Return drag data preview (item icon, quantity).
func get_preview() -> Control:
	var preview : Control = Control.new()
	preview.set_size(Vector2i(32, 32))

	var preview_icon : TextureRect = TextureRect.new()
	preview.add_child(preview_icon)
	preview_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview_icon.set_size(Vector2i(32, 32))
	preview_icon.texture = item.icon
	
	var preview_quantity : Label = Label.new()
	preview.add_child(preview_quantity)
	preview_quantity.text = str(quantity)
	preview_quantity.set_size(Vector2i(32, 32))
	preview_quantity.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	preview_quantity.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	
	var center_offset = Vector2(-16, -16) 
	preview.set_position(center_offset)
	
	return preview

## When user drag this slot. Return item data and set drag preview if the slot isn't empty.
func _get_drag_data(at_position: Vector2) -> Variant:
	if not item:
		return
	set_drag_preview(get_preview())
	var data : ItemData = ItemData.new(item, quantity, self)
	return data

## Check if the data can drop at this slot.
## Data must be ItemData and data's source slot can't be itself.
func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return (data is ItemData) and (data.source_slot != self)

## Handle drop logics: Add, Stack, Swap items.
func _drop_data(at_position: Vector2, data: Variant) -> void:
	# Add item to slot if this slot is empty.
	if not item:
		add_item(data)
	else:
		# Swap items if items are different.
		if item != data.item:
			swap_item(data)
		else:
			# If this slot is full already, swap itmes. Otherwise try to stack item at this slot.
			if quantity == item.max_stack:
				swap_item(data)
			else:
				stack_item(data)
#endregion

#region Inventory Operations
## Adds an item to this empty slot.
## @param new_item: The source ItemData.
func add_item(new_item : ItemData) -> void:
	item = new_item.item
	quantity = new_item.quantity
	# Clear the item from the source slot.
	if new_item.source_slot:
		new_item.source_slot.clear_slot()
## Stacks identical items.
## If the total exceeds max_stack, the remainder stays in the source slot.
## @param new_item: The source ItemData.
func stack_item(new_item : ItemData) -> void:
	# Total quantity from this slot and source slot.
	var total_quantity: int = quantity + new_item.quantity
	# Case1: Stack all in this slot.
	if total_quantity <= item.max_stack:
		quantity = total_quantity
		if new_item.source_slot:
			new_item.source_slot.clear_slot()
	# Case 2: Fill this slot to max, return remainder to source slot.
	else:
		quantity = item.max_stack
		var remainder : int = total_quantity - item.max_stack
		if new_item.source_slot:
			new_item.source_slot.quantity = remainder
## Swap items between this slot and source slot.
## @param: new_item: The source ItemData.
func swap_item(new_item : ItemData) -> void:
	var temp_data : ItemData = ItemData.new(item, quantity)
	
	item = new_item.item
	quantity = new_item.quantity
	
	new_item.source_slot.item = temp_data.item
	new_item.source_slot.quantity = temp_data.quantity

## Clear slot item, quantity.
func clear_slot() -> void:
	item = null
	quantity = 0
#endregion
