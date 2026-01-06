class_name TurretSystem
extends Node

@onready var level_container: LevelContainer = get_parent()
@onready var turret_container: Node2D = $TurretContainer


# Signal handler pattern
func try_build_turret(_player: Node, world_pos: Vector2, turret_type: StringName) -> void:
    print("Trying to build turret")
    print(turret_type)

    var def := DefinitionDB.get_turret(turret_type)
    var turret: Node = def.scene.instantiate()

    turret.configure_pre_ready(level_container, def)
    turret_container.add_child(turret)
    turret.configure_post_ready(world_pos)
