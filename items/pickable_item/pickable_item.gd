extends Node2D
class_name PickableItem

@export var data : ItemData:
	set(value):
		data = value
		if data:
			item_sprite.texture = data.item.icon
@export var pickup_key : InputEventKey
@export var item_sprite : Sprite2D
@export var detect_box : Area2D
var able_to_pickup : bool = false

func _input(event: InputEvent) -> void:
	pass

func pickup(inventory : Inventory) -> void:
	inventory.add_item(data.item, data.quantity)

func _on_detect_box_body_entered(body: Node2D) -> void:
	pass


func _on_detect_box_body_exited(body: Node2D) -> void:
	pass # Replace with function body.
