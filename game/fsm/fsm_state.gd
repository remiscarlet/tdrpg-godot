class_name FSMState
extends RefCounted


## Purpose: Base class for finite state machine states.
func enter(_ctx: Dictionary) -> void:
    pass


func exit(_ctx: Dictionary) -> void:
    pass


func update(_ctx: Dictionary, _dt: float) -> void:
    pass


func physics_update(_ctx: Dictionary, _dt: float) -> void:
    pass


# Optional: events are nicer than polling everything in update()
func handle_event(_ctx: Dictionary, _event: StringName, _data: Variant) -> void:
    pass
