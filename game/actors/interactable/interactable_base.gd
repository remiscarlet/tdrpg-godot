class_name InteractableBase
extends Area2D

## Purpose: Base interactable area with interaction hooks.
var run_state: RunState


func _enter_tree() -> void:
    # Interactables are scene tiles which get spawned in by Godot systems - not us. Thus, we can't dependency inject.
    # As a workaround, use groups that we query and wire up from somewhere we control such as LevelContainer's _ready()
    add_to_group(Groups.RUN_STATE_CONSUMERS)


func bind_run_state(rs: RunState) -> void:
    run_state = rs


func can_interact(_interactor: Node2D) -> bool:
    return true


func interact(_interactor: Node2D) -> bool:
    return true


func interaction_priority() -> float:
    return 1.0
