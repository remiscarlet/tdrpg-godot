extends Node2D
class_name AIHaulerController

var hauler_task_system: HaulerTaskSystem

var _rng := RandomNumberGenerator.new()

@export_flags_2d_navigation var navigation_layers := 1 # must match region layers you want to use

@onready var body: CombatantBase = get_parent().get_parent().get_parent() # CombatantBase/AttachmentsRoot/Controllers
@onready var agent: NavigationAgent2D = $NavigationAgent2D
@onready var interactable_detector_component: InteractableDetectorComponent

enum HaulerState {
    IDLE,
    GO_TO_LOOT,
    GO_TO_COLLECTOR,
    DEPOSIT, # interact
}

var completed_state: bool = true
var current_task: HaulTask
var state = HaulerState.IDLE

## Public methods

func bind_hauler_task_system(system: HaulerTaskSystem) -> void:
    print("Setting hauler to %s (%s)" % [system, get_instance_id()])
    hauler_task_system = system

func bind_interactable_detector_component(component: InteractableDetectorComponent) -> void:
    interactable_detector_component = component

## Lifecycle

func _ready() -> void:
    _rng.randomize()

    # Avoid querying paths in _ready() before navigation map sync
    _setup.call_deferred()

func _process(_delta: float) -> void:
    match state:
        HaulerState.DEPOSIT: _interact_with_collector()
        _: pass

func _setup() -> void:
    await get_tree().physics_frame
    agent.navigation_layers = navigation_layers

func _physics_process(_delta: float) -> void:
    if _can_transition_state():
        var tick_physics = _transition_hauler_state()

        if not tick_physics:
            return

    var next_pos := agent.get_next_path_position()
    body.desired_dir = body.global_position.direction_to(next_pos)

## Helpers

func _can_transition_state() -> bool:
    return agent.is_navigation_finished() and completed_state

## Returns bool on whether _physics_process should continue processing physics/navigation this frame
func _transition_hauler_state()-> bool:
    # TODO: Make more robust
    match state:
        HaulerState.IDLE:
            body.desired_dir = Vector2.ZERO
            _pick_new_target()
            state = HaulerState.GO_TO_LOOT
            return false
        HaulerState.GO_TO_LOOT:
            state = HaulerState.GO_TO_COLLECTOR
            agent.target_position = current_task.destination
        HaulerState.GO_TO_COLLECTOR:
            state = HaulerState.DEPOSIT
            completed_state = false # Refactor this. This is brittle. "Waiting for non-navigation action to complete"
        HaulerState.DEPOSIT:
            state = HaulerState.IDLE
        _: push_warning("Got an unknown HaulerState! (%s)" % state)

    return true

func _pick_new_target() -> void:
    current_task = hauler_task_system.request_task(self)
    if current_task == null:
        # No new tasks available
        return

    print("New hauling task: %s (%s) (%s)" % [current_task, current_task.location, current_task.destination])
    agent.target_position = current_task.location
    

func _interact_with_collector() -> void:
    if interactable_detector_component.try_interact():
        completed_state = true
        current_task.status = HaulTask.Status.DONE
    else:
        push_error("AI Hauler failed to interact with collector!")
