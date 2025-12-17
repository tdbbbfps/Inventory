extends Node2D
class_name CollectibleItem
## CollectibleItem: Collectible item for instantiating in the game scene.
## Usage:
## 1. Instantiate CollectibleItem and add into scene tree (Must assign parameters before adding into scene tree).
## 2. Set up position, item and quantity.
@export_category("Item Data")
@export var item: Item
@export var quantity : int
@export_category("Node Reference")
@export var item_sprite : Sprite2D
@export var collision : CollisionShape2D

func _ready() -> void:
	# Initialize.
	if item:
		item_sprite.texture = item.icon
		collision.shape.size = item_sprite.texture.get_size()
		collision.shape.resource_local_to_scene = true

## Add item into inventory.
func collect(inventory : Inventory) -> void:
	inventory.add_item(item, quantity)
	collect_animation()

## Animation: Shrink and fade out.
func collect_animation(duration : float = 0.25) -> void:
	var collect_tween : Tween = get_tree().create_tween()
	collect_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	collect_tween.tween_property(self, "modulate", Color("ffffff00"), duration)
	collect_tween.parallel().tween_property(self, "scale", Vector2.ZERO, duration)
	collect_tween.tween_callback(queue_free)
