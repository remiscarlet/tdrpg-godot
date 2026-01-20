class_name SquadStateBase
extends FSMState

const DIRECTIVE_CHANGED := &"directive_changed"

func _squad(ctx: Dictionary) -> Squad:
    return ctx[SquadFSMKeys.SQUAD]


func _cfg(ctx: Dictionary) -> SquadConfig:
    return ctx[SquadFSMKeys.CFG]


func _rt(ctx: Dictionary) -> SquadRuntime:
    return ctx[SquadFSMKeys.RT]


func _fsm(ctx: Dictionary) -> FiniteStateMachine:
    return ctx[SquadFSMKeys.FSM]


func _nav_map(ctx: Dictionary) -> RID:
    return ctx[SquadFSMKeys.NAV_MAP]


func _switch_for_directive(ctx: Dictionary) -> bool:
    # Returns true if we switched (caller should early-return).
    var rt := _rt(ctx)
    var fsm := _fsm(ctx)
    match rt.directive.kind:
        SquadDirective.Kind.HOLD:
            fsm.switch_to(ctx[SquadFSMKeys.ST_HOLD], DIRECTIVE_CHANGED)
            return true
        SquadDirective.Kind.MOVE_TO:
            fsm.switch_to(ctx[SquadFSMKeys.ST_MOVE], DIRECTIVE_CHANGED)
            return true
        SquadDirective.Kind.PATROL:
            fsm.switch_to(ctx[SquadFSMKeys.ST_PATROL], DIRECTIVE_CHANGED)
            return true
    return false
