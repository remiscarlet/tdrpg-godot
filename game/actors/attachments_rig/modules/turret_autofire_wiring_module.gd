class_name TurretAutofireWiringModule
extends FeatureModuleBase


## Purpose: Feature module that wires Turret autofire into the attachments rig.
func id() -> StringName:
    return AttachmentModules.TURRET_AUTOFIRE_WIRING


func stages() -> int:
    return ModuleHost.Stage.READY | ModuleHost.Stage.PRE_TREE


func is_applicable(ctx: RigContext) -> bool:
    return (
        ctx.rig != null
        and ctx.rig.shot_delay_timer() != null
        and ctx.rig.target_sensor() != null
        and ctx.rig.aim_fire_controller() != null
    )


func _install_pre_tree(ctx: RigContext) -> bool:
    var sensor := ctx.rig.target_sensor()

    if ctx.team_id >= 0:
        sensor.set_team_id(ctx.team_id)
    if ctx.definition != null and "fire_range" in ctx.definition:
        sensor.set_target_sensor_radius(ctx.definition.fire_range)
    return true


func _install_ready(ctx: RigContext) -> bool:
    var timer := ctx.rig.shot_delay_timer()
    var aim_fire_controller := ctx.rig.aim_fire_controller()

    # READY: configure fire rate
    if ctx.definition != null and "fire_rate_per_sec" in ctx.definition and ctx.definition.fire_rate_per_sec > 0.0:
        timer.wait_time = 1.0 / ctx.definition.fire_rate_per_sec
        var cb := Callable(aim_fire_controller, "try_fire").bind(RangedAttackTypes.DEFULT_TURRET_SHOT)
        if not timer.timeout.is_connected(cb):
            timer.timeout.connect(cb)
        timer.start()

    return true
