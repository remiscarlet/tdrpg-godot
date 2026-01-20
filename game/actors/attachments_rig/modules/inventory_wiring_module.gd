class_name InventoryWiringModule
extends FeatureModuleBase


func id() -> StringName:
    return AttachmentModules.INVENTORY_WIRING


func stages() -> int:
    return ModuleHost.Stage.READY | ModuleHost.Stage.PRE_TREE


func is_applicable(ctx: RigContext) -> bool:
    return ctx.rig != null and ctx.rig.inventory() != null and ctx.rig.pickupbox() != null


func _install_pre_tree(ctx: RigContext) -> bool:
    var pb := ctx.rig.pickupbox()

    if ctx.team_id >= 0:
        var sensorbox := pb.get_node("PickupSensorArea")
        PhysicsUtils.set_pickupbox_collisions_for_team(sensorbox, ctx.team_id)
    return true


func _install_ready(ctx: RigContext) -> bool:
    var inv := ctx.rig.inventory()
    var pb := ctx.rig.pickupbox()

    var cap := 0
    if ctx.definition != null and "inventory_capacity" in ctx.definition:
        cap = ctx.definition.inventory_capacity
    inv.configure(pb, cap)
    return true
