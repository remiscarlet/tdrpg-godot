class_name SquadSpawnPlacementContext
extends RefCounted

## Purpose: Context data for spawn placement.
var spawner: Node
var spawn_group: StringName
var request: SquadSpawnRequest


func _init(p_spawner: Node, p_spawn_group: StringName, p_request: SquadSpawnRequest) -> void:
    spawner = p_spawner
    spawn_group = p_spawn_group
    request = p_request
