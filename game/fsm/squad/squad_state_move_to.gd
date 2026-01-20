class_name SquadStateMoveTo
extends SquadStateBase

## Purpose: Squad FSM state for moving to a target.
const MOVE_COMPLETE := &"move_complete"


func physics_update(ctx: Dictionary, dt: float) -> void:
    var rt := _rt(ctx)
    if rt.directive.kind != SquadDirective.Kind.MOVE_TO:
        _switch_for_directive(ctx)
        return

    var squad := _squad(ctx)
    var nav_map := _nav_map(ctx)
    var dest: Vector2 = rt.directive.target_position

    var complete := squad.move_anchor_toward(dt, nav_map, dest)
    if complete:
        # Convert MOVE_TO into HOLD at destination (your current behavior, but in-state).
        squad.set_directive(SquadDirective.hold(dest))
        _fsm(ctx).switch_to(ctx[SquadFSMKeys.ST_HOLD], MOVE_COMPLETE)
