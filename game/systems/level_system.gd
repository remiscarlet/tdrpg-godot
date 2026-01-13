extends Node
class_name LevelSystem

var level_container_scene: PackedScene = preload("res://scenes/world/level_container.tscn")
var current_level: Node = null

var run_state: RunState


func bind_run_state(state: RunState) -> void:
    run_state = state


func start_session() -> LevelContainer:
    # Remove existing level subtree.
    if current_level != null:
        current_level.queue_free()

    # Instantiate a fresh LevelContainer
    var container := level_container_scene.instantiate()
    container.prepare_map("map01")
    container.bind_run_state(run_state)
    add_child(container)
    current_level = container

    return container
