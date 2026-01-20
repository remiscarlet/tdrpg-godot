class_name Squad
extends RefCounted

const GOLDEN_ANGLE: float = PI * (3.0 - sqrt(5.0))
const DIRECTIVE_CHANGED := &"directive_changed"

var squad_id: int
var team_id: int = 0
var desired_count: int = 0
var members: Array[CombatantBase] = []
var cfg: SquadConfig
var fsm: FiniteStateMachine
var rt := SquadRuntime.new()


func _init(config: SquadConfig, id: int, team: int, anchor_pos: Vector2, desired: int) -> void:
    cfg = config

    squad_id = id
    team_id = team
    desired_count = desired

    rt.set_anchor_position(anchor_pos)
    rt.set_directive(SquadDirective.hold(anchor_pos))

    _rebuild_slot_offsets()


func get_directive() -> SquadDirective:
    return rt.directive


func set_directive(d: SquadDirective) -> void:
    rt.set_directive(d)
    rt.path = PackedVector2Array()
    rt.path_index = 0
    rt.slots_dirty = true

    # Optional: nudge FSM immediately (otherwise the next physics_step will route)
    if fsm != null:
        fsm.emit_event(DIRECTIVE_CHANGED, d)


func get_any_member() -> CombatantBase:
    if members.size() <= 0:
        return null
    return members[0]


func add_member(m: CombatantBase) -> void:
    if m == null or not is_instance_valid(m):
        return
    if members.has(m):
        return
    members.append(m)
    rt.slots_dirty = true


func remove_member(m: CombatantBase) -> void:
    members.erase(m)
    var id: int = m.get_instance_id() if m != null else 0
    if id in rt.slot_assignment:
        rt.slot_assignment.erase(id)
    rt.slots_dirty = true


func is_empty() -> bool:
    return members.size() == 0


func prune_invalid_members() -> void:
    for i in range(members.size() - 1, -1, -1):
        if not is_instance_valid(members[i]):
            members.remove_at(i)
            rt.slots_dirty = true


func tick(delta: float, nav_map: RID) -> void:
    prune_invalid_members()

    if desired_count <= 0:
        desired_count = max(1, members.size())

    # FSM drives anchor/directive mechanics.
    _ensure_fsm()
    fsm.set_ctx_value(SquadFSMKeys.NAV_MAP, nav_map)
    fsm.physics_step(delta)

    if rt.slots_dirty:
        _rebuild_slot_offsets()
        rt.slots_dirty = false


func get_current_cohesion_radius() -> float:
    match rt.directive.kind:
        SquadDirective.Kind.HOLD:
            return cfg.cohesion_radius_idle
        SquadDirective.Kind.MOVE_TO:
            return cfg.cohesion_radius_move
        SquadDirective.Kind.PATROL:
            return cfg.cohesion_radius_patrol
    return cfg.cohesion_radius_idle


func has_slot_target_for(member: CombatantBase) -> bool:
    if member == null or not is_instance_valid(member):
        return false

    var id: int = member.get_instance_id()
    return id in rt.slot_assignment


func get_slot_target_for(member: CombatantBase) -> Vector2:
    if not has_slot_target_for(member):
        return rt.anchor_position

    var id: int = member.get_instance_id()
    var idx: int = int(rt.slot_assignment[id])
    idx = clampi(idx, 0, max(0, rt.slot_offsets.size() - 1))

    return rt.anchor_position + rt.slot_offsets[idx]


func get_debug_path() -> PackedVector2Array:
    return rt.path


func get_debug_slot_offsets() -> PackedVector2Array:
    return rt.slot_offsets


## Returns if path was completed.
func move_anchor_toward(delta: float, nav_map: RID, destination: Vector2) -> bool:
    # Ensure we have a path.
    if rt.path.size() == 0:
        _recompute_path(nav_map, destination)

    # If path still empty (nav not ready, or unreachable), fallback to straight-line.
    if rt.path.size() == 0:
        return _move_anchor_direct(delta, destination)

    # Advance along path points.
    while rt.path_index < rt.path.size():
        var next_pt: Vector2 = rt.path[rt.path_index]
        var to_next: Vector2 = next_pt - rt.anchor_position
        var dist: float = to_next.length()

        if dist <= cfg.anchor_arrival_radius:
            rt.path_index += 1
            continue

        var step: float = cfg.anchor_speed * delta
        if step >= dist:
            rt.path_index += 1
        else:
            next_pt = rt.anchor_position + (to_next / dist * step)

        rt.set_anchor_position(next_pt)

        break

    # Path completed?
    if rt.path_index >= rt.path.size():
        rt.path = PackedVector2Array()
        rt.path_index = 0
        return (rt.anchor_position.distance_to(destination) <= cfg.anchor_arrival_radius)

    return false


func _move_anchor_direct(delta: float, destination: Vector2) -> bool:
    var to_dest: Vector2 = destination - rt.anchor_position
    var dist: float = to_dest.length()
    if dist <= cfg.anchor_arrival_radius:
        return true
    var step: float = cfg.anchor_speed * delta
    rt.anchor_position += to_dest / dist * min(step, dist)
    return (rt.anchor_position.distance_to(destination) <= cfg.anchor_arrival_radius)


func _recompute_path(nav_map: RID, destination: Vector2) -> void:
    # Query path directly from NavigationServer2D.
    rt.path = NavigationServer2D.map_get_path(
        nav_map,
        rt.anchor_position,
        destination,
        cfg.path_optimize,
        cfg.nav_layers,
    )
    rt.path_index = 0

    # Many nav paths include the origin as the first point; skip it if it's basically anchor_position.
    if rt.path.size() > 0 and rt.path[0].distance_to(rt.anchor_position) <= 1.0:
        rt.path_index = 1


func _rebuild_slot_offsets() -> void:
    var slot_count: int = max(1, max(desired_count, members.size()))
    var radius: float = max(0.0, get_current_cohesion_radius())

    var offsets := PackedVector2Array()
    offsets.resize(slot_count)

    # Slot 0 at the anchor.
    offsets[0] = Vector2.ZERO

    # Vogel spiral-ish distribution for the rest.
    for i in range(1, slot_count):
        var t := float(i) / float(max(1, slot_count - 1))
        var r := sqrt(t) * radius
        var a := float(i) * GOLDEN_ANGLE
        offsets[i] = Vector2(cos(a), sin(a)) * r

    rt.slot_offsets = offsets

    # Keep existing assignments where possible; assign new members deterministically.
    _assign_slots_stably()


func _assign_slots_stably() -> void:
    # Clear assignments for invalid members.
    var valid_ids: Dictionary = { }
    for m in members:
        if is_instance_valid(m):
            valid_ids[m.get_instance_id()] = true

    for k in rt.slot_assignment.keys():
        if not (k in valid_ids):
            rt.slot_assignment.erase(k)

    # Assign any unassigned member to the first available slot.
    var used: Dictionary = { }
    for sid in rt.slot_assignment.keys():
        used[rt.slot_assignment[sid]] = true

    var next_slot: int = 0
    for m in members:
        if not is_instance_valid(m):
            continue
        var id: int = m.get_instance_id()
        if id in rt.slot_assignment:
            continue
        while next_slot in used and next_slot < rt.slot_offsets.size():
            next_slot += 1
        if next_slot >= rt.slot_offsets.size():
            next_slot = rt.slot_offsets.size() - 1
        rt.slot_assignment[id] = next_slot
        used[next_slot] = true


func _ensure_fsm() -> void:
    if fsm != null:
        return
    # Need cfg available before this. If cfg is assigned after construction,
    # call _ensure_fsm() from tick() once cfg is set.
    fsm = FiniteStateMachine.new()

    var st_hold := SquadStateHold.new()
    var st_move := SquadStateMoveTo.new()
    var st_patrol := SquadStatePatrol.new()

    var ctx := {
        SquadFSMKeys.SQUAD: self,
        SquadFSMKeys.CFG: cfg,
        SquadFSMKeys.RT: rt,
        SquadFSMKeys.FSM: fsm,
        SquadFSMKeys.NAV_MAP: RID(),
        SquadFSMKeys.ST_HOLD: st_hold,
        SquadFSMKeys.ST_MOVE: st_move,
        SquadFSMKeys.ST_PATROL: st_patrol,
    }

    fsm.init(ctx, st_hold)
