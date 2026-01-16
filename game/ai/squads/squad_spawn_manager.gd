class_name SquadSpawnManager
extends Node

@export var squad_manager_path: NodePath
@export var combatant_system: CombatantSystem
@export var enemy_member_scene: PackedScene
@export var spawn_markers_group: StringName = Groups.ENEMY2_SPAWNS
@export_range(0.1, 60.0, 0.1) var spawn_interval_sec: float = 4.0
@export var squad_size: int = 4
@export var team_id: int = CombatantTeam.MUTANT
@export var max_squads_alive: int = 8
@export var spawn_enabled: bool = true
@export var spawn_scatter_radius: float = 14.0

var _timer: Timer


func _ready() -> void:
    _timer = Timer.new()
    _timer.one_shot = true
    _timer.wait_time = spawn_interval_sec
    _timer.timeout.connect(_on_timeout)
    add_child(_timer)
    _timer.start()


func _on_timeout() -> void:
    if not spawn_enabled:
        return
    if enemy_member_scene == null:
        return

    var mgr := get_node_or_null(squad_manager_path) as SquadManager
    if mgr == null:
        return

    if mgr.get_all_squads().size() >= max_squads_alive:
        return

    var markers := get_tree().get_nodes_in_group(spawn_markers_group)
    if markers.is_empty():
        return

    # Pick a random Marker2D.
    var marker: Marker2D = markers.pick_random()
    if not (marker is Marker2D):
        # If the group contains other things, try to find a Marker2D.
        for n in markers:
            if n is Marker2D:
                marker = n
                break
        if not (marker is Marker2D):
            return

    var anchor_pos := (marker as Marker2D).global_position
    var squad_id := mgr.create_squad(team_id, anchor_pos, squad_size)

    # Default directive: HOLD at the anchor.
    mgr.set_squad_hold(squad_id, anchor_pos)

    # Spawn members and register them with the squad.
    for i in range(squad_size):
        var jitter := Vector2.RIGHT.rotated(randf() * TAU) * (randf() * spawn_scatter_radius)
        var ctx := CombatantSpawnContext.new(anchor_pos + jitter, CombatantTypes.DEFAULT_ENEMY)
        var combatant: CombatantBase = await combatant_system.spawn(ctx)

        mgr.add_member_to_squad(squad_id, combatant)
