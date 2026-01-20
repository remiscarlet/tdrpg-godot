class_name SquadStatePatrol
extends SquadStateBase

const PATROL_EMPTY := &"patrol_empty"

func physics_update(ctx: Dictionary, dt: float) -> void:
    var rt := _rt(ctx)
    if rt.directive.kind != SquadDirective.Kind.PATROL:
        _switch_for_directive(ctx)
        return

    if rt.directive.patrol_points.size() == 0:
        # Degenerate patrol: just hold where you are.
        _squad(ctx).set_directive(SquadDirective.hold(rt.anchor_position))
        _fsm(ctx).switch_to(ctx[SquadFSMKeys.ST_HOLD], PATROL_EMPTY)
        return

    var squad := _squad(ctx)
    var nav_map := _nav_map(ctx)
    var wp: Vector2 = rt.get_patrol_point()

    var reached := squad.move_anchor_toward(dt, nav_map, wp)
    if reached:
        rt.increment_patrol_index()
        # Next tick we’ll walk toward the next waypoint.
