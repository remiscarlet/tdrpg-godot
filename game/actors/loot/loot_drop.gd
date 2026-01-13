class_name LootDrop
extends RefCounted

var loot_id: StringName
var quantity: int


func _init(id: StringName, new_quantity: int = 1) -> void:
    loot_id = id
    quantity = new_quantity


func is_nothing() -> bool:
    return loot_id == &""
