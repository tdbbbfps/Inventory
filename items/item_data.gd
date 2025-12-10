extends Node
class_name ItemData
## Use for item drag and drop data.
var item : Item
var quantity : int
var origin_slot : Slot

func _init(_item : Item, _quantity : int, _origin_slot : Slot = null) -> void:
	self.item = _item
	self.quantity = _quantity
	self.origin_slot = _origin_slot
