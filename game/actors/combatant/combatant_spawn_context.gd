class_name CombatantSpawnContext
extends RefCounted

var origin: Vector2
var direction: Vector2 = Vector2.RIGHT
var combatant_id: StringName
# Optional: gameplay metadata
var tags: Array[StringName] = []


func _init(at: Vector2, id: StringName) -> void:
    origin = at
    combatant_id = id
