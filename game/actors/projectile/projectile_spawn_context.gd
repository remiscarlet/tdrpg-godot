class_name ProjectileSpawnContext
extends RefCounted

var origin: Vector2
var direction: Vector2 = Vector2.RIGHT
var source: Node
var team_id: int

# Optional: for homing projectiles
var target: Node2D = null

# Optional: gameplay metadata
var element: StringName = &""
var tags: Array[StringName] = []

func _init(_source: Node, _origin: Vector2, _team_id: int) -> void:
	source = _source
	origin = _origin
	team_id = _team_id