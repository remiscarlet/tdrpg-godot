extends TargetBaseProvider
class_name ClosestTarget2DProvider

var sensor: TargetSensor2DComponent
var require_line_of_sight: bool = false
var los_mask: int = Layers.WORLD_SOLID

func _init_sensor(origin: Node2D) -> bool:
	if sensor == null:
		# Optional auto-find if you follow a convention
		sensor = origin.get_node_or_null("AttachmentsRoot/TargetSensor2DComponent") as TargetSensor2DComponent

	return sensor != null

func get_target_direction(origin: Node2D) -> Vector2:
	var target := get_target_node(origin)

	if target == null:
		return Vector2.ZERO

	return origin.global_position.direction_to(target.global_position)

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