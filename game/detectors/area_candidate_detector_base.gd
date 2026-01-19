class_name AreaCandidateDetectorBase
extends Area2D

@export var sensor_path: NodePath = NodePath(".")

var candidates: Array = []

@onready var sensor: Area2D = _resolve_sensor()


func _ready() -> void:
    if sensor == null:
        push_error("%s requires an Area2D at sensor_path." % self)
        return
    sensor.area_entered.connect(_on_area_entered)
    sensor.area_exited.connect(_on_area_exited)


func get_candidates() -> Array:
    _prune_invalid()
    return candidates


func _resolve_sensor() -> Area2D:
    return get_node_or_null(sensor_path) as Area2D


func _get_candidate_from_area(area: Area2D) -> Node:
    return area


func _candidate_entered(_candidate) -> void:
    pass


func _candidate_exited(_candidate) -> void:
    pass


func _on_area_entered(area: Area2D) -> void:
    var candidate := _get_candidate_from_area(area)
    if candidate == null:
        return
    if candidates.has(candidate):
        return
    candidates.append(candidate)
    _candidate_entered(candidate)


func _on_area_exited(area: Area2D) -> void:
    var candidate := _get_candidate_from_area(area)
    if candidate == null:
        return
    candidates.erase(candidate)
    _candidate_exited(candidate)


func _prune_invalid() -> void:
    for i in range(candidates.size() - 1, -1, -1):
        if not is_instance_valid(candidates[i]):
            candidates.remove_at(i)
