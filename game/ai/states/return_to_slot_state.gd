class_name ReturnToSlotState
extends LocomotionIntentStateBase

## Purpose: AI state that returns to the assigned slot.
@export var arrive_radius: float = 16.0
@export var slowdown_radius: float = 80.0


func _watched_intent_id() -> StringName:
    return LocomotionIntents.RETURN_TO_SLOT_MOVE


func _build_intent() -> LocomotionIntent:
    return CommonIntents.move_to_point(
        _watched_intent_id(),
        _dest,
        arrive_radius,
        slowdown_radius,
        true,
    )
