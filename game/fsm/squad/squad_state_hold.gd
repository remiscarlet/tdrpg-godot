class_name SquadStateHold
extends SquadStateBase


func enter(ctx: Dictionary) -> void:
    # Optional: clear path when entering hold.
    var rt := _rt(ctx)
    rt.path = PackedVector2Array()
    rt.path_index = 0


func physics_update(ctx: Dictionary, _dt: float) -> void:
    var rt := _rt(ctx)
    if rt.directive.kind != SquadDirective.Kind.HOLD:
        _switch_for_directive(ctx)
        return
    # Anchor stays put. Nothing to do.
