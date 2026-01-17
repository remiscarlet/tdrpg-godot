class_name WanderState
extends LocomotionIntentStateBase

@export var nav_agent_path: NodePath = NodePath("../../../NavIntentLocomotionDriver/NavigationAgent2D")
@export var wander_radius: float = 400.0
@export var tries: int = 12
@export var arrive_radius: float = 24.0
@export var slowdown_radius: float = 80.0
# Optional: force repick even if not “arrived”
@export var repick_interval_sec: float = 0.0

var _agent: NavigationAgent2D
var _nav_rid: RID
var _repick_timer: Timer


func _ready() -> void:
    super._ready()

    _agent = get_node_or_null(nav_agent_path) as NavigationAgent2D
    if _agent == null:
        push_error("%s: nav_agent_path is invalid." % name)
        return

    # If you need the map to be synced first, this keeps it safe.
    _setup.call_deferred()

    if repick_interval_sec > 0.0:
        _repick_timer = Timer.new()
        _repick_timer.one_shot = false
        _repick_timer.wait_time = repick_interval_sec
        add_child(_repick_timer)
        _repick_timer.timeout.connect(_apply_intent)


func enter() -> void:
    super.enter()
    if _repick_timer != null:
        _repick_timer.start()


func exit() -> void:
    if _repick_timer != null:
        _repick_timer.stop()
    super.exit()


func _setup() -> void:
    await get_tree().physics_frame
    _nav_rid = _agent.get_navigation_map()


func _watched_intent_id() -> StringName:
    return LocomotionIntents.WANDER_MOVE


func _build_intent() -> LocomotionIntent:
    if _body == null or _agent == null:
        return null

    if _nav_rid == RID():
        _nav_rid = _agent.get_navigation_map()

    print("Building intent bound for: %s" % _dest)
    var intent: LocomotionIntent = CommonIntents.move_to_point(
        _watched_intent_id(),
        _dest,
        arrive_radius,
        slowdown_radius,
        true,
    )
    return intent
