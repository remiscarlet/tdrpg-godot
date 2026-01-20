class_name SpreadShotMode
extends ShotModeDefinition

## Purpose: Shot mode resource for spread firing.
@export var sub_projectiles: int = 3

@export_range(0.01, PI, PI / 32, "radians_as_degrees")
var angle_spread: float = PI / 4
