class_name DirectorDirective
extends RefCounted

enum Goal {
    UNKNOWN,
    SCOUT,
    PRESSURE,
    DEFEND,
    RANDOM_SPAWN,
}

var id: int = 0
var goal: Goal = Goal.UNKNOWN
var target_position: Vector2 = Vector2.ZERO
var priority: float = 1.0
var expires_ms: int = 0
var payload: Dictionary = { }


static func create(id: int, goal: Goal, target: Vector2, priority: float = 1.0, ttl_ms: int = 0) -> DirectorDirective:
    var d := DirectorDirective.new()
    d.id = id
    d.goal = goal
    d.target_position = target
    d.priority = priority
    if ttl_ms > 0:
        d.expires_ms = Time.get_ticks_msec() + ttl_ms
    return d
