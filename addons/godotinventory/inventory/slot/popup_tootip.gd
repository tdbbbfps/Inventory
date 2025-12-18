extends Control
class_name PopupTooltip

@export var item_icon : TextureRect
@export var item_name : Label
@export var item_quantity : Label


func initialize(_item_icon : Texture, _item_name : String, _item_quantity : int) -> void:
	item_icon.texture = _item_icon
	item_name.text = _item_name
	item_quantity.text = str(_item_quantity)
