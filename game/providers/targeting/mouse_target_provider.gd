extends TargetBaseProvider
class_name MouseTargetProvider


## If Vector2.ZERO is returned, it means no target.
func get_target_direction(origin: Node2D) -> Vector2:
    return MouseUtils.get_dir_to_mouse(origin)
