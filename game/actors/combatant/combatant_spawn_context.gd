class_name CombatantSpawnContext
extends RefCounted

var origin: Vector2
var direction: Vector2 = Vector2.RIGHT
var combatant_id: StringName
# Optional: gameplay metadata
var squad_id: int
var tags: Array[StringName] = []


func _init(at: Vector2, id: StringName, s_id: int = -1) -> void:
    origin = at
    combatant_id = id
    squad_id = s_id
