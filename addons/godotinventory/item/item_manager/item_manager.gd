extends Node
## ItemManager load all item's resource into resource_preloader when adding into scene tree.
var resource_preloader : ResourcePreloader
var resources_path : String = "res://addons/godotinventory/item/resources/"

func _enter_tree() -> void:
	resource_preloader = ResourcePreloader.new()
	load_item_resources()

func _exit_tree() -> void:
	resource_preloader.free()

## Load all item's resources into resource_preloader.
func load_item_resources() -> void:
	var files = DirAccess.get_files_at(resources_path)
	for file in files:
		resource_preloader.add_resource(file.get_basename(), load(resources_path.path_join(file)))

## Return an item if exist.
func get_item(item_name : String) -> Item:
	return resource_preloader.get_resource(item_name) if resource_preloader.has_resource(item_name) else null
