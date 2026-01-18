class_name SquadSystem
extends Node2D

signal squad_created(squad_id: int)
signal squad_disbanded(squad_id: int)
signal squad_slot_targets_updated(squad_id: int, targets: Dictionary) # Node2D -> Vector2

@export var default_squad_config: SquadConfig
@export var auto_assign_member_targets: bool = false
@export var project_targets_to_navmesh: bool = true
@export var squad_move_tries: int = 12
@export var squad_move_radius: float = 1000.0
@export var squad_path_radius_mod_min: float = 0.5

var _nav_map: RID
var _next_squad_id: int = 1
var _squads: Dictionary = { } # int -> Squad

@onready var directive_randomization_timer: Timer = $SquadDirectiveRandTimer


func _ready() -> void:
    # Default navigation map RID comes from World2D.
    _nav_map = get_world_2d().get_navigation_map()

    directive_randomization_timer.timeout.connect(_on_directive_rand_timer_timeout)

    (get_node("/root/Debug") as DebugService).request_force_move_squad.connect(_on_force_move_squad)


func _process(_delta: float) -> void:
    for squad_id in _squads.keys():
        var squad: Squad = _squads.get(squad_id)
        if squad.is_empty():
            disband_squad(squad_id)


func _physics_process(delta: float) -> void:
    # If the map has never synchronized, queries can be empty. Iteration id 0 indicates “never synced”.
    var map_ready := NavigationServer2D.map_get_iteration_id(_nav_map) > 0

    for squad_id in _squads.keys():
        var s: Squad = _squads.get(squad_id)
        s.tick(delta, _nav_map)

        var targets := _compute_slot_targets(s, map_ready)
        squad_slot_targets_updated.emit(s.squad_id, targets)

        if auto_assign_member_targets:
            _apply_targets_to_members(targets)


func create_squad(team_id: int, anchor_position: Vector2, desired_count: int) -> int:
    var id := _next_squad_id
    _next_squad_id += 1

    var s := Squad.new(default_squad_config, id, team_id, anchor_position, desired_count)
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
    print("Setting squad (%s) hold at %s" % [squad_id, at])
    var s := get_squad(squad_id)
    if s == null:
        return
    s.set_directive(SquadDirective.hold(at))


func set_squad_move_to(squad_id: int, destination: Vector2) -> void:
    print("Setting squad (%s) move to %s" % [squad_id, destination])
    var s := get_squad(squad_id)
    if s == null:
        return
    s.set_directive(SquadDirective.move_to(destination))


func set_squad_patrol(squad_id: int, points: PackedVector2Array, loop: bool = true) -> void:
    print("Setting squad (%s) patrol along %s (Loop: %s)" % [squad_id, points, loop])
    var s := get_squad(squad_id)
    if s == null:
        return
    s.set_directive(SquadDirective.patrol(points, loop))


func _on_force_move_squad(squad_id: int, target_pos: Vector2) -> void:
    print("FORCE SQUAD (%s) TO MOVE %s" % [squad_id, target_pos])
    set_squad_move_to(squad_id, target_pos)


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
        var pos: Vector2 = targets.get(m)
        if not is_instance_valid(m):
            continue

        if m.has_method("set_squad_slot_target"):
            m.call("set_squad_slot_target", pos)
        elif "squad_slot_target" in m:
            m.set("squad_slot_target", pos)


func _on_directive_rand_timer_timeout() -> void:
    print("Changing directive")
    for squad_id in _squads.keys():
        var squad: Squad = get_squad(squad_id)
        var member: Node2D = squad.get_any_member()
        var nav_rid := member.get_world_2d().get_navigation_map()

        # TODO: Tweaked
        var rand := RandomNumberGenerator.new().randi_range(2, 3)
        match rand:
            1:
                set_squad_hold(squad_id, NavUtils.get_some_random_reachable_point(nav_rid, squad.rt.anchor_position))
            2:
                set_squad_move_to(
                    squad_id,
                    NavUtils.get_some_random_reachable_point(
                        nav_rid,
                        squad.rt.anchor_position,
                        squad_move_tries,
                        squad_move_radius,
                    ),
                )
            3:
                set_squad_patrol(
                    squad_id,
                    NavUtils.get_some_random_path(
                        nav_rid,
                        squad.rt.anchor_position,
                        squad_move_tries,
                        squad_move_radius,
                        squad_path_radius_mod_min,
                    ),
                    true,
                )
            _:
                pass
