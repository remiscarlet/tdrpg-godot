extends Node

## Purpose: Bootstraps the run, HUD, and level systems.
var meta_state: MetaState = MetaState.new()
var run_state: RunState

@onready var run_hud: RunHUD = %RunHUD
@onready var level_system: LevelSystem = %LevelSystem
@onready var minimap: Minimap = run_hud.get_node("%Minimap")


func _ready() -> void:
    start_run()


func get_meta_state() -> MetaState:
    return meta_state


func get_run_state() -> RunState:
    return run_state


func start_run() -> void:
    run_state = RunState.new()
    run_hud.bind_run_state(run_state)
    level_system.bind_run_state(run_state)

    var container: LevelContainer = level_system.start_session()
    var nav_root: Node = container.get_active_map().get_nav_root()
    var tilemap_layer: TileMapLayer = container.get_active_map().get_nav_tilemap_layer()
    minimap.bind_nav_root(nav_root)
    minimap.bind_player_root(container.get_player())
    minimap.bind_tilemap_layer(tilemap_layer)
