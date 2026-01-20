class_name LocomotionIntent
extends RefCounted

## Purpose: Data describing a locomotion intent and constraints.
var id: StringName = StringNames.EMPTY
# Callable() -> Vector2
var goal_provider: Callable
# Optional Callable() -> bool
var active_provider: Callable
# Consider arrived when within this radius of goal
var arrive_radius: float = 24.0
# Optional slowdown radius (0 = no slowdown). If > 0, speed scales down near goal.
var slowdown_radius: float = 0.0
# Repath gating for moving goals
var repath_min_interval_sec: float = 0.20
var repath_goal_delta: float = 24.0
# Complete behavior: if true, driver clears intent when arrived.
var complete_on_arrival: bool = false


func _init(
        _id: StringName = StringNames.EMPTY,
        _goal_provider: Callable = Callable(),
        _active_provider: Callable = Callable(),
) -> void:
    id = _id
    goal_provider = _goal_provider
    active_provider = _active_provider


func is_active() -> bool:
    if not active_provider.is_valid():
        return true
    return bool(active_provider.call())


func get_goal() -> Vector2:
    if not goal_provider.is_valid():
        return Vector2.INF
    return goal_provider.call()


func is_arrived(actor_pos: Vector2, goal: Vector2) -> bool:
    if not goal.is_finite():
        return true
    var r: float = max(arrive_radius, 0.0)
    return actor_pos.distance_squared_to(goal) <= r * r


func should_repath(
        last_goal: Vector2,
        new_goal: Vector2,
        since_last_repath_sec: float,
) -> bool:
    if since_last_repath_sec >= repath_min_interval_sec:
        return true

    if not last_goal.is_finite() or not new_goal.is_finite():
        return true

    var t := repath_goal_delta
    return last_goal.distance_squared_to(new_goal) >= (t * t)


func speed_scale_for_distance(dist_to_goal: float) -> float:
    if slowdown_radius <= 0.0:
        return 1.0
    return clampf(dist_to_goal / max(slowdown_radius, 0.001), 0.5, 1.0)
