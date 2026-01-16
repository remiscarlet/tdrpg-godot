class_name RangedAttackSpawnContext
extends RefCounted

var ranged_attack_type_id: StringName
var origin: Vector2
var direction: Vector2 = Vector2.RIGHT
var source: Node
var team_id: int
# Optional: for homing projectiles
var target: Node2D = null
# Optional: gameplay metadata
var element: StringName = &""
var tags: Array[StringName] = []


func _init(type: StringName, new_source: Node, new_origin: Vector2, new_team_id: int) -> void:
    ranged_attack_type_id = type
    source = new_source
    origin = new_origin
    team_id = new_team_id
