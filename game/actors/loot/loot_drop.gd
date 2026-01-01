extends RefCounted
class_name LootDrop

var item_id: StringName = &""
var quantity: int
var scene: PackedScene

func _init(new_item_id: StringName = &"", new_quantity: int = 1, new_scene: PackedScene = null) -> void:
	item_id = new_item_id
	quantity = new_quantity
	scene = new_scene

func is_nothing() -> bool:
	return item_id == &""