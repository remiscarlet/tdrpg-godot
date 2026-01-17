class_name InteractableDetectorComponent
extends Area2D

@export var sensor_path: NodePath

var candidates: Array[InteractableBase] = []

@onready var sensor: Area2D = get_node(sensor_path) as Area2D
# CombatantRoot/AttachmentsRig/FacingRoot/Sensors
@onready var interactor: Node2D = get_parent().get_parent().get_parent().get_parent()


func _ready() -> void:
    sensor.area_entered.connect(_on_area_entered)
    sensor.area_exited.connect(_on_area_exited)


func try_interact() -> bool:
    var target := _pick_best_candidate()
    if target == null:
        return false

    if not target.can_interact(interactor):
        return false

    return target.interact(interactor)


func _on_area_entered(area: Area2D) -> void:
    var maybe := area as InteractableBase
    if maybe and not candidates.has(maybe):
        # print("Adding candidate interactable: %s" % maybe)
        candidates.append(maybe)


func _on_area_exited(area: Area2D) -> void:
    var maybe := area as InteractableBase
    if maybe:
        # print("Removing candidate interactable: %s" % maybe)
        candidates.erase(maybe)


func _pick_best_candidate() -> InteractableBase:
    if candidates.is_empty():
        return null

    var best: InteractableBase = null
    var best_score := -INF

    for c in candidates:
        if c == null or not is_instance_valid(c):
            continue

        # Example scoring: priority first, then distance
        var pri := float(c.interaction_priority()) * 10000.0
        var dist := interactor.global_position.distance_to(c.global_position)
        var score := pri - dist

        if score > best_score:
            best_score = score
            best = c

    return best
