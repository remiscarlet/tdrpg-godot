class_name DamageableCoreModule
extends FeatureModuleBase


## Purpose: Feature module that wires the damageable core into the attachments rig.
func id() -> StringName:
    return AttachmentModules.DAMAGEABLE_CORE


func stages() -> int:
    return ModuleHost.Stage.PRE_TREE | ModuleHost.Stage.READY


func is_applicable(ctx: RigContext) -> bool:
    return ctx.rig != null and ctx.rig.health() != null and ctx.rig.hurtbox() != null


func _install_pre_tree(ctx: RigContext) -> bool:
    var health := ctx.rig.health()

    if ctx.definition != null and "max_hp" in ctx.definition:
        health.set_max_health(ctx.definition.max_hp)
    return true


func _install_ready(ctx: RigContext) -> bool:
    print("Installing %s" % ctx.tag())
    var health := ctx.rig.health()
    var hurtbox := ctx.rig.hurtbox()

    # READY
    hurtbox.bind_root(ctx.actor)
    hurtbox.bind_health_component(health)
    PhysicsUtils.set_hurtbox_collisions_for_team(hurtbox, ctx.team_id)

    var cb := Callable(self, "_on_died").bind(ctx.actor)
    if not health.died.is_connected(cb):
        health.died.connect(cb)
    return true


func _on_died(_src: Node, actor: Node2D) -> void:
    actor.queue_free()
