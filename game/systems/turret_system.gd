extends Node

@onready var turret_container: Node2D = $TurretContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func try_build_turret(player: Node, world_pos: Vector2, turret_scene: PackedScene) -> void:
	print("Trying to build turret")

	var turret: Node = turret_scene.instantiate()
	turret_container.add_child(turret)
	turret.global_position = world_pos
	# turret.spawn_projectile.connect()
