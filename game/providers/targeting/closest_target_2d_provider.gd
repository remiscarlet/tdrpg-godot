class_name ClosestTarget2DProvider
extends TargetBaseProvider

var sensor: TargetSensor2DComponent


func get_target_direction(origin: Node2D) -> Vector2:
    var target := get_target_node(origin)

    if target == null:
        return Vector2.ZERO

    var target_location: Vector2
    var target_has_movement = "velocity" in target.root
    if not target_has_movement:
        # Naive - aim straight at current pos
        target_location = target.global_position
    else:
        # Leading aim
        # First, calculate how long bullet would take to travel to target's current pos.
        # Then take that `time`, and estimate target's new "leaded" position by moving their position forward by `time`
        var target_pos := target.global_position
        var target_velocity: Vector2 = target.root.velocity
        var dist_to_target := origin.global_position.distance_to(target_pos)

        var projectile_velocity := 600.0 # Default projectile velocity. TODO: Make more robust.
        var time_to_target := dist_to_target / projectile_velocity

        target_location = target_pos + target_velocity * time_to_target

    return origin.global_position.direction_to(target_location)


func get_target_node(origin: Node2D) -> Hurtbox2DComponent:
    var sensor_inited := _init_sensor(origin)
    if not sensor_inited:
        return null

    var best: Node2D = null
    var best_d2 := INF

    for t in sensor.get_candidates():
        if t == null or not is_instance_valid(t):
            continue

        var d2 := origin.global_position.distance_squared_to(t.global_position)
        if d2 >= best_d2:
            continue

        if not _has_line_of_sight(origin, t):
            continue

        best = t
        best_d2 = d2

    return best


func _init_sensor(origin: Node2D) -> bool:
    if sensor == null:
        sensor = (
            origin.get_node("AttachmentsRig/%FacingRoot/Sensors/TargetSensor2DComponent") as TargetSensor2DComponent
        )

    return sensor != null


func _has_line_of_sight(origin: Node2D, target: Hurtbox2DComponent) -> bool:
    var space := origin.get_world_2d().direct_space_state
    var params := PhysicsRayQueryParameters2D.create(origin.global_position, target.global_position)

    var team_id: int = target.root.definition.team_id
    var target_hurtbox_layer_mask: int = PhysicsUtils.get_hurtbox_layer(team_id)
    var world_collidables_mask: int = PhysicsUtils.get_world_collidables_mask()

    params.collision_mask = target_hurtbox_layer_mask | world_collidables_mask
    params.collide_with_areas = true

    var hit := space.intersect_ray(params)
    # print(hit)
    # We masked for world collidables or the enemy hurtbox.
    # If there is a hit, the collider will be one of the two.
    var hurtbox := hit.get("collider") as Hurtbox2DComponent
    return hurtbox != null
