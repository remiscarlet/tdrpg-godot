class_name NavIntentLocomotionDriver
extends Node2D

signal intent_completed(intent_id: StringName)

@export var enabled: bool = true
@export_flags_2d_navigation var navigation_layers := 1
@export_group("Bindings")
@export var nav_agent_path: NodePath = NodePath("NavigationAgent2D")
@export_group("Output")
@export var stop_when_no_intent: bool = true
@export var stop_when_finished: bool = true

var _intent: LocomotionIntent
var _last_goal: Vector2 = Vector2.INF
var _since_repath: float = 9999.0
var _target_set_this_frame: bool = false

@onready var _body: CombatantBase = _find_body()
@onready var _agent: NavigationAgent2D = get_node_or_null(nav_agent_path) as NavigationAgent2D


func _ready() -> void:
    # Make sure this runs before CombatantBase motor (which we set to 10).
    process_physics_priority = 0

    # Avoid querying paths in _ready() before navigation map sync
    _setup.call_deferred()


func _physics_process(delta: float) -> void:
    if not enabled:
        return

    if _body == null or _agent == null:
        print(_body, _agent)
        return

    _target_set_this_frame = false

    if _intent == null:
        _stop_if_no_intent()
        return

    if not _intent.is_active():
        clear_intent()
        _stop_if_no_intent()
        return

    _since_repath += delta

    var goal := _intent.get_goal()
    if not goal.is_finite():
        clear_intent()
        _stop_if_no_intent()
        return

    if _intent.should_repath(_last_goal, goal, _since_repath):
        _agent.target_position = goal
        _last_goal = goal
        _since_repath = 0.0
        _target_set_this_frame = true

    # If finished and we didn't just set a new target, stop output.
    if _agent.is_navigation_finished() and not _target_set_this_frame:
        _stop_if_no_intent()

        if _intent.complete_on_arrival and _intent.is_arrived(_body.global_position, _last_goal):
            var finished_id := _intent.id
            clear_intent()
            intent_completed.emit(finished_id)

        return

    var next_pos := _agent.get_next_path_position()
    var to_next := next_pos - _body.global_position
    var dist := to_next.length()

    if dist <= 0.001:
        _stop_if_no_intent()
        return

    var dir := to_next / dist

    # Optional slowdown when nearing the final goal (not waypoint distance).
    var speed_scale := 1.0
    if _last_goal.is_finite():
        var dist_to_goal := _body.global_position.distance_to(_last_goal)
        speed_scale = _intent.speed_scale_for_distance(dist_to_goal)

    _body.set_desired_move(dir, speed_scale)


func set_intent(intent: LocomotionIntent) -> void:
    _intent = intent
    _since_repath = 9999.0
    _last_goal = Vector2.INF
    _target_set_this_frame = false


func clear_intent() -> void:
    # DebugUtils.print_caller()
    # print("Clearing intent!")
    _intent = null
    _since_repath = 9999.0
    _last_goal = Vector2.INF
    _target_set_this_frame = false


func has_intent() -> bool:
    return _intent != null


func current_intent_id() -> StringName:
    return _intent.id if _intent != null else &""


func get_last_goal() -> Vector2:
    return _last_goal


func get_agent() -> NavigationAgent2D:
    return _agent


func is_navigation_finished() -> bool:
    return _agent == null or _agent.is_navigation_finished()


func _setup() -> void:
    await get_tree().physics_frame
    if _agent != null:
        _agent.navigation_layers = navigation_layers


func _stop_if_no_intent() -> void:
    if stop_when_no_intent and _intent == null:
        print("Stopping - no intent")
        _body.set_desired_move(Vector2.ZERO, 0.0)


func _find_body() -> CombatantBase:
    var n := get_parent()
    while n != null:
        if n is CombatantBase:
            return n as CombatantBase
        n = n.get_parent()
    return null
