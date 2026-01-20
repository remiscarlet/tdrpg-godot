class_name SquadConfig
extends Resource

## Purpose: Configuration resource for squad settings.
@export var nav_layers: int = Layers.NAV_WALK
@export var anchor_speed: float = 140.0
@export var anchor_arrival_radius: float = 10.0
@export var path_optimize: bool = true
@export var cohesion_radius_idle: float = 72.0
@export var cohesion_radius_move: float = 36.0
@export var cohesion_radius_patrol: float = 48.0
