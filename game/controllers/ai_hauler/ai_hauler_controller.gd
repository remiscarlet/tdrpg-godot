extends Node2D
class_name AIHaulerController

var hauler_task_system: HaulerTaskSystem

var _rng := RandomNumberGenerator.new()

@export var wander_radius := 400.0
@export var wander_tries := 12
@export_flags_2d_navigation var navigation_layers := 1 # must match region layers you want to use

@onready var body: CombatantBase = get_parent().get_parent().get_parent() # CombatantBase/AttachmentsRoot/Controllers
@onready var agent: NavigationAgent2D = $NavigationAgent2D
@onready var timer: Timer = $WanderTimer

enum HaulerState {
    IDLE,
    GO_TO_LOOT,
    GO_TO_COLLECTOR,
}

var current_task: HaulTask
var state = HaulerState.IDLE

func set_hauler_task_system(system: HaulerTaskSystem) -> void:
    print("Setting hauler to %s (%s)" % [system, get_instance_id()])
    hauler_task_system = system

func _ready() -> void:
    print("AIHauler: _ready")
    _rng.randomize()

    # Avoid querying paths in _ready() before navigation map sync
    _setup.call_deferred()

func _process(_delta: float) -> void:
    print("AIHauler _process id=%s path=%s mode=%s is_processing=%s parent_mode=%s owner=%s" % [
        get_instance_id(),
        get_path(),
        process_mode,
        is_processing(),
        get_parent().process_mode,
        owner
    ])
    if hauler_task_system != null:
        match state:
            HaulerState.IDLE: _pick_new_target()
            _: print("Hauler doing nothing")

func _setup() -> void:
    print("AIHauler: _setup")
    await get_tree().physics_frame
    timer.timeout.connect(_on_WanderTimer_timeout)

func _physics_process(_delta: float) -> void:
    if agent.is_navigation_finished():
        body.desired_dir = Vector2.ZERO
        # TODO: Make more robust
        if state == HaulerState.GO_TO_LOOT:
            state = HaulerState.GO_TO_COLLECTOR
            agent.target_position = current_task.destination
        elif state == HaulerState.GO_TO_COLLECTOR:
            state = HaulerState.IDLE
        else:
            # Idle
            _pick_new_target()
            return

    var next_pos := agent.get_next_path_position()
    body.desired_dir = body.global_position.direction_to(next_pos)

func _on_WanderTimer_timeout() -> void:
    pass
    # _pick_new_target()

func _pick_new_target() -> void:
    print("Hauler is %s (%s)" % [hauler_task_system, self.get_instance_id()])
    current_task = hauler_task_system.request_task(self)
    agent.target_position = current_task.location

    state = HaulerState.GO_TO_LOOT
