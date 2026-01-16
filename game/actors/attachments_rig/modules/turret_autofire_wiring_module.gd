class_name TurretAutofireWiringModule
extends FeatureModuleBase


func id() -> StringName:
    return &"turret_autofire_wiring"


func stages() -> int:
    return ModuleHost.Stage.READY | ModuleHost.Stage.PRE_TREE


func is_applicable(ctx: RigContext) -> bool:
    return (
        ctx.rig != null
        and ctx.rig.shot_delay_timer() != null
        and ctx.rig.target_sensor() != null
        and ctx.rig.aim_fire_controller() != null
    )


func install(ctx: RigContext, stage: int) -> bool:
    var timer := ctx.rig.shot_delay_timer()
    var sensor := ctx.rig.target_sensor()
    var aim_fire_controller := ctx.rig.aim_fire_controller()

    if stage == ModuleHost.Stage.PRE_TREE:
        if ctx.team_id >= 0:
            PhysicsUtils.set_target_detector_collisions_for_team(sensor, ctx.team_id)
        if ctx.definition != null and "fire_range" in ctx.definition:
            sensor.set_target_sensor_radius(ctx.definition.fire_range)
        return true

    # READY: configure fire rate
    if ctx.definition != null and "fire_rate_per_sec" in ctx.definition and ctx.definition.fire_rate_per_sec > 0.0:
        timer.wait_time = 1.0 / ctx.definition.fire_rate_per_sec
        timer.timeout.connect(func(): aim_fire_controller.try_fire(RangedAttackTypes.DEFULT_TURRET_SHOT))

    return true
