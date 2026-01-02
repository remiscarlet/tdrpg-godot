extends RefCounted
class_name LootDrop

var loot_definition: LootDefinitionBase = LootEntryNothing.new()
var quantity: int
var scene: PackedScene

func _init(loot: LootDefinitionBase, new_quantity: int = 1, new_scene: PackedScene = null) -> void:
	loot_definition = loot
	quantity = new_quantity
	scene = new_scene

func is_nothing() -> bool:
	return loot_definition.item_id == &""