class_name AimFireWiringModule
extends FeatureModuleBase


func id() -> StringName:
    return &"aim_fire_wiring"


func stages() -> int:
    return ModuleHost.Stage.READY


func is_applicable(ctx: RigContext) -> bool:
    return (
        ctx.rig != null
        and ctx.rig.aim_fire_controller() != null
        and ctx.rig.aim_to_target() != null
        and ctx.rig.fire_weapon() != null
    )


func install(ctx: RigContext, stage: int) -> bool:
    print("Installing %s during stage %d with ctx: %s" % [id(), stage, ctx])

    match stage:
        ModuleHost.Stage.READY:
            return _install_ready(ctx)
        _:
            return true


func _install_ready(ctx: RigContext) -> bool:
    var aim_fire := ctx.rig.aim_fire_controller()
    var aim := ctx.rig.aim_to_target()
    var fire := ctx.rig.fire_weapon()

    print("Binding: %s, %s, %s" % [aim_fire, aim, fire])
    aim.bind_facing_root(ctx.rig.facing_root())
    aim_fire.bind_aim_to_target_component(aim)
    aim_fire.bind_fire_weapon_component(fire)

    # Provider selection:
    # - If player input exists => mouse targeting
    # - Else if target sensor exists => closest target
    if ctx.rig.player_input() != null:
        aim_fire.bind_target_provider(MouseTargetProvider.new())
    elif ctx.rig.target_sensor() != null:
        aim_fire.bind_target_provider(ClosestTarget2DProvider.new())

    return true
