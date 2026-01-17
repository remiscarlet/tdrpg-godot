class_name LocomotionIntentStateBase
extends Node

@export var driver_path: NodePath = NodePath("../../../NavIntentLocomotionDriver")
@export var body_path: NodePath
@export var clear_intent_on_exit: bool = true

var _driver: NavIntentLocomotionDriver
var _body: CombatantBase
var _dest: Vector2


func _ready() -> void:
    _driver = get_node_or_null(driver_path) as NavIntentLocomotionDriver
    _body = _resolve_body()

    if _driver == null:
        push_error("%s: driver_path is invalid." % name)
        return
    if _body == null:
        push_error("%s: could not resolve CombatantBase." % name)
        return

    _driver.intent_completed.connect(_on_driver_intent_completed)


func set_target(vec: Vector2) -> void:
    _dest = vec


# Called by FSM/supervisor
func enter() -> void:
    _apply_intent()


# Called by FSM/supervisor
func exit() -> void:
    if clear_intent_on_exit and _driver != null:
        _driver.clear_intent()


# Override point: return the intent you want active in this state.
func _build_intent() -> LocomotionIntent:
    return null


# Override point: which intent id should this state react to completing?
# Return &"" to ignore completions.
func _watched_intent_id() -> StringName:
    return &""


# Override point: what to do when watched intent completes (default: re-apply current intent)
func _on_watched_intent_completed() -> void:
    _apply_intent()


func _apply_intent() -> void:
    if _driver == null:
        return
    var intent := _build_intent()
    if intent == null:
        _driver.clear_intent()
        return
    _driver.set_intent(intent)


func _on_driver_intent_completed(intent_id: StringName) -> void:
    print("INTENT FINISHED: %s" % intent_id)
    var watched := _watched_intent_id()
    if watched == &"":
        return
    if intent_id == watched:
        _on_watched_intent_completed()


func _resolve_body() -> CombatantBase:
    if body_path != NodePath():
        return get_node_or_null(body_path) as CombatantBase

    var n := get_parent()
    while n != null:
        if n is CombatantBase:
            return n as CombatantBase
        n = n.get_parent()
    return null
