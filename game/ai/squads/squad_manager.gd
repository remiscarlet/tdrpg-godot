class_name SquadManager
extends Node2D

signal squad_created(squad_id: int)
signal squad_disbanded(squad_id: int)
signal squad_slot_targets_updated(squad_id: int, targets: Dictionary) # Node2D -> Vector2

@export var auto_assign_member_targets: bool = false
@export var project_targets_to_navmesh: bool = true
@export var nav_layers_default: int = 1

var _nav_map: RID
var _next_squad_id: int = 1
var _squads: Dictionary = { } # int -> Squad


func _ready() -> void:
    # Default navigation map RID comes from World2D.
    _nav_map = get_world_2d().get_navigation_map()


func _physics_process(delta: float) -> void:
    # If the map has never synchronized, queries can be empty. Iteration id 0 indicates “never synced”.
    var map_ready := NavigationServer2D.map_get_iteration_id(_nav_map) > 0

    for squad_id in _squads.keys():
        var s: Squad = _squads[squad_id]
        s.nav_layers = nav_layers_default
        s.tick(delta, _nav_map)

        var targets := _compute_slot_targets(s, map_ready)
        squad_slot_targets_updated.emit(s.squad_id, targets)

        if auto_assign_member_targets:
            _apply_targets_to_members(targets)


func create_squad(team_id: int, anchor_position: Vector2, desired_count: int) -> int:
    var id := _next_squad_id
    _next_squad_id += 1

    var s := Squad.new(id, team_id, anchor_position, desired_count)
    _squads[id] = s
    squad_created.emit(id)
    return id


func disband_squad(squad_id: int) -> void:
    if not _squads.has(squad_id):
        return
    _squads.erase(squad_id)
    squad_disbanded.emit(squad_id)


func get_squad(squad_id: int) -> Squad:
    return _squads.get(squad_id, null)


func get_all_squads() -> Array[Squad]:
    var out: Array[Squad] = []
    for k in _squads.keys():
        out.append(_squads[k])
    return out


func add_member_to_squad(squad_id: int, member: Node2D) -> void:
    var s := get_squad(squad_id)
    if s == null:
        return
    s.add_member(member)


func remove_member_from_squad(squad_id: int, member: Node2D) -> void:
    var s := get_squad(squad_id)
    if s == null:
        return
    s.remove_member(member)


func set_squad_hold(squad_id: int, at: Vector2) -> void:
    var s := get_squad(squad_id)
    if s == null:
        return
    s.set_directive(SquadDirective.hold(at))


func set_squad_move_to(squad_id: int, destination: Vector2) -> void:
    var s := get_squad(squad_id)
    if s == null:
        return
    s.set_directive(SquadDirective.move_to(destination))


func set_squad_patrol(squad_id: int, points: PackedVector2Array, loop: bool = true) -> void:
    var s := get_squad(squad_id)
    if s == null:
        return
    s.set_directive(SquadDirective.patrol(points, loop))


func _compute_slot_targets(s: Squad, map_ready: bool) -> Dictionary:
    var targets: Dictionary = { } # Node2D -> Vector2
    for m in s.members:
        if not is_instance_valid(m):
            continue
        var desired := s.get_slot_target_for(m)
        if project_targets_to_navmesh and map_ready:
            # Snaps target to nearest nav surface point.
            desired = NavigationServer2D.map_get_closest_point(_nav_map, desired)
        targets[m] = desired
    return targets


func _apply_targets_to_members(targets: Dictionary) -> void:
    # Optional convenience for early prototypes.
    # Your actual member controller can consume these however you like.
    for m in targets.keys():
        var pos: Vector2 = targets[m]
        if not is_instance_valid(m):
            continue

        if m.has_method("set_squad_slot_target"):
            m.call("set_squad_slot_target", pos)
        elif "squad_slot_target" in m:
            m.set("squad_slot_target", pos)
