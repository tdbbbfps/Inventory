extends TextureRect
class_name DropArea
## Throw item when user dragged item to drop area.

## Delete: Remove item when drop. Drop: Spawn a collectible item on actor's position.
enum Behavior {
	DELETE,
	DROP
}
@export var inventory : Inventory
@export var resource_preloader : ResourcePreloader
## Declare how drop area handle drop data.
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
			drop_item(data)
			delete_item(data)
	
## Drop collectible item.
func drop_item(data : ItemData) -> void:
	var collectible_item_instance : CollectibleItem = resource_preloader.get_resource("collectible_item").instantiate()
	collectible_item_instance.item = data.item
	collectible_item_instance.quantity = data.quantity
	collectible_item_instance.global_position = inventory.actor.global_position
	get_tree().current_scene.add_child(collectible_item_instance)

## Delete item from source slot.
func delete_item(data : ItemData) -> void:
	if data.source_slot:
		data.source_slot.clear_slot()
