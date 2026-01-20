class_name InteractableWiringModule
extends FeatureModuleBase


func id() -> StringName:
    return AttachmentModules.INTERACTABLE_WIRING


func stages() -> int:
    return ModuleHost.Stage.READY


func is_applicable(ctx: RigContext) -> bool:
    return ctx.rig != null and ctx.rig.interactable_detector() != null


func _install_ready(ctx: RigContext) -> bool:
    var det := ctx.rig.interactable_detector()

    var player_ctrl := ctx.rig.player_input()
    if player_ctrl != null:
        player_ctrl.bind_interactable_detector_component(det)

    var hauler := ctx.rig.hauler_ai()
    if hauler != null:
        hauler.bind_interactable_detector_component(det)

    return true
