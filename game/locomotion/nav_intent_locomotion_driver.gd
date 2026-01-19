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
@export_group("Local Modifiers/Flocking")
@export var enable_flocking: bool = true
@export var flock_detector_path: NodePath = NodePath("FlockDetector")
@export var flock_radius: float = 80.0
##  Separation: steer to avoid crowding local flockmates
@export var flock_separation_weight: float = 1.2
##  Alignment: steer towards the average heading of local flockmates
@export var flock_alignment_weight: float = 0.8
##  Cohesion: steer to move toward the average position of local flockmates
@export var flock_cohesion_weight: float = 0.6
@export var flock_same_squad_only: bool = true
@export_group("Local Modifiers/Shearing")
@export var enable_shearing: bool = true
@export var shear_expected_speed_threshold: float = 40.0
@export_range(0.0, 1.0) var shear_actual_ratio_threshold: float = 0.2
@export var shear_stage1_delay_sec: float = 0.3
@export var shear_stage2_delay_sec: float = 0.75
@export var shear_angle_min_rad: float = PI / 16.0
@export var shear_angle_max_rad: float = PI / 10.0
@export var shear_bias_strength: float = 0.75
@export var debug_print: bool = false

var _intent: LocomotionIntent
var _last_goal: Vector2 = Vector2.INF
var _since_repath: float = 9999.0
var _target_set_this_frame: bool = false
# Avoidance bookkeeping (so we only apply safe velocity for the current physics frame)
var _avoidance_request_frame: int = -1
var _avoidance_requested_scale: float = 0.0
var _avoidance_applied_this_frame: bool = false
var _last_body_position: Vector2 = Vector2.INF
var _last_actual_velocity: Vector2 = Vector2.ZERO
var _last_commanded_dir: Vector2 = Vector2.ZERO
var _last_commanded_scale: float = 0.0
var _stuck_timer: float = 0.0
var _last_delta: float = 0.0
var _body: CombatantBase

@onready var _agent: NavigationAgent2D = get_node_or_null(nav_agent_path) as NavigationAgent2D
@onready var _flock_detector: FlockDetector = get_node_or_null(flock_detector_path) as FlockDetector


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

    _last_delta = delta
    _update_motion_state(delta)
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


func set_body(body: CombatantBase) -> void:
    _body = body


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


func get_body() -> CombatantBase:
    return _body


func get_recent_velocity() -> Vector2:
    return _last_actual_velocity


func get_last_commanded_dir() -> Vector2:
    return _last_commanded_dir


func is_navigation_finished() -> bool:
    return _agent == null or _agent.is_navigation_finished()


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


func _apply_local_movement_modifiers(dir: Vector2, v_scale: float) -> void:
    var base_dir := dir.normalized() if dir.length() > 0.001 else Vector2.ZERO
    var base_scale := clampf(v_scale, 0.0, 1.0)
    var base_velocity := base_dir * base_scale

    var new_dir := base_dir
    var new_scale := base_scale
    if debug_print:
        print("[%s] ORIG: (dir:%s, deg:%.1f, s:%s)" % [self, new_dir, _dir_deg(new_dir), new_scale])

    if enable_flocking:
        var steer := _compute_flock_adjustment()
        var flock_velocity := base_velocity + steer
        var flock_speed := flock_velocity.length()
        var flock_scale := clampf(flock_speed, 0.0, 1.0)

        if flock_speed > 0.001:
            new_dir = flock_velocity / flock_speed
            new_scale = flock_scale
        else:
            new_dir = base_dir
            new_scale = base_scale

        if debug_print:
            print(
                "[%s] FLOCKING dir:%s deg:%.1f (scale:%s, steer:%s, base_vel:%s)"
                % [self, new_dir, _dir_deg(new_dir), new_scale, steer, base_velocity],
            )

    if enable_shearing:
        var shear_stage := _get_shear_stage()
        if shear_stage > 0 and new_dir.length() > 0.001:
            var angle_min: float = min(shear_angle_min_rad, shear_angle_max_rad)
            var angle_max: float = max(shear_angle_min_rad, shear_angle_max_rad)
            var shear_angle := randf_range(angle_min, angle_max)
            var working_dir := new_dir
            if shear_stage == 2:
                working_dir = -working_dir # stage2: flip 180° then shear
            var rotated := working_dir.rotated(-shear_angle) # clockwise bias
            new_dir += rotated * shear_bias_strength
            if debug_print:
                print(
                    "[%s] SHEARING stage:%s dir:%s deg:%.1f (rotated: %s deg:%.1f, str: %s)" % [
                        self,
                        shear_stage,
                        new_dir,
                        _dir_deg(new_dir),
                        rotated,
                        _dir_deg(rotated),
                        shear_bias_strength,
                    ],
                )

    if new_dir.length() > 0.001:
        new_dir = new_dir.normalized()
    else:
        new_dir = Vector2.ZERO

    _last_commanded_dir = new_dir
    _last_commanded_scale = new_scale

    _body.set_desired_move(new_dir, new_scale)


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
    _configure_flock_detector()


func _stop_if_no_intent() -> void:
    if stop_when_no_intent and _intent == null:
        _body.set_desired_move(Vector2.ZERO, 0.0)
        _last_commanded_dir = Vector2.ZERO
        _last_commanded_scale = 0.0
        _stuck_timer = 0.0

        # Prevent “residual” avoidance motion.
    if use_avoidance and _agent != null and _agent.avoidance_enabled:
        _agent.set_velocity(Vector2.ZERO)


func _configure_flock_detector() -> void:
    if _flock_detector == null:
        return
    _flock_detector.set_flock_radius(flock_radius)


func _update_motion_state(delta: float) -> void:
    if not _last_body_position.is_finite():
        _last_body_position = _body.global_position
        _last_actual_velocity = Vector2.ZERO
        _stuck_timer = 0.0
        return

    var displacement := _body.global_position - _last_body_position
    _last_actual_velocity = displacement / max(delta, 0.0001)
    _last_body_position = _body.global_position

    var expected_speed := _body.move_speed * _last_commanded_scale
    var actual_speed := _last_actual_velocity.length()

    var has_command := _last_commanded_dir.length() > 0.01 and _last_commanded_scale > 0.01
    var speed_gap := expected_speed * shear_actual_ratio_threshold
    var is_slow := actual_speed <= speed_gap
    var is_expectation_high := expected_speed >= shear_expected_speed_threshold

    if has_command and is_expectation_high and is_slow:
        _stuck_timer += delta
    else:
        _stuck_timer = 0.0


# Based off of https://www.red3d.com/cwr/boids/
func _compute_flock_adjustment() -> Vector2:
    if _flock_detector == null:
        return Vector2.ZERO

    var neighbors := _flock_detector.get_candidates()
    if neighbors.is_empty():
        return Vector2.ZERO

    var separation := Vector2.ZERO
    var alignment := Vector2.ZERO
    var cohesion := Vector2.ZERO
    var count := 0

    for c in neighbors:
        var driver := c as NavIntentLocomotionDriver
        if driver == null or driver == self or not is_instance_valid(driver):
            continue
        var other_body := driver.get_body()
        if other_body == null or not is_instance_valid(other_body):
            continue
        if flock_same_squad_only and not _is_same_squad(other_body):
            continue

        count += 1
        var to_other := _body.global_position - other_body.global_position
        var dist := to_other.length()
        if dist > 0.001:
            separation += to_other / (dist * dist)

        var other_vel := driver.get_recent_velocity()
        if other_vel.length() > 0.001:
            alignment += other_vel.normalized()

        cohesion += other_body.global_position

    if count <= 0:
        return Vector2.ZERO

    var steer := Vector2.ZERO

    if separation.length() > 0.001:
        steer += separation * flock_separation_weight

    if alignment.length() > 0.001:
        steer += (alignment / float(count)) * flock_alignment_weight

    var center := (cohesion / float(count)) - _body.global_position
    if center.length() > 0.001:
        steer += center * flock_cohesion_weight

    # Soft clamp so steering can't explode; we still allow magnitude influence.
    var steer_len := steer.length()
    if steer_len > 1.0:
        steer = steer / steer_len
    return steer


func _dir_deg(vec: Vector2) -> float:
    if vec.length() <= 0.001:
        return 0.0
    return rad_to_deg(vec.angle())


func _is_same_squad(other_body: CombatantBase) -> bool:
    if _body == null or other_body == null:
        return false
    if _body.squad_link == null or other_body.squad_link == null:
        return false
    return _body.squad_link.get_squad_id() == other_body.squad_link.get_squad_id()


func _get_shear_stage() -> int:
    if _last_commanded_dir.length() <= 0.001 or _last_commanded_scale <= 0.01:
        return 0
    if _stuck_timer < shear_stage1_delay_sec:
        return 0
    if _stuck_timer < shear_stage2_delay_sec:
        return 1
    return 2
