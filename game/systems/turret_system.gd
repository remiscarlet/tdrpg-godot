class_name TurretSystem
extends Node

## Purpose: System that spawns and manages turrets.
@onready var level_container: LevelContainer = get_parent()
@onready var turret_container: Node2D = $TurretContainer


# Signal handler pattern
func try_build_turret(ctx: TurretSpawnContext) -> DefaultTurret:
    print("Trying to build turret")
    var def := DefinitionDB.get_turret(ctx.turret_id)

    var node = def.scene.instantiate()
    var turret := node as DefaultTurret
    if turret == null:
        push_error("Turret scene does not inherit DefaultTurret.")
        return null

    var rig := turret.get_node("AttachmentsRig") as AttachmentsRig
    rig.module_host().configure_pre_tree(def, def.team_id, ctx)
    turret.configure_pre_ready(ctx, def)

    turret_container.add_child(turret)
    if not turret.is_node_ready():
        await turret.ready

    rig.module_host().configure_post_ready(level_container)

    return turret
