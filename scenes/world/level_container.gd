class_name LevelContainer
extends Node2D

@onready var combatants_container: Node = $CombatantSystem/CombatantsContainer
@onready var turret_system: TurretSystem = $TurretSystem
@onready var projectile_system: ProjectileSystem = $ProjectileSystem
@onready var combatant_system: CombatantSystem = $CombatantSystem
@onready var map_slot: Node2D = $MapSlot
@onready var camera_rig: Node2D = $CameraRig

@export var map_name_to_load = ""

var run_state: RunState

# Simple registry; later you can replace this with Resources / data-driven tables.
var maps := {
    "map01": preload("res://scenes/world/maps/map1.tscn"),
}

var map_content: Node2D

func prepare_map(map_name: String) -> void:
    assert(map_name != "")
    var map_content_scene = maps.get(map_name)

    assert(map_content_scene != null)
    map_content = map_content_scene.instantiate() as Node2D

func bind_run_state(state: RunState) -> void:
    run_state = state

func _ready() -> void:
    _reset_run_state()
    _initialize_map()
    _inject_dependencies()

func _exit_tree() -> void:
    # Optional hygiene
    if get_tree().node_added.is_connected(_on_node_added):
        get_tree().node_added.disconnect(_on_node_added)

func _on_node_added(node: Node) -> void:
    # Filter to avoid injecting into unrelated scenes elsewhere in the tree.
    if not is_ancestor_of(node):
        return

    if node.is_in_group(Groups.RUN_STATE_CONSUMERS):
        # Defer to avoid “timing” surprises during enter-tree.
        node.call_deferred("bind_run_state", run_state)

    if node.is_in_group(Groups.COMBATANT_SYSTEM_CONSUMERS):
        node.call_deferred("bind_combatant_system", combatant_system)

func _inject_dependencies():
    # Wire anything already in the tree
    get_tree().call_group(Groups.RUN_STATE_CONSUMERS, "bind_run_state", run_state)
    get_tree().call_group(Groups.COMBATANT_SYSTEM_CONSUMERS, "bind_combatant_system", combatant_system)
    # Wire anything that shows up later (ie, scene tiles)
    get_tree().node_added.connect(_on_node_added)

func _reset_run_state() -> void:
    var rng = RandomNumberGenerator.new()
    rng.randomize()
    var run_seed = rng.get_seed()
    var run_id = Uuid.v4()

    run_state.reset_for_new_run(run_id, run_seed)

func _initialize_map() -> void:
    # Instantiate the per-map content under MapSlot
    assert(map_content != null)
    map_slot.add_child(map_content)

    var spawn_system: SpawnSystem = map_slot.get_child(0).get_node("SpawnSystem")
    spawn_system.combatant_spawn_requested.connect(combatant_system.spawn)

    var spawn_pos := global_position
    # Prefer the "MapContent" API if present.
    if map_content is MapBase:
        var marker := (map_content as MapBase).get_player_spawn()
        if marker:
            spawn_pos = marker.global_position

    var player = await _spawn_player(spawn_pos)
    camera_rig.set_target(player)


func _spawn_player(spawn_pos: Vector2) -> Player:
    print("Attempting to spawn player at %s" % spawn_pos)
    var ctx = CombatantSpawnContext.new(spawn_pos, CombatantTypes.PLAYER)
    var player := await combatant_system.spawn(ctx) as Player

    var placer := player.get_node("AttachmentsRig/%ComponentsRoot/TurretPlacerComponent")
    placer.place_turret_requested.connect(
        func(pos, scene): turret_system.try_build_turret(player, pos, scene)
    )

    return player
