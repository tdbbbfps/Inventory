extends Node2D
class_name CollectItemComponent
## A component that handles the interaction for collecting items within a specific area.
## Usage:
## 1. Attach CollectItemComponent node to the player character.
## 2. Assign Collect Area (Area2D) and Inventory dependencies in the inspector.
## 3. Assign collect action name.
@export_category("Key Binding")
## The name of the input for collecting items.
@export var collect_action_name : StringName
@export_category("Node Reference")
@export var collect_area : Area2D
@export var inventory : Inventory

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed(collect_action_name):
		collect_items()

## Scans the collect_area and attempts to collect all collectible items.
func collect_items() -> void:
	if not collect_area or not inventory:
		push_warning("CollectItemComponent: Missing collect_area or inventory.")
		return
	# Get all areas that are in collect area.
	# You can set collectible_item and collect_area to a specific layer and mask.
	for area in collect_area.get_overlapping_areas():
		if area.get_parent() is CollectibleItem:
			area.get_parent().collect(inventory)
