class_name Squad
extends RefCounted

const GOLDEN_ANGLE: float = PI * (3.0 - sqrt(5.0))

var squad_id: int
var team_id: int = 0
var desired_count: int = 0
var members: Array[Node2D] = []
# "Squad anchor" state (pure data; no Node required)
var anchor_position: Vector2 = Vector2.ZERO
# Movement/path config for the anchor
var nav_layers: int = Layers.NAV_WALK
var anchor_speed: float = 140.0
var anchor_arrival_radius: float = 10.0
var path_optimize: bool = true
# Cohesion/slot config (radius varies by directive)
var cohesion_radius_idle: float = 72.0
var cohesion_radius_move: float = 36.0
var cohesion_radius_patrol: float = 48.0
# Internal navigation state
var _directive: SquadDirective
var _path: PackedVector2Array = PackedVector2Array()
var _path_index: int = 0
var _patrol_index: int = 0
# Slotting
var _slot_offsets: PackedVector2Array = PackedVector2Array()
var _slot_assignment: Dictionary = { } # instance_id(int) -> slot_index(int)
var _slots_dirty: bool = true


func _init(id: int, team: int, anchor_pos: Vector2, desired: int) -> void:
    squad_id = id
    team_id = team
    anchor_position = anchor_pos
    desired_count = desired
    _directive = SquadDirective.hold(anchor_pos)


func get_directive() -> SquadDirective:
    return _directive


func set_directive(d: SquadDirective) -> void:
    _directive = d
    _path = PackedVector2Array()
    _path_index = 0
    _slots_dirty = true


func add_member(m: Node2D) -> void:
    if m == null or not is_instance_valid(m):
        return
    if members.has(m):
        return
    members.append(m)
    _slots_dirty = true


func remove_member(m: Node2D) -> void:
    members.erase(m)
    var id: int = m.get_instance_id() if m != null else 0
    if id in _slot_assignment:
        _slot_assignment.erase(id)
    _slots_dirty = true


func prune_invalid_members() -> void:
    for i in range(members.size() - 1, -1, -1):
        if not is_instance_valid(members[i]):
            members.remove_at(i)
            _slots_dirty = true


func tick(delta: float, nav_map: RID) -> void:
    prune_invalid_members()

    # Some projects prefer to keep desired_count fixed; others track it dynamically.
    if desired_count <= 0:
        desired_count = max(1, members.size())

    _tick_anchor(delta, nav_map)

    # Rebuild offsets if needed.
    if _slots_dirty:
        _rebuild_slot_offsets()
        _slots_dirty = false


func get_current_cohesion_radius() -> float:
    match _directive.kind:
        SquadDirective.Kind.HOLD:
            return cohesion_radius_idle
        SquadDirective.Kind.MOVE_TO:
            return cohesion_radius_move
        SquadDirective.Kind.PATROL:
            return cohesion_radius_patrol
    return cohesion_radius_idle


func get_slot_target_for(member: Node2D) -> Vector2:
    if member == null or not is_instance_valid(member):
        return anchor_position
    var id: int = member.get_instance_id()
    var idx: int = 0
    if id in _slot_assignment:
        idx = int(_slot_assignment[id])
    idx = clampi(idx, 0, max(0, _slot_offsets.size() - 1))
    return anchor_position + _slot_offsets[idx]


func get_debug_path() -> PackedVector2Array:
    return _path


func get_debug_slot_offsets() -> PackedVector2Array:
    return _slot_offsets


func _tick_anchor(delta: float, nav_map: RID) -> void:
    match _directive.kind:
        SquadDirective.Kind.HOLD:
            # Anchor stays put.
            return
        SquadDirective.Kind.MOVE_TO:
            _move_anchor_toward(delta, nav_map, _directive.target_position)
        SquadDirective.Kind.PATROL:
            if _directive.patrol_points.size() == 0:
                return
            # Acquire current patrol waypoint.
            var wp: Vector2 = _directive.patrol_points[_patrol_index]
            var reached: bool = _move_anchor_toward(delta, nav_map, wp)
            if reached:
                _patrol_index += 1
                if _patrol_index >= _directive.patrol_points.size():
                    _patrol_index = 0 if _directive.patrol_loop else (_directive.patrol_points.size() - 1)


## Returns if path was completed.
func _move_anchor_toward(delta: float, nav_map: RID, destination: Vector2) -> bool:
    # Ensure we have a path.
    if _path.size() == 0:
        _recompute_path(nav_map, destination)

    # If path still empty (nav not ready, or unreachable), fallback to straight-line.
    if _path.size() == 0:
        return _move_anchor_direct(delta, destination)

    # Advance along path points.
    while _path_index < _path.size():
        var next_pt: Vector2 = _path[_path_index]
        var to_next: Vector2 = next_pt - anchor_position
        var dist: float = to_next.length()

        if dist <= anchor_arrival_radius:
            _path_index += 1
            continue

        var step: float = anchor_speed * delta
        if step >= dist:
            anchor_position = next_pt
            _path_index += 1
        else:
            anchor_position += to_next / dist * step

        break

    # Path completed?
    if _path_index >= _path.size():
        _path = PackedVector2Array()
        _path_index = 0
        return (anchor_position.distance_to(destination) <= anchor_arrival_radius)

    return false


func _move_anchor_direct(delta: float, destination: Vector2) -> bool:
    var to_dest: Vector2 = destination - anchor_position
    var dist: float = to_dest.length()
    if dist <= anchor_arrival_radius:
        return true
    var step: float = anchor_speed * delta
    anchor_position += to_dest / dist * min(step, dist)
    return (anchor_position.distance_to(destination) <= anchor_arrival_radius)


func _recompute_path(nav_map: RID, destination: Vector2) -> void:
    # Query path directly from NavigationServer2D.
    _path = NavigationServer2D.map_get_path(nav_map, anchor_position, destination, path_optimize, nav_layers)
    _path_index = 0

    # Many nav paths include the origin as the first point; skip it if it's basically anchor_position.
    if _path.size() > 0 and _path[0].distance_to(anchor_position) <= 1.0:
        _path_index = 1


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

    _slot_offsets = offsets

    # Keep existing assignments where possible; assign new members deterministically.
    _assign_slots_stably()


func _assign_slots_stably() -> void:
    # Clear assignments for invalid members.
    var valid_ids: Dictionary = { }
    for m in members:
        if is_instance_valid(m):
            valid_ids[m.get_instance_id()] = true

    for k in _slot_assignment.keys():
        if not (k in valid_ids):
            _slot_assignment.erase(k)

    # Assign any unassigned member to the first available slot.
    var used: Dictionary = { }
    for sid in _slot_assignment.keys():
        used[_slot_assignment[sid]] = true

    var next_slot: int = 0
    for m in members:
        if not is_instance_valid(m):
            continue
        var id: int = m.get_instance_id()
        if id in _slot_assignment:
            continue
        while next_slot in used and next_slot < _slot_offsets.size():
            next_slot += 1
        if next_slot >= _slot_offsets.size():
            next_slot = _slot_offsets.size() - 1
        _slot_assignment[id] = next_slot
        used[next_slot] = true
