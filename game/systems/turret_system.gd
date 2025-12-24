class_name TurretSystem
extends Node

@onready var turret_container: Node2D = $TurretContainer
@onready var projectile_system: Node = $"../ProjectileSystem"


# Signal handler pattern
func try_build_turret(player: Node, world_pos: Vector2, turret_scene: PackedScene) -> void:
	print("Trying to build turret")
	print(projectile_system)

	var turret: Node = turret_scene.instantiate()
	turret.init(projectile_system)
	turret_container.add_child(turret)
	turret.global_position = world_pos
