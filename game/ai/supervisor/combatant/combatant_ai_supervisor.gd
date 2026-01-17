class_name CombatantAISupervisor
extends Node

@export var enabled: bool = true
@export_group("Tether")
@export var max_slot_distance: float = 180.0
@export var recover_slot_distance: float = 120.0 # hysteresis
@export_group("States")
@export var follow_state_path: NodePath
@export var wander_state_path: NodePath
@export var return_state_path: NodePath

var _actor: CombatantBase
var _returning_to_slot: bool = false
var _follow_state: LocomotionIntentStateBase
var _wander_state: LocomotionIntentStateBase
var _return_state: LocomotionIntentStateBase
var _active_state: LocomotionIntentStateBase

func get_active_state() -> LocomotionIntentStateBase:
    return _active_state

func is_returning_to_slot() -> bool:
    return _returning_to_slot

func _ready() -> void:
    # Must run before the locomotion driver if you want same-tick intent changes.
    process_physics_priority = -20

    _actor = get_parent().get_parent().get_parent() as CombatantBase
    if _actor == null:
        push_error("%s: parent is not CombatantBase" % name)
        return

    _follow_state = get_node_or_null(follow_state_path) as LocomotionIntentStateBase
    _wander_state = get_node_or_null(wander_state_path) as LocomotionIntentStateBase
    _return_state = get_node_or_null(return_state_path) as LocomotionIntentStateBase

    # Default
    _transition_to(_wander_state)


func _physics_process(_delta: float) -> void:
    if not enabled or _actor == null:
        return

    # --- Guard: tether to assigned slot (preempt almost everything) ---
    if _actor.squad_link != null and _actor.squad_link.has_assigned_slot():
        var slot_pos: Vector2 = _actor.squad_link.get_assigned_slot_pos()
        var d2 := _actor.global_position.distance_squared_to(slot_pos)

        var max2 := max_slot_distance * max_slot_distance
        var rec2 := recover_slot_distance * recover_slot_distance

        if not _returning_to_slot and d2 > max2:
            _returning_to_slot = true
            _transition_to(_return_state)
            return

        if _returning_to_slot and d2 < rec2:
            _returning_to_slot = false
            # fall through

    # If still returning, do not select anything else.
    if _returning_to_slot:
        return

    # --- Normal selection ---
    if _actor.squad_link != null and _actor.squad_link.has_active_move_directive():
        _transition_to(_follow_state)
    else:
        _transition_to(_wander_state)


func _transition_to(next: LocomotionIntentStateBase) -> void:
    if next == _active_state:
        return

    if _active_state != null:
        _active_state.exit()

    print("Setting active state: %s" % DebugUtils.pretty_object(next))
    _active_state = next

    if _active_state != null:
        _active_state.enter()
