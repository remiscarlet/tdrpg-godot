class_name PlayerMouseAimingWiringModule
extends FeatureModuleBase


## Purpose: Feature module that wires Player mouse aiming into the attachments rig.
func id() -> StringName:
    return AttachmentModules.PLAYER_MOUSE_AIM_WIRING


func stages() -> int:
    return ModuleHost.Stage.READY


func is_applicable(ctx: RigContext) -> bool:
    return (
        ctx.rig != null
        and ctx.rig.aim_fire_controller() != null
        and ctx.rig.player_input() != null
    )


func _install_ready(ctx: RigContext) -> bool:
    var player_ctrl: PlayerInputController = ctx.rig.player_input()
    var aim_fire := ctx.rig.aim_fire_controller()

    player_ctrl.bind_player_aim_fire_controller(aim_fire)

    return true
