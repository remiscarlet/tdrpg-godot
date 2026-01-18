class_name SquadSpawnPlacementResult
extends RefCounted

var position: Vector2 = Vector2.ZERO
var spawn_point: Node = null


func _init(p_position: Vector2 = Vector2.ZERO, p_spawn_point: Node = null) -> void:
    position = p_position
    spawn_point = p_spawn_point


func is_valid() -> bool:
    return position != Vector2.ZERO
