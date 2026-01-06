extends TargetBaseProvider
class_name ClosestTarget2DProvider

var sensor: TargetSensor2DComponent
var require_line_of_sight: bool = false
var los_mask: int = Layers.WORLD_SOLID

func _init_sensor(origin: Node2D) -> bool:
	if sensor == null:
		sensor = origin.get_node("AttachmentsRig/%FacingRoot/Sensors/TargetSensor2DComponent") as TargetSensor2DComponent

	return sensor != null

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

		var projectile_velocity := 600.0 # Default projectile velocity. Make more robust.
		var time_to_target := dist_to_target / projectile_velocity

		target_location = target_pos + target_velocity * time_to_target

	return origin.global_position.direction_to(target_location)

func get_target_node(origin: Node2D) -> Node2D:
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

		if require_line_of_sight and not _has_line_of_sight(origin, t):
			continue

		best = t
		best_d2 = d2

	return best

func _has_line_of_sight(origin: Node2D, target: Node2D) -> bool:
	var space := origin.get_world_2d().direct_space_state
	var params := PhysicsRayQueryParameters2D.create(origin.global_position, target.global_position)
	params.collision_mask = los_mask
	# Optionally exclude origin/target colliders if needed:
	# params.exclude = [origin.get_rid(), target.get_rid()]
	var hit := space.intersect_ray(params)
	return hit.is_empty()