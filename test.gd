extends Node2D

var array = ["Godot", "Sword", "Shield", "Apple", "Potion", "Banana"]
var madarin = ["帥哥","雞雞","懶覺"]
func _ready() -> void:
	array.sort_custom(func(a, b): 
		prints(a, "vs", b, "is", b.naturalnocasecmp_to(a))
		return bool(b.naturalnocasecmp_to(a) + 1))
	prints(array)
	var x = "x"
	var y = "y"
	print(bool(x.naturalnocasecmp_to(y)))
