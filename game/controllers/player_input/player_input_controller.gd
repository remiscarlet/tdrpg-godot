extends Node2D

var delay_config: Dictionary[StringName, Dictionary] = {
    Inputs.CONFIRM: {
        "last": 0.0,
        "delay": 0.3,
        "func": func(): return player_aim_fire_controller.try_fire(),
        "held": false,
    },
    Inputs.INTERACT: {
        "last": 0.0,
        "delay": 1.0,
        "func": func(): return interactable_detector_component.try_interact(),
        "held": false,
    },
}

@onready var body: CombatantBase = get_parent().get_parent().get_parent() # CombatantBase/AttachmentsRoot/Controllers
@onready var player_aim_fire_controller: AimFireController
@onready var interactable_detector_component: InteractableDetectorComponent


func _process(_delay: float) -> void:
    for input in delay_config:
        var cfg = delay_config[input]
        if cfg["held"] and Input.is_action_pressed(input) and _can(input):
            if cfg["func"].call():
                _set_last(input)


func _physics_process(_delta: float) -> void:
    var d := Vector2(
        Input.get_action_strength(Inputs.MOVE_RIGHT) - Input.get_action_strength(Inputs.MOVE_LEFT),
        Input.get_action_strength(Inputs.MOVE_DOWN) - Input.get_action_strength(Inputs.MOVE_UP),
    )
    body.desired_dir = d.normalized()


## Use _unhandled_input for input events to allow other systems to take input priority, such as menu/UI/Canvas inputs
func _unhandled_input(event: InputEvent) -> void:
    for input in delay_config:
        if event.is_action_pressed(input): # initial press only
            delay_config[input]["held"] = true
            get_viewport().set_input_as_handled()
        elif event.is_action_released(input):
            delay_config[input]["held"] = false


func bind_player_aim_fire_controller(controller: AimFireController) -> void:
    player_aim_fire_controller = controller


func bind_interactable_detector_component(component: InteractableDetectorComponent) -> void:
    interactable_detector_component = component


func _get_now() -> float:
    return Time.get_unix_time_from_system()


func _can(input_type: StringName) -> bool:
    var now := _get_now()
    var last: float = delay_config[input_type]["last"]
    var delay: float = delay_config[input_type]["delay"]
    return now >= last + delay


func _set_last(input_type: StringName) -> void:
    delay_config[input_type]["last"] = _get_now()
