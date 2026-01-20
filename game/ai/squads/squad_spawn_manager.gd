class_name SquadSpawnManager
extends Node

## Purpose: Manages squad spawn requests and policies.
@export var squad_system_path: NodePath
@export var combatant_system: CombatantSystem
# Policy
@export var spawn_policy: SquadSpawnPolicy = MaxSquadsSpawnPolicy.new()
# Placement
@export var spawn_markers_group: StringName = Groups.ENEMY2_SPAWNS
@export var spawn_placement: SquadSpawnPlacement = MarkerGroupSpawnPlacement.new()
# Legacy policy knobs (mirrored into MaxSquadsSpawnPolicy in _ready)
@export_range(0.1, 60.0, 0.1) var spawn_interval_sec: float = 4.0
# Misc
@export var spawn_enabled: bool = true
@export var spawn_scatter_radius: float = 14.0

var _timer: Timer
var _squad_system: SquadSystem


func _ready() -> void:
    spawn_placement = MarkerGroupSpawnPlacement.new()
    _squad_system = get_node_or_null(squad_system_path) as SquadSystem

    _timer = Timer.new()
    _timer.one_shot = true
    _timer.wait_time = spawn_interval_sec
    _timer.timeout.connect(_on_timeout)
    add_child(_timer)
    _timer.start()


func _validate_ready() -> bool:
    if not spawn_enabled:
        return false
    if combatant_system == null:
        return false
    if _squad_system == null:
        return false
    if spawn_policy == null:
        return false
    if spawn_placement == null:
        return false
    if spawn_markers_group == StringNames.EMPTY:
        return false
    return true


func _on_timeout() -> void:
    # One-shot timer prevents overlapping spawns while we await CombatantSystem.
    if _validate_ready():
        await _consume_director_directives()

    # Always schedule the next tick.
    _timer.wait_time = spawn_interval_sec
    _timer.start()


func _consume_director_directives() -> void:
    var director := Director.get_instance()
    var consumed_any := false

    if director != null:
        print("SquadSpawnManager: querying director for RANDOM_SPAWN directives.")
        var directives := director.consume_directives(DirectorDirective.Goal.RANDOM_SPAWN)
        for d in directives:
            consumed_any = true
            await _try_spawn_once()

    if not consumed_any:
        print("SquadSpawnManager: no director directives available; skipping spawn.")


func _try_spawn_once() -> void:
    var now_sec := float(Time.get_ticks_msec()) / 1000.0

    var policy_ctx := SquadSpawnPolicyContext.new(self, _squad_system, now_sec)
    var req := spawn_policy.build_request(policy_ctx)
    if req == null or not req.is_valid():
        return

    var place_ctx := SquadSpawnPlacementContext.new(self, spawn_markers_group, req)
    var placement := spawn_placement.pick(place_ctx)
    if placement == null or not placement.is_valid():
        return

    await _spawn_squad(req, placement.position)


func _spawn_squad(req: SquadSpawnRequest, anchor_pos: Vector2) -> void:
    var squad_id := _squad_system.create_squad(req.team_id, anchor_pos, req.squad_size)

    # Default directive: HOLD at the anchor.
    _squad_system.set_squad_hold(squad_id, anchor_pos)

    # Spawn members and register them with the squad.
    for i in range(req.squad_size):
        var jitter := Vector2.RIGHT.rotated(randf() * TAU) * (randf() * spawn_scatter_radius)
        var ctx := CombatantSpawnContext.new(anchor_pos + jitter, req.combatant_id, squad_id)
        var combatant: CombatantBase = await combatant_system.spawn(ctx)

        if combatant != null:
            _squad_system.add_member_to_squad(squad_id, combatant)
