extends Node

@onready var level_container: Node = $World/LevelContainer

var level_container_scene: PackedScene = preload("res://scenes/world/level_container.tscn")
var current_level: Node = null

# Simple registry; later you can replace this with Resources / data-driven tables.
var maps := {
	"map01": preload("res://scenes/world/maps/test_map.tscn"),
}


func _ready() -> void:
	var level = level_container_scene.instantiate()
	add_child(level)


func load_map(map_id: String) -> void:
	var map_scene: PackedScene = maps.get(map_id, null)
	assert(map_scene != null)

	# Remove existing level subtree.
	if current_level != null:
		current_level.queue_free()

	# Instantiate a fresh LevelContainer, point it at the map, attach it.
	var container := level_container_scene.instantiate()
	container.map_content_scene = map_scene
	level_container.add_child(container)
	current_level = container
