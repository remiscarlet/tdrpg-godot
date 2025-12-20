extends Area2D

signal spawn_projectile(world_pos: Vector2, projectile_scene: PackedScene)

@export var projectile: PackedScene
@onready var shot_timer: Timer = $ShotDelayTimer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func fire_turret() -> void:
	spawn_projectile.emit(global_position, projectile)
