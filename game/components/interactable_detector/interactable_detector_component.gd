class_name InteractableDetectorComponent
extends AreaCandidateDetectorBase

## Purpose: Detector component for nearby interactables.
@onready var interactor: Node2D = get_parent().get_parent().get_parent().get_parent()


func try_interact() -> bool:
    var target := _pick_best_candidate()
    if target == null:
        return false

    if not target.can_interact(interactor):
        return false

    return target.interact(interactor)


func _get_candidate_from_area(area: Area2D):
    return area as InteractableBase


func _pick_best_candidate() -> InteractableBase:
    if candidates.is_empty():
        return null

    var best: InteractableBase = null
    var best_score := -INF

    for c in candidates:
        var candidate := c as InteractableBase
        if candidate == null or not is_instance_valid(candidate):
            continue

        # Example scoring: priority first, then distance
        var pri := float(candidate.interaction_priority()) * 10000.0
        var dist := interactor.global_position.distance_to(candidate.global_position)
        var score := pri - dist

        if score > best_score:
            best_score = score
            best = candidate

    return best
