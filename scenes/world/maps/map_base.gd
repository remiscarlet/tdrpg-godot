class_name MapBase
extends Node2D

@export var player_spawn_path: NodePath
@onready var spawn_system: SpawnSystem = $SpawnSystem

func get_player_spawn() -> Marker2D:
	return spawn_system.get_random_player_spawn()

func get_enemy1_spawn() -> Marker2D:
	return spawn_system.get_random_enemy1_spawn()

func get_enemy2_spawn() -> Marker2D:
	return spawn_system.get_random_enemy2_spawn()