class_name ProjectileSpawnContext
extends RefCounted

var origin: Vector2
var direction: Vector2 = Vector2.RIGHT

# Optional: for homing projectiles
var target: Node2D = null

# Optional: ownership / gameplay metadata
var owner: Node = null
var team_id: int = 0
var element: StringName = &""
var tags: Array[StringName] = []

func _init(origin_: Vector2) -> void:
	origin = origin_