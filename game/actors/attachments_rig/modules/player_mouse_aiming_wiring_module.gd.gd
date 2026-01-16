class_name PlayerMouseAimingWiringModule
extends FeatureModuleBase


func id() -> StringName:
    return &"player_mouse_aim_wiring"


func stages() -> int:
    return ModuleHost.Stage.READY


func is_applicable(ctx: RigContext) -> bool:
    return (
        ctx.rig != null
        and ctx.rig.aim_fire_controller() != null
        and ctx.rig.player_input() != null
    )


func install(ctx: RigContext, stage: int) -> bool:
    print("Installing %s during stage %d with ctx: %s" % [id(), stage, ctx])

    match stage:
        ModuleHost.Stage.READY:
            return _install_ready(ctx)
        _:
            return true


func _install_ready(ctx: RigContext) -> bool:
    var player_ctrl: PlayerInputController = ctx.rig.player_input()
    var aim_fire := ctx.rig.aim_fire_controller()

    player_ctrl.bind_player_aim_fire_controller(aim_fire)

    return true
