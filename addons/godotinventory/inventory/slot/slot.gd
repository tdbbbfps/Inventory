extends PanelContainer
class_name Slot
## Slot store item and quantity.
## You can add, stack or swap items by dragging and dropping item to another slot.

@export var item : Item:
	set(value):
		item = value
		if item:
			icon.texture = item.icon
			# Update tooltip ui.
			popup_tooltip.update_tooltip(item, quantity)
			emit_signal("slot_occupied")
		else:
			icon.texture = null
			# Force to hide tooltip when item become null.
			popup_tooltip.hide()
			emit_signal("slot_cleared")
var quantity : int = 0:
	set(value):
		if not item:
			quantity = 0
			quantity_label.hide()
		else:
			quantity = clamp(value, 0, item.max_stack)
			if quantity > 0:
				quantity_label.text = "x%d" %quantity
				# Update ui.
				popup_tooltip.update_tooltip(item, quantity)
				if not quantity_label.visible:
					quantity_label.show()
			else:
				# Remove item if quantity equal to 0.
				item = null
				quantity_label.hide()
@export_category("Slot Configuration")
@export_category("Node Reference")
@export var icon : TextureRect
@export var quantity_label : Label
@export var popup_tooltip : PopupTooltip
signal slot_occupied # Call when this slot occupied.
signal slot_cleared # Call when this slot cleared.

func _ready() -> void:
	quantity_label.hide()
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

## Show popup tooltip.
func _on_mouse_entered() -> void:
	if item and popup_tooltip:
		popup_tooltip.show()
		popup_tooltip.position = get_global_mouse_position() + Vector2(16, 16)

## Hide popup tooltip.
func _on_mouse_exited() -> void:
	if popup_tooltip:
		popup_tooltip.hide()

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
	if not item:
		add_item(data)
	else:
		if item != data.item:
			swap_item(data)
		else:
			if quantity == item.max_stack:
				swap_item(data)
			else:
				stack_item(data)

## Adds an item to this empty slot.
## @param new_item: The source ItemData.
func add_item(new_item : ItemData) -> void:
	item = new_item.item
	quantity = new_item.quantity
	if new_item.source_slot:
		new_item.source_slot.clear_slot()
## Stacks identical items.
## If the total exceeds max_stack, the remainder stays in the source slot.
## @param new_item: The source ItemData.
func stack_item(new_item : ItemData) -> void:
	var total_quantity: int = quantity + new_item.quantity
	if total_quantity <= item.max_stack:
		quantity = total_quantity
		if new_item.source_slot:
			new_item.source_slot.clear_slot()
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
