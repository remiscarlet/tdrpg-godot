class_name CommonIntents
extends RefCounted


static func move_to_point(
        id: StringName,
        goal: Vector2,
        arrive_radius: float = 24.0,
        slowdown_radius: float = 0.0,
        complete_on_arrival: bool = true,
) -> LocomotionIntent:
    print("move_to_point to %s" % goal)
    var intent := LocomotionIntent.new(id, GoalProviders.static_point(goal), Callable())
    intent.arrive_radius = arrive_radius
    intent.slowdown_radius = slowdown_radius
    intent.complete_on_arrival = complete_on_arrival
    return intent


static func return_to_slot(
        squad_link: Object,
        arrive_radius: float = 18.0,
        slowdown_radius: float = 48.0,
) -> LocomotionIntent:
    var intent := LocomotionIntent.new(
        LocomotionIntents.RETURN_TO_SLOT_MOVE,
        GoalProviders.squad_return_pos(squad_link),
        Callable(), # always active
    )
    print("return_to_slot to goal %s" % intent.get_goal())

    intent.arrive_radius = arrive_radius
    intent.slowdown_radius = slowdown_radius
    intent.repath_min_interval_sec = 0.35
    intent.repath_goal_delta = 8.0
    intent.complete_on_arrival = true
    return intent


static func follow_squad_goal(
        squad_link: Object,
        arrive_radius: float = 24.0,
        slowdown_radius: float = 0.0,
) -> LocomotionIntent:
    var intent := LocomotionIntent.new(
        &"follow_squad_goal",
        GoalProviders.squad_follow_goal_pos(squad_link),
        GoalProviders.squad_has_directive_goal(squad_link),
    )
    intent.arrive_radius = arrive_radius
    intent.slowdown_radius = slowdown_radius
    intent.repath_min_interval_sec = 0.10
    intent.repath_goal_delta = 16.0
    intent.complete_on_arrival = false
    return intent
