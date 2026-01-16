class_name DefaultTurret
extends Area2D

var level_container: LevelContainer
var fire_rate_per_sec: float
var sensor_radius: float
var definition: TurretDefinition


# Lifecycle methods
func _enter_tree() -> void:
    process_mode = Node.PROCESS_MODE_DISABLED


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    process_mode = Node.PROCESS_MODE_INHERIT


# Public methods
func configure_pre_ready(ctx: TurretSpawnContext, def: TurretDefinition) -> void:
    definition = def
    fire_rate_per_sec = def.fire_rate_per_sec
    sensor_radius = def.fire_range
    global_position = ctx.origin
