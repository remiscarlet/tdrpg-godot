class_name SquadWiringModule
extends FeatureModuleBase


func id() -> StringName:
    return &"squad_wiring"


func stages() -> int:
    return ModuleHost.Stage.POST_READY


func is_applicable(ctx: RigContext) -> bool:
    return (
        ctx.rig != null
        and (ctx.actor as CombatantBase) != null
        and ctx.level_container != null
    )


func _install_post_ready(ctx: RigContext) -> bool:
    if ctx.level_container == null:
        print("Called _install_post_ready but ctx.level_container was null!")
        return false

    var squad_system: SquadSystem = ctx.level_container.get_squad_system()

    var actor := ctx.actor as CombatantBase
    if actor == null:
        print("No actor?")
        return false

    var squad_id := actor.spawn_context.squad_id
    var link: SquadLink = SquadLink.new(actor, squad_id, squad_system)

    print("Setting squad link: %s" % DebugUtils.pretty_object(link))
    actor.squad_link = link

    return true
