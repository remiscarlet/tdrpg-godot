extends Node

var level_container_scene: PackedScene = preload("res://scenes/world/level_container.tscn")
var current_level: Node = null


func _ready() -> void:
    start_session()


func start_session() -> void:
    # Remove existing level subtree.
    if current_level != null:
        current_level.queue_free()

    # Instantiate a fresh LevelContainer
    var container := level_container_scene.instantiate()
    container.prepare_map("map01")
    add_child(container)
    current_level = container
