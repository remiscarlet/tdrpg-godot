class_name GoalProviders
extends RefCounted


static func static_point(p: Vector2) -> Callable:
    return func() -> Vector2:
        return p


static func method_vec2(obj: Object, method_name: StringName) -> Callable:
    return func() -> Vector2:
        if not is_instance_valid(obj):
            return Vector2.INF
        if not obj.has_method(method_name):
            return Vector2.INF
        return obj.call(method_name)


static func method_bool(obj: Object, method_name: StringName) -> Callable:
    return func() -> bool:
        if not is_instance_valid(obj):
            return false
        if not obj.has_method(method_name):
            return false
        return bool(obj.call(method_name))


# SquadLink adapters (match your existing SquadLink stub)
static func squad_return_pos(squad_link: SquadLink) -> Callable:
    # squad_link.get_return_pos() -> Vector2
    return method_vec2(squad_link, &"get_return_pos")


static func squad_follow_goal_pos(squad_link: SquadLink) -> Callable:
    # squad_link.get_follow_directive_pos() -> Vector2
    return method_vec2(squad_link, &"get_follow_directive_pos")


static func squad_has_directive_goal(squad_link: SquadLink) -> Callable:
    # squad_link.has_active_follow_goal() -> bool
    return method_bool(squad_link, &"has_active_move_directive")
