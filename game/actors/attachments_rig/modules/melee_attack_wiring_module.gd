class_name MeleeAttackWiringModule
extends FeatureModuleBase


## Purpose: Feature module that wires Melee attack into the attachments rig.
func id() -> StringName:
    return AttachmentModules.MELEE_ATTACK_WIRING


func stages() -> int:
    return ModuleHost.Stage.POST_READY | ModuleHost.Stage.PRE_TREE


func is_applicable(ctx: RigContext) -> bool:
    return (
        ctx.rig != null
        and ctx.level_container != null
        and ctx.rig.melee_attack() != null
        and ctx.rig.target_sensor() != null
    )


func _install_pre_tree(ctx: RigContext) -> bool:
    var target_sensor: TargetSensor2DComponent = ctx.rig.target_sensor()
    target_sensor.set_team_id(ctx.team_id)

    return true


func _install_post_ready(ctx: RigContext) -> bool:
    var target_sensor: TargetSensor2DComponent = ctx.rig.target_sensor()
    var melee: MeleeAttackComponent = ctx.rig.melee_attack()
    var sword: BasicSword = ctx.rig.sword()

    melee.bind_target_sensor_component(target_sensor)
    melee.bind_sword(sword)
    target_sensor.set_team_id(ctx.team_id)

    PhysicsUtils.set_hitbox_collisions_for_team(sword, ctx.team_id)

    return true
