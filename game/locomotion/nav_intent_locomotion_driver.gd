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

@export_group("Avoidance")
@export var use_avoidance: bool = true
# IMPORTANT: set this to your combatant's real top speed (px/s). Avoidance assumes this cap.
@export var avoidance_base_speed: float = 160.0
@export var avoidance_layers: int = 1
@export var avoidance_mask: int = 1
@export var avoidance_priority: float = 1.0

var _intent: LocomotionIntent
var _last_goal: Vector2 = Vector2.INF
var _since_repath: float = 9999.0
var _target_set_this_frame: bool = false

# Avoidance bookkeeping (so we only apply safe velocity for the current physics frame)
var _avoidance_request_frame: int = -1
var _avoidance_requested_scale: float = 0.0
var _avoidance_applied_this_frame: bool = false

@onready var _body: CombatantBase = _find_body()
@onready var _agent: NavigationAgent2D = get_node_or_null(nav_agent_path) as NavigationAgent2D


func _ready() -> void:
    # Make sure this runs before CombatantBase motor (which we set to 10).
    process_physics_priority = PhysicsPriorities.LOCOMOTION_DRIVER

    # Avoid querying paths in _ready() before navigation map sync
    _setup.call_deferred()

    # Needed to receive the computed safe velocity.
    if _agent != null and not _agent.velocity_computed.is_connected(_on_agent_velocity_computed):
        _agent.velocity_computed.connect(_on_agent_velocity_computed)


func _physics_process(delta: float) -> void:
    if not enabled:
        return
    if _body == null or _agent == null:
        return

    _target_set_this_frame = false
    _avoidance_applied_this_frame = false
    _avoidance_requested_scale = 0.0

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
    var requested_scale := 1.0
    if _last_goal.is_finite():
        var dist_to_goal := _body.global_position.distance_to(_last_goal)
        requested_scale = _intent.speed_scale_for_distance(dist_to_goal)

    # --- Avoidance path: feed desired velocity -> apply safe velocity in signal ---
    if use_avoidance and _agent.avoidance_enabled:
        _avoidance_request_frame = Engine.get_physics_frames()
        _avoidance_requested_scale = requested_scale

        # "Preferred" velocity this frame (px/s).
        var preferred_velocity := dir * (avoidance_base_speed * requested_scale)

        # This triggers avoidance processing; safe velocity arrives via velocity_computed.
        _agent.set_velocity(preferred_velocity)

        # Safety fallback: if for any reason we didn't receive/apply safe vel this frame,
        # keep moving normally rather than stalling.
        if not _avoidance_applied_this_frame:
            _apply_local_movement_modifiers(dir, requested_scale)

        return

    # --- No avoidance: keep your original behavior ---
    _apply_local_movement_modifiers(dir, requested_scale)


func _on_agent_velocity_computed(safe_velocity: Vector2) -> void:
    # Only apply for the frame where we requested avoidance this tick.
    if Engine.get_physics_frames() != _avoidance_request_frame:
        return
    if not enabled or _body == null:
        return
    if _intent == null or not _intent.is_active():
        return
    if not use_avoidance or _agent == null or not _agent.avoidance_enabled:
        return

    _avoidance_applied_this_frame = true

    var speed := safe_velocity.length()
    if speed <= 0.001:
        _apply_local_movement_modifiers(Vector2.ZERO, 0.0)
        return

    var safe_dir := safe_velocity / speed

    # Convert safe velocity (px/s) back into your motor contract (dir + scale).
    # Scale is relative to avoidance_base_speed, NOT relative to requested speed.
    var safe_scale: float = speed / max(avoidance_base_speed, 0.001)

    # Preserve your "slow down near goal" intent even if avoidance returns something odd.
    safe_scale = min(safe_scale, _avoidance_requested_scale)

    _apply_local_movement_modifiers(safe_dir, safe_scale)

func _apply_local_movement_modifiers(dir: Vector2, scale: float) -> void:
    var new_dir := dir
    var new_scale := scale

    _body.set_desired_move(new_dir, new_scale)

func set_intent(intent: LocomotionIntent) -> void:
    _intent = intent
    _since_repath = 9999.0
    _last_goal = Vector2.INF
    _target_set_this_frame = false


func clear_intent() -> void:
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

        # Configure avoidance (optional; you can also set these on the node in the editor).
        _agent.avoidance_enabled = use_avoidance
        if use_avoidance:
            _agent.avoidance_layers = avoidance_layers
            _agent.avoidance_mask = avoidance_mask
            _agent.avoidance_priority = avoidance_priority
            _agent.max_speed = avoidance_base_speed


func _stop_if_no_intent() -> void:
    if stop_when_no_intent and _intent == null:
        _body.set_desired_move(Vector2.ZERO, 0.0)

        # Prevent “residual” avoidance motion.
        if use_avoidance and _agent != null and _agent.avoidance_enabled:
            _agent.set_velocity(Vector2.ZERO)


func _find_body() -> CombatantBase:
    var n := get_parent()
    while n != null:
        if n is CombatantBase:
            return n as CombatantBase
        n = n.get_parent()
    return null
