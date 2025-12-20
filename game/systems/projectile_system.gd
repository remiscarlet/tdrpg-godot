extends Node

@onready var projectile_container: Node2D = $ProjectileContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func spawn(world_pos: Vector2, projectile_scene: PackedScene) -> void:
	pass

func spawn_default_projectile(world_pos: Vector2):
	pass
