class_name MapBase
extends Node2D

@export var player_spawn_path: NodePath

@onready var spawn_system: SpawnSystem = %SpawnSystem
@onready var nav_root: Node = %Navigation
@onready var floor_tiles: TileMapLayer = %Floor


func get_nav_tilemap_layer() -> TileMapLayer:
    return floor_tiles


func get_player_spawn() -> Marker2D:
    return spawn_system.get_random_player_spawn()


func get_enemy1_spawn() -> Marker2D:
    return spawn_system.get_random_enemy1_spawn()


func get_enemy2_spawn() -> Marker2D:
    return spawn_system.get_random_enemy2_spawn()


func get_nav_root() -> Node:
    return nav_root
