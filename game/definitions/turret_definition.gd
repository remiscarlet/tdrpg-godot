extends CombatantDefinition
class_name TurretDefinition

var scene: PackedScene = preload("res://scenes/turrets/default_turret/default_turret.tscn")

@export var build_cost: Dictionary[StringName, int] = {} # e.g. {"scrap": 25}
@export var fire_range: float = 240.0
@export var fire_rate_per_sec: float = 2.0
