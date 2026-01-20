class_name SquadSpawnPoint
extends Marker2D

## Purpose: Marker node for squad spawn locations.
@export var enabled: bool = true
@export_range(0.0, 100.0, 0.1) var weight: float = 1.0
# Optional future-facing metadata.
@export var tags: Array[StringName] = []
# Convenience: automatically registers this point to a group on _ready.
@export var auto_add_to_group: bool = true
@export var spawn_group: StringName = Groups.ENEMY2_SPAWNS


func _ready() -> void:
    if auto_add_to_group and spawn_group != StringNames.EMPTY:
        add_to_group(spawn_group)


func get_spawn_position() -> Vector2:
    return global_position
