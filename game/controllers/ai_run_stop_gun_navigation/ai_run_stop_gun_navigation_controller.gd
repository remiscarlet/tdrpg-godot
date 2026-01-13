extends Node2D
class_name AIRunStopGunNavigationController

var _rng := RandomNumberGenerator.new()

@export_flags_2d_navigation var navigation_layers := 1  # must match region layers you want to use

@onready var body: CombatantBase = get_parent().get_parent().get_parent()  # CombatantBase/AttachmentsRoot/Controllers
@onready var agent: NavigationAgent2D = $NavigationAgent2D

enum GunnerState {
    IDLE,
    MOVE_TO_TARGET,
    STOP_AND_GUN,
    RETREAT,
}

var fire_weapon_component: FireWeaponComponent

var ready_next_state: bool = true
var current_task: HaulTask
var current_state = GunnerState.IDLE

## Public methods


func bind_fire_weapon_component(component: FireWeaponComponent) -> void:
    fire_weapon_component = component


## Lifecycle


func _ready() -> void:
    _rng.randomize()

    # Avoid querying paths in _ready() before navigation map sync
    _setup.call_deferred()


func _process(_delta: float) -> void:
    match current_state:
        _:
            pass


func _setup() -> void:
    await get_tree().physics_frame
    agent.navigation_layers = navigation_layers


func _physics_process(delta: float) -> void:
    if _can_transition_state():
        var tick_physics = _transition_state(delta)

        if not tick_physics:
            return

    var next_pos := agent.get_next_path_position()
    body.desired_dir = body.global_position.direction_to(next_pos)


## Helpers


func _can_transition_state() -> bool:
    return agent.is_navigation_finished() and ready_next_state


## Returns bool on whether _physics_process should continue processing physics/navigation this frame
func _transition_state(delta: float) -> bool:
    # TODO: Make more robust
    match current_state:
        GunnerState.IDLE:
            _transition_state_idle()
            return false
        GunnerState.MOVE_TO_TARGET:
            pass
        GunnerState.STOP_AND_GUN:
            pass
        GunnerState.RETREAT:
            pass

        GunnerState.GO_TO_LOOT:
            if inventory_component.inventory.is_full():
                print("[%s] Inventory was full. Moving back to collector" % self)
                _transition_state_go_to_collector()
            else:
                print("[%s] Inventory was not full. Waiting for more loot." % self)
                current_state = GunnerState.WAITING_MORE_LOOT
        GunnerState.WAITING_MORE_LOOT:
            if _transition_state_idle():
                time_waiting_for_more_loot = 0.0
                return false

            time_waiting_for_more_loot += delta
            if time_waiting_for_more_loot >= time_waiting_for_more_loot_threshold_ms:
                _transition_state_go_to_collector()
                return true
            return false
        GunnerState.GO_TO_COLLECTOR:
            current_state = GunnerState.DEPOSIT
            ready_next_state = false  # Refactor this. This is brittle. "Waiting for non-navigation action to complete"
        GunnerState.DEPOSIT:
            current_state = GunnerState.IDLE
        _:
            push_warning("Got an unknown GunnerState! (%s)" % current_state)

    return true


func _transition_state_idle() -> bool:
    body.desired_dir = Vector2.ZERO
    _pick_new_target()
    if current_task != null:
        current_state = GunnerState.GO_TO_LOOT
    return current_task != null


func _transition_state_go_to_collector() -> void:
    current_state = GunnerState.GO_TO_COLLECTOR
    agent.target_position = current_task.collector_loc


func _pick_new_target() -> void:
    current_task = hauler_task_system.request_task(self)
    if current_task == null:
        # No new tasks available
        return

    print(
        (
            "New hauling task: %s (%s) (%s)"
            % [current_task, current_task.loot_loc, current_task.collector_loc]
        )
    )
    agent.target_position = current_task.loot_loc


func _interact_with_collector() -> void:
    if interactable_detector_component.try_interact():
        ready_next_state = true
        current_task.status = HaulTask.Status.DONE
    else:
        push_error("AI Hauler failed to interact with collector!")
