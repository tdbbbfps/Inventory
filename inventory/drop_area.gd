extends TextureRect
class_name DropArea
## Throw item when user dragged item to drop area.
enum Behavior {
	DELETE,
	DROP
}
@export var inventory : Inventory
## Declare how drop area handle drop data.
## Delete: Remove item when drop. Drop: Spawn a pickable item.
@export var drop_behavior : Behavior = Behavior.DELETE
var pickable_item = preload("uid://bqjkubbra5wp8")

## Check if data is ItemData.
func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return data is ItemData

## Remove source slot's data.
func _drop_data(at_position: Vector2, data: Variant) -> void:
	match drop_behavior:
		Behavior.DELETE:
			delete_item(data)
		Behavior.DROP:
			drop_pickable_item(data)
			delete_item(data)
	
## Drop pickable item.
func drop_pickable_item(data : ItemData) -> void:
	var pickable_item_instance : PickableItem = pickable_item.instantiate()
	get_tree().current_scene.add_child(pickable_item_instance)
	pickable_item_instance.item = data.item
	pickable_item_instance.quantity = data.quantity
	pickable_item_instance.global_position = inventory.actor.global_position

## Delete item from source slot.
func delete_item(data : ItemData) -> void:
	if data.source_slot:
		data.source_slot.clear_slot()
