class_name FiniteStateMachine
extends Node

var _ctx: Dictionary
var _state: FSMState
var _pending: FSMState = null
var _pending_reason: StringName = &""


func init(ctx: Dictionary, initial: FSMState) -> void:
    _ctx = ctx
    switch_to(initial, &"init")


func switch_to(next: FSMState, reason: StringName = &"") -> void:
    _pending = next
    _pending_reason = reason


func set_ctx_value(key: StringName, value: Variant) -> void:
    _ctx[key] = value


# Manual stepping (use this from Squad.tick)
func step(dt: float) -> void:
    _apply_pending()
    if _state != null:
        _state.update(_ctx, dt)
    _apply_pending()


func physics_step(dt: float) -> void:
    _apply_pending()
    if _state != null:
        _state.physics_update(_ctx, dt)
    _apply_pending()


func emit_event(event: StringName, data: Variant = null) -> void:
    if _state != null:
        _state.handle_event(_ctx, event, data)


func _apply_pending() -> void:
    if _pending == null:
        return
    if _state != null:
        _state.exit(_ctx)
    _state = _pending
    _pending = null
    _state.enter(_ctx)
