class_name AIHaulerWiringModule
extends FeatureModuleBase


func id() -> StringName:
    return &"ai_hauler_wiring"


func stages() -> int:
    return ModuleHost.Stage.POST_READY


func is_applicable(ctx: RigContext) -> bool:
    return (
        ctx.rig != null
        and ctx.level_container != null
        and ctx.rig.inventory() != null
        and ctx.rig.hauler_ai() != null
        and ctx.rig.interactable_detector() != null
    )


func _install_post_ready(ctx: RigContext) -> bool:
    if ctx.level_container == null:
        print("Called _install_post_ready but ctx.level_container was null!")
        return false

    var interactable_detector: InteractableDetectorComponent = ctx.rig.interactable_detector()
    var inventory: InventoryComponent = ctx.rig.inventory()
    var ai_hauler: AIHaulerController = ctx.rig.hauler_ai()
    var task_system: HaulerTaskSystem = ctx.level_container.get_hauler_task_system()

    ai_hauler.bind_interactable_detector_component(interactable_detector)
    ai_hauler.bind_inventory_component(inventory)
    ai_hauler.bind_hauler_task_system(task_system)

    return true
