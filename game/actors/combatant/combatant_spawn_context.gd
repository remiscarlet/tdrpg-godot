class_name CombatantSpawnContext
extends RefCounted

var origin: Vector2
var direction: Vector2 = Vector2.RIGHT

var projectile_system: ProjectileSystem

# Optional: gameplay metadata
var team_id: int = 0
var tags: Array[StringName] = []

func _init(origin_: Vector2, projectile_system_: ProjectileSystem) -> void:
    origin = origin_
    projectile_system = projectile_system_