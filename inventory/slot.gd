extends PanelContainer
class_name Slot

@export var item : Item
var max_stack : int = 1
var quantity : int = 0

func _ready() -> void:
	pass

## Get item preview including item texture, quantity.
func get_preview() -> Control:
	var preview : Control = Control.new()
	preview.set_size(Vector2i(32, 32))
	
	var icon : TextureRect = TextureRect.new()
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.set_size(Vector2i(32, 32))
	icon.texture = item.icon
	preview.add_child(icon)
	
	return preview

func _get_drag_data(at_position: Vector2) -> Variant:
	return item
	
func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return data is Item
	
func _drop_data(at_position: Vector2, data: Variant) -> void:
	var temp_data = data
	item = data.item
	quantity = data.quantity
	
	
