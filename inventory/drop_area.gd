extends TextureRect
class_name DropArea
## Throw item when user dragged item to drop area.

## Check if data is ItemData.
func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return data is ItemData

## Remove source slot's data.
func _drop_data(at_position: Vector2, data: Variant) -> void:
	var source_slot : Slot = data.source_data
	source_slot.clear_slot()
	
## Drop pickable item.
func drop_pickable_item(item : Item, quantity : int, at_position : Vector2) -> void:
	pass
