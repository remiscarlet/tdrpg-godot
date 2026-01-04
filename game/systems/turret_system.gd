class_name TurretSystem
extends Node

@onready var level_container: LevelContainer = get_parent()
@onready var turret_container: Node2D = $TurretContainer


# Signal handler pattern
func try_build_turret(_player: Node, world_pos: Vector2, turret_scene: PackedScene) -> void:
    print("Trying to build turret")

    var turret: Node = turret_scene.instantiate()
    turret.bind_level_container_ref(level_container)
    turret_container.add_child(turret)
    turret.bind_target_provider(ClosestTarget2DProvider.new())
    turret.global_position = world_pos
