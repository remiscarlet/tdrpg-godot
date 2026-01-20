class_name TurretSpawnContext
extends RefCounted
## TODO: Please move this into somewhere not under scenes/...

## Purpose: Spawn context data for Turret.
var origin: Vector2
var turret_id: StringName


func _init(at: Vector2, id: StringName) -> void:
    origin = at
    turret_id = id
