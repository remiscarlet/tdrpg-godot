class_name CombatantAISupervisor
extends Node

enum Intent { WANDER, FOLLOW_SQUAD, RETURN_TO_SPAWNER, RETURN_TO_SLOT }

@export var enabled: bool = true
@export_group("Tether")
@export var max_slot_distance: float = 180.0
@export var recover_slot_distance: float = 120.0 # hysteresis
@export_group("States")
@export var follow_directive_state_path: NodePath
@export var wander_state_path: NodePath
@export var return_to_spawner_state_path: NodePath
@export var return_to_slot_state_path: NodePath

var _actor: CombatantBase
var _agent: NavigationAgent2D
var _returning_to_slot: bool = false
var _follow_directive_state: LocomotionIntentStateBase
var _wander_state: LocomotionIntentStateBase
var _return_to_spawner_state: LocomotionIntentStateBase
var _return_to_slot_state: LocomotionIntentStateBase
var _active_state: LocomotionIntentStateBase


func _ready() -> void:
    process_physics_priority = -20

    _actor = get_parent().get_parent().get_parent() as CombatantBase
    if _actor == null:
        push_error("%s: parent is not CombatantBase" % name)
        return

    _agent = get_parent().get_node("NavIntentLocomotionDriver/NavigationAgent2D")
    if _agent == null:
        push_error("%s: Could not find LocomotionDriver's NavigationAgent2D" % name)
        return

    _follow_directive_state = get_node_or_null(follow_directive_state_path) as LocomotionIntentStateBase
    _wander_state = get_node_or_null(wander_state_path) as LocomotionIntentStateBase
    _return_to_spawner_state = get_node_or_null(return_to_spawner_state_path) as LocomotionIntentStateBase
    _return_to_slot_state = get_node_or_null(return_to_slot_state_path) as LocomotionIntentStateBase

    # Default
    _wander_state.set_target(_actor.global_position)
    _transition_to(_wander_state)


func _physics_process(_delta: float) -> void:
    if not enabled or _actor == null:
        return

    var intent := _pick_intent()
    var target := _pick_target_for_intent(intent)

    # --- Constraint: tether to assigned slot (override target with hysteresis) ---
    if _actor.squad_link != null and _actor.squad_link.has_assigned_slot():
        var slot_pos: Vector2 = _actor.squad_link.get_assigned_slot_pos()
        var d2 := _actor.global_position.distance_squared_to(slot_pos)

        var max2 := max_slot_distance * max_slot_distance
        var rec2 := recover_slot_distance * recover_slot_distance

        if not _returning_to_slot and d2 > max2:
            _returning_to_slot = true
        elif _returning_to_slot and d2 < rec2:
            _returning_to_slot = false

        if _returning_to_slot:
            target = _snap_to_nav(slot_pos)
            intent = Intent.RETURN_TO_SLOT

    _apply_intent_and_target(intent, target)


func get_active_state() -> LocomotionIntentStateBase:
    return _active_state


func is_returning_to_slot() -> bool:
    return _returning_to_slot


func _snap_to_nav(p: Vector2) -> Vector2:
    var map := _agent.get_navigation_map()
    if map == RID():
        return p
    return NavigationServer2D.map_get_closest_point(map, p)


func _pick_intent() -> Intent:
    # Highest priority: explicit return-to-spawner retreat mode.
    if _should_return_to_spawner():
        return Intent.RETURN_TO_SPAWNER

    if _actor.squad_link != null and _actor.squad_link.has_active_move_directive():
        return Intent.FOLLOW_SQUAD

    return Intent.WANDER


func _should_return_to_spawner() -> bool:
    return false


func _pick_target_for_intent(intent: Intent) -> Vector2:
    match intent:
        Intent.WANDER:
            return NavUtils.get_some_random_reachable_point(
                _agent.get_navigation_map(),
                _actor.global_position,
                _wander_state.tries,
                _wander_state.wander_radius,
            )
        Intent.FOLLOW_SQUAD:
            return _actor.squad_link.get_assigned_slot_pos()
        Intent.RETURN_TO_SLOT:
            return _actor.squad_link.get_assigned_slot_pos()
        Intent.RETURN_TO_SPAWNER:
            return _actor.squad_link.get_return_pos()

    return _actor.global_position


func _apply_intent_and_target(intent: Intent, target: Vector2) -> void:
    match intent:
        Intent.WANDER:
            _wander_state.set_target(target) # if applicable
            _transition_to(_wander_state)
        Intent.FOLLOW_SQUAD:
            _follow_directive_state.set_target(target)
            _transition_to(_follow_directive_state)
        Intent.RETURN_TO_SLOT:
            _return_to_slot_state.set_target(target)
            _transition_to(_return_to_slot_state)
        Intent.RETURN_TO_SPAWNER:
            _return_to_spawner_state.set_target(target)
            _transition_to(_return_to_spawner_state)


func _transition_to(next: LocomotionIntentStateBase) -> void:
    if next == _active_state:
        return

    print("Exiting from prev state? %s" % _active_state)
    if _active_state != null:
        _active_state.exit()

    _active_state = next

    print("Entering next state? %s" % _active_state)
    if _active_state != null:
        _active_state.enter()
