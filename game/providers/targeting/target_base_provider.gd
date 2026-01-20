class_name TargetBaseProvider
extends RefCounted


## Purpose: Base class for targeting providers.
## If Vector2.ZERO is returned, it means no target.
func get_target_direction(_origin: Node2D) -> Vector2:
    return Vector2.ZERO
