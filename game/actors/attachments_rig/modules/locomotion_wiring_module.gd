class_name LocomotionWiringModule
extends FeatureModuleBase


func id() -> StringName:
    return AttachmentModules.LOCOMOTION_WIRING


func stages() -> int:
    return ModuleHost.Stage.READY


func is_applicable(ctx: RigContext) -> bool:
    return ctx.rig != null and _locomotion_driver(ctx) != null


func _install_ready(ctx: RigContext) -> bool:
    var driver := _locomotion_driver(ctx)
    if driver == null:
        return false

    driver.set_body(ctx.actor as CombatantBase)

    # Configure avoidance to collide with world only (matches prior runtime behavior).
    driver.avoidance_layers = PhysicsUtils.get_world_collidables_mask()
    driver.avoidance_mask = PhysicsUtils.get_world_collidables_mask()

    # Ensure flock detector exists and uses detector collisions.
    var flock := driver.get_node_or_null(driver.flock_detector_path) as FlockDetector
    if flock != null:
        # FlockDetector already sets FLOCK layer/mask in its script; nothing else required.
        pass

    return true


func _locomotion_driver(ctx: RigContext) -> NavIntentLocomotionDriver:
    var ctr := ctx.rig.controllers_root()
    return ctr.get_node_or_null("NavIntentLocomotionDriver") as NavIntentLocomotionDriver if ctr != null else null
