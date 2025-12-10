extends PanelContainer
class_name Slot

@export var item : Item:
	set(value):
		if value:
			item = value
			icon.texture = item.icon
		else:
			item = null
			icon.texture = null
@export_category("Slot components reference")
@export var slot_size : Vector2i:
	set(value):
		slot_size = value
		set_size(value)
@export var icon : TextureRect
@export var quantity_label : Label
# Slot's item quantity. Visible only if quantity greater than 0.
var quantity : int = 0:
	set(value):
		if value > 0:
			quantity = clamp(value, 0, item.max_stack)
		else:
			quantity = value
			# Remove item if quantity equal to 0
			if item:
				item = null
		quantity_label.text = str(quantity)
		if quantity > 0:
			quantity_label.show()
		else:
			quantity_label.hide()

func _ready() -> void:
	quantity_label.hide()
## TODO: Change control to panel container.
## Get item preview including item texture, quantity.
func get_preview() -> Control:
	var preview : Control = Control.new()
	preview.set_size(Vector2i(32, 32))
	
	var preview_icon : TextureRect = TextureRect.new()
	preview_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview_icon.set_size(Vector2i(32, 32))
	preview_icon.texture = item.icon
	preview.add_child(preview_icon)
	
	var preview_quantity : Label = Label.new()
	preview_quantity.text = str(quantity)
	preview_quantity.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	preview_quantity.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	preview_quantity.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	preview_quantity.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	preview.add_child(preview_quantity)
	return preview

## Return drag data and preview if the slot isn't empty.
func _get_drag_data(at_position: Vector2) -> Variant:
	if not item:
		return
	set_drag_preview(get_preview())
	var data : ItemData = ItemData.new(item, quantity, self)
	return data

## Return true if data is ItemData.
func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return data is ItemData

## TODO: Simplify this function.
## Try drop item, stack same item, swap different item.
func _drop_data(at_position: Vector2, data: Variant) -> void:
	# Drop item if slot is empty.
	if not item:
		item = data.item
		quantity = data.quantity
		data.origin_slot.clear_slot()
	else:
		# Swap items.
		if item != data.item:
			var temp_data : ItemData = ItemData.new(item, quantity)
			item = data.item
			quantity = data.quantity
			
			data.origin_slot.item = temp_data.item
			data.origin_slot.quantity = temp_data.quantity
		else:
			# Stack all items.
			if item.max_stack >= quantity + data.quantity:
				quantity += data.quantity
				data.origin_slot.clear_slot()
			# Stack some items.
			elif item.max_stack <= quantity + data.quantity:
				var total_quantity : int = quantity + data.quantity
				quantity += data.quantity
				total_quantity -= quantity
				data.origin_slot.quantity = total_quantity
			# Swap items.
			elif quantity == item.max_stack:
				var temp_data : ItemData = ItemData.new(item, quantity)
				item = data.item
				quantity = data.quantity
				
				data.origin_slot.item = temp_data.item
				data.origin_slot.quantity = temp_data.item

func add_item(new_item : ItemData) -> void:
	item = new_item.item
	quantity = new_item.quantity
	# Clear origin_slot if new_item is dragged from another slot.
	if new_item.origin_slot:
		new_item.origin_slot.clear_slot()

func stack_item(new_item : ItemData) -> void:
	pass

## Swap two items.
## @param: new_item
func swap_item(new_item : ItemData) -> void:
	var temp_data : ItemData = ItemData.new(item, quantity)
	item = new_item.item
	quantity = new_item.quantity
	new_item.origin_slot.item = temp_data.item
	new_item.origin_slot.quantity = temp_data.quantity
## Clear slot item, quantity.
func clear_slot() -> void:
	item = null
	quantity = 0
