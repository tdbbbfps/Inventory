extends Node
class_name ItemData
## Use for item drag and drop data.
var item : Item
var quantity : int
var source_slot : Slot

func _init(_item : Item, _quantity : int, source_slot : Slot = null) -> void:
	self.item = _item
	self.quantity = _quantity
	self.source_slot = source_slot
