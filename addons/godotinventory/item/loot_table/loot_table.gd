extends Node
class_name LootTable

class Loot extends Node:
	func _init(_item : Item, _quantity : int, _weight : int) -> void:
		self.item = _item
		self.quantity = _quantity
		self.weight = _weight

@export var loots : Array[Loot]
var total_weights : int
func _ready() -> void:
	for loot in loots:
		total_weights += loot.weight
func get_loot() -> Array:
	var rnd = randi_range(0, total_weights)
	while rnd > 0:
		pass
	return []
