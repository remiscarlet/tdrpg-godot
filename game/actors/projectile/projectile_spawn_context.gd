class_name ProjectileSpawnContext
extends RefCounted

var origin: Vector2
var direction: Vector2 = Vector2.RIGHT
var source: Node

# Optional: for homing projectiles
var target: Node2D = null

# Optional: gameplay metadata
var team_id: int = 0
var element: StringName = &""
var tags: Array[StringName] = []

func _init(source_: Node, origin_: Vector2) -> void:
	source = source_
	origin = origin_