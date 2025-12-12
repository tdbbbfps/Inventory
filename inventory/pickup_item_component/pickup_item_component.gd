extends Node2D
class_name PickupItemComponent
## PickupItemComponent is a component for handling the logic of picking up item.
## Put this component in user's character.

@export var pickup_area : Area2D
@export var collision : CollisionShape2D
@export var inventory : Inventory
## Pickup key events.
@export var pickup_event : InputEventAction

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed(pickup_event.action):
		pickup_items()

## Pickup all item in pickup_area.
## You can remove if condition if you set a specific collision layer and mask for both pickable item and pickup item componenet.
func pickup_items() -> void:
	for area in pickup_area.get_overlapping_areas():
		if area.get_parent() is PickableItem:
			area.get_parent().pickup(inventory)
			
