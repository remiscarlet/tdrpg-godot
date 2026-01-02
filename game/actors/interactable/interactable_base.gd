extends Area2D
class_name InteractableBase

@onready var target_sensor: TargetSensor2DComponent = $"AttachmentsRoot/TargetSensor2DComponent"

var run_state: RunState

func _enter_tree() -> void:
    add_to_group("run_state_consumers")

func set_run_state(rs: RunState) -> void:
    run_state = rs

func can_interact(interactor: Node2D) -> bool:
    return true

func interact(interactor: Node2D) -> bool:
    return true

func interaction_priority() -> float:
    return 1.0