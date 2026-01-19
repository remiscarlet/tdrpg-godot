class_name Director
extends Node

signal observation_processed(event: DirectorObservationEvent)

static var _instance: Director

@export var config: DirectorConfig

var _state := DirectorState.new()
var _observation_queue: Array[DirectorObservationEvent] = []
var _next_directive_id: int = 1
var _tick_accumulator: float = 0.0
var _rng := RandomNumberGenerator.new()


static func get_instance() -> Director:
    return _instance


static func emit_observation(evt: DirectorObservationEvent) -> bool:
    var inst := get_instance()
    if inst == null or not is_instance_valid(inst):
        return false
    return inst.enqueue_observation(evt)


func _ready() -> void:
    _instance = self
    if config == null:
        config = DirectorConfig.new()
    _state.reset(config)
    set_physics_process(config.enabled)
    _rng.randomize()


func _physics_process(delta: float) -> void:
    if config == null or not config.enabled:
        return

    _tick_accumulator += delta
    if _tick_accumulator < config.tick_interval_sec:
        return
    _tick_accumulator = 0.0

    _process_tick(delta)


func _exit_tree() -> void:
    if _instance == self:
        _instance = null


func enqueue_observation(evt: DirectorObservationEvent) -> bool:
    if evt == null:
        return false
    if _observation_queue.size() >= config.max_observation_queue:
        return false
    _observation_queue.append(DirectorObservationEvent.copy_from(evt))
    return true


func get_heat_map_snapshot() -> Dictionary:
    return _state.heat_map.get_all_cells()


func get_belief_map_snapshot() -> Dictionary:
    return _state.belief_map.get_all_cells()


func create_directive(goal: DirectorDirective.Goal, target: Vector2, priority: float = 1.0, ttl_ms: int = 0) -> DirectorDirective:
    var d := DirectorDirective.create(_next_directive_id, goal, target, priority, ttl_ms)
    _next_directive_id += 1
    return d


func consume_directives(goal: DirectorDirective.Goal) -> Array[DirectorDirective]:
    var taken: Array[DirectorDirective] = []
    for d in _state.directives:
        if d.goal == goal:
            taken.append(d)
    if taken.size() == 0:
        return taken

    # Remove consumed directives.
    _state.directives = _state.directives.filter(
        func(item):
            return item.goal != goal
    )
    return taken


func _process_tick(delta: float) -> void:
    _drain_observations()
    _state.heat_map.decay(delta)
    _state.belief_map.diffuse_and_decay(delta)
    _maybe_issue_placeholder_directive(delta)


func _drain_observations() -> void:
    if _observation_queue.is_empty():
        return
    for evt in _observation_queue:
        _apply_observation(evt)
        observation_processed.emit(evt)
    _observation_queue.clear()


func _apply_observation(evt: DirectorObservationEvent) -> void:
    print("APPLYING OBSERVATION: %s" % evt)
    match evt.kind:
        DirectorObservationEvent.Kind.PLAYER_SIGHTING, DirectorObservationEvent.Kind.PLAYER_ATTACK, DirectorObservationEvent.Kind.STRUCTURE_DAMAGE:
            _state.heat_map.add_heat(evt.position, evt.intensity if evt.intensity > 0.0 else config.heat_write_default)
            _state.belief_map.add_belief(evt.position, evt.intensity if evt.intensity > 0.0 else 1.0)
        DirectorObservationEvent.Kind.SQUAD_STATUS, DirectorObservationEvent.Kind.COMBATANT_STATUS:
            # For now, also feed heat; later can branch to other maps.
            _state.heat_map.add_heat(evt.position, evt.intensity if evt.intensity > 0.0 else config.heat_write_default)
        _:
            if not config.drop_unknown_events:
                _state.heat_map.add_heat(evt.position, evt.intensity if evt.intensity > 0.0 else config.heat_write_default)


func _maybe_issue_placeholder_directive(delta: float) -> void:
    if not config.enable_directives:
        return

    _state.directive_timer_accum += delta
    if _state.directive_timer_accum < config.placeholder_directive_interval_sec:
        return
    _state.directive_timer_accum = 0.0

    var dir := create_directive(
        DirectorDirective.Goal.RANDOM_SPAWN,
        _random_target_position(),
        1.0,
        int(config.placeholder_directive_interval_sec * 1000.0),
    )
    _state.directives.append(dir)
    print("Director placeholder directive issued: RANDOM_SPAWN -> %s" % dir.target_position)


func _random_target_position() -> Vector2:
    var angle := _rng.randf_range(0.0, TAU)
    var radius := _rng.randf_range(config.placeholder_directive_radius * 0.3, config.placeholder_directive_radius)
    return Vector2.RIGHT.rotated(angle) * radius
