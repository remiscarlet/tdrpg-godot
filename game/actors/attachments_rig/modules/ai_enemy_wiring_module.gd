class_name AIEnemyWiringModule
extends FeatureModuleBase

## Purpose: Feature module that wires Ai enemy into the attachments rig.
const PhysicsUtils = preload("res://game/utils/physics_utils.gd")


func id() -> StringName:
    return AttachmentModules.AI_ENEMY_WIRING


func stages() -> int:
    return ModuleHost.Stage.READY


func is_applicable(ctx: RigContext) -> bool:
    return ctx.rig != null and ctx.rig.sensors_root() != null and _player_detector(ctx) != null


func _install_ready(ctx: RigContext) -> bool:
    var detector := _player_detector(ctx)
    if detector == null:
        return false

    # Align detector collisions with team detector settings.
    PhysicsUtils.set_hostile_detector_collisions_for_team(detector, ctx.team_id)
    detector.monitoring = true

    return true


func _player_detector(ctx: RigContext) -> PlayerSightingDetector:
    var sr := ctx.rig.sensors_root()
    return sr.get_node_or_null("PlayerSightingDetector") as PlayerSightingDetector if sr != null else null
