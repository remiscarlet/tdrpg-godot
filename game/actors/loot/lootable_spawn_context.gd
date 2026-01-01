class_name LootableSpawnContext
extends RefCounted

var origin: Vector2
var source: Node
var drops: Array[LootDrop]

var direction: Vector2 = Vector2.RIGHT

func _init(new_source: Node, new_origin: Vector2, new_drops: Array[LootDrop]) -> void:
	source = new_source
	origin = new_origin
	drops = new_drops