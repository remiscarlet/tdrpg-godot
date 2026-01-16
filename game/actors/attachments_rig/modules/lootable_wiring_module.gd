class_name LootableWiringModule
extends FeatureModuleBase


func id() -> StringName:
    return &"lootable_wiring"


func stages() -> int:
    return ModuleHost.Stage.POST_READY


func is_applicable(ctx: RigContext) -> bool:
    return ctx.rig != null and ctx.level_container != null and ctx.rig.lootable() != null


func install(ctx: RigContext, stage: int) -> bool:
    print("Installing %s during stage %d with ctx: %s" % [id(), stage, ctx])

    match stage:
        ModuleHost.Stage.POST_READY:
            return _install_post_ready(ctx)
        _:
            return true


func _install_post_ready(ctx: RigContext) -> bool:
    if ctx.level_container == null:
        print("Called _install_post_ready but ctx.level_container was null!")
        return false

    var loot: LootableComponent = ctx.rig.lootable()
    loot.bind_loot_system(ctx.level_container.get_loot_system())

    return true
