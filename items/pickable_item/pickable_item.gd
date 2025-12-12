extends Node2D
class_name PickableItem

@export var item: Item:
	set(value):
		item = value
		if item:
			item_sprite.texture = item.icon
@export var quantity : int
@export var item_sprite : Sprite2D
@export var collision : CollisionShape2D

func _ready() -> void:
	collision.shape.size = item_sprite
## Add item into inventory.
func pickup(inventory : Inventory) -> void:
	inventory.add_item(item, quantity)
	queue_free()
