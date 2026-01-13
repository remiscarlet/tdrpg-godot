extends RefCounted
class_name TargetBaseProvider


## If Vector2.ZERO is returned, it means no target.
func get_target_direction(_origin: Node2D) -> Vector2:
    return Vector2.ZERO
