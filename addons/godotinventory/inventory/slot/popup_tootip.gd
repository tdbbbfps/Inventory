extends PanelContainer
class_name PopupTooltip
## Popup tooltip show up when cursor enter the slot. Display item's information including icon, name, description, quantity.

@export var item_icon : TextureRect
@export var item_name : Label
@export var item_description : Label
@export var item_quantity : Label

func _ready() -> void:
	hide()

## Update tooltip's ui of texture, name, description and quantity.
func update_tooltip(item : Item, quantity : int) -> void:
	if not item:
		return
	item_icon.texture = item.icon
	item_name.text = item.name
	item_description.text = item.description
	item_quantity.text = "x%d" %quantity
	reset_size()
