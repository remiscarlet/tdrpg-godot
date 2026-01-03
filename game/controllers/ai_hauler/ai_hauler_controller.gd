extends Node2D
class_name AIHaulerController

var hauler_task_system: HaulerTaskSystem

var _rng := RandomNumberGenerator.new()

@export_flags_2d_navigation var navigation_layers := 1 # must match region layers you want to use

@onready var body: CombatantBase = get_parent().get_parent().get_parent() # CombatantBase/AttachmentsRoot/Controllers
@onready var agent: NavigationAgent2D = $NavigationAgent2D
@onready var interactable_detector_component: InteractableDetectorComponent = $"../../InteractableDetectorComponent"

enum HaulerState {
    IDLE,
    GO_TO_LOOT,
    GO_TO_COLLECTOR,
    DEPOSIT, # interact
}

var _nav_ready: bool = false
var completed_state: bool = true
var current_task: HaulTask
var state = HaulerState.IDLE

## Public methods

func set_hauler_task_system(system: HaulerTaskSystem) -> void:
    print("Setting hauler to %s (%s)" % [system, get_instance_id()])
    hauler_task_system = system
    _try_activate()

## Lifecycle

func _enter_tree() -> void:
    set_physics_process(false)
    set_process(false)

func _ready() -> void:
    _rng.randomize()

    # Avoid querying paths in _ready() before navigation map sync
    _setup.call_deferred()

func _process(_delta: float) -> void:
    match state:
        HaulerState.DEPOSIT: _interact_with_collector()
        _: pass#print("Hauler doing nothing")

func _setup() -> void:
    await get_tree().physics_frame
    agent.navigation_layers = navigation_layers

    _try_activate()

func _physics_process(_delta: float) -> void:
    if _can_transition_state():
        # TODO: Make more robust
        match state:
            HaulerState.IDLE:
                body.desired_dir = Vector2.ZERO
                _pick_new_target()
                return
            HaulerState.GO_TO_LOOT:
                state = HaulerState.GO_TO_COLLECTOR
                agent.target_position = current_task.destination
            HaulerState.GO_TO_COLLECTOR:
                state = HaulerState.DEPOSIT
                completed_state = false # Refactor this. This is brittle. "Waiting for non-navigation action to complete"
            HaulerState.DEPOSIT:
                state = HaulerState.IDLE
            _: push_warning("Got an unknown HaulerState! (%s)" % state)

    var next_pos := agent.get_next_path_position()
    body.desired_dir = body.global_position.direction_to(next_pos)

## Helpers

func _try_activate() -> void:
    if not _nav_ready:
        return
    if hauler_task_system == null:
        return

    set_physics_process(true)
    set_process(true)

func _can_transition_state() -> bool:
    return agent.is_navigation_finished() and completed_state

func _pick_new_target() -> void:
    print("Hauler is %s (%s)" % [hauler_task_system, self.get_instance_id()])
    current_task = hauler_task_system.request_task(self)

    agent.target_position = current_task.location

    state = HaulerState.GO_TO_LOOT

func _interact_with_collector() -> void:
    if interactable_detector_component.try_interact():
        completed_state = true
    else:
        push_error("AI Hauler failed to interact with collector!")
