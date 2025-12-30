class_name CombatantSpawnContext
extends RefCounted

var origin: Vector2
var direction: Vector2 = Vector2.RIGHT
var type: Const.CombatantType

# Optional: gameplay metadata
var tags: Array[StringName] = []

func _init(_origin: Vector2, _type: Const.CombatantType) -> void:
    origin = _origin
    type = _type 