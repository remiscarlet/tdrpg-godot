extends Node

@onready var run_hud: RunHUD = %RunHUD
@onready var level_system: LevelSystem = %LevelSystem

var meta_state: MetaState = MetaState.new()
var run_state: RunState

func get_meta_state() -> MetaState:
    return meta_state

func get_run_state() -> RunState:
    return run_state

func _ready() -> void:
    start_run()

func start_run() -> void:
    run_state = RunState.new()
    run_hud.bind_run_state(run_state)
    level_system.bind_run_state(run_state)

    level_system.start_session()
