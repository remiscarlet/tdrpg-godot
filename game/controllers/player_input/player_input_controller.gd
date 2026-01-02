extends Node2D

@onready var body: CombatantBase = get_parent().get_parent().get_parent() # CombatantBase/AttachmentsRoot/Controllers
@onready var player_aim_fire_controller: AimFireController = $"../AimFireController"
@onready var interactable_detector_component: InteractableDetectorComponent = $"../../InteractableDetectorComponent"

func _physics_process(_delta: float) -> void:
    var d := Vector2(
        Input.get_action_strength(Inputs.MOVE_RIGHT) - Input.get_action_strength(Inputs.MOVE_LEFT),
        Input.get_action_strength(Inputs.MOVE_DOWN) - Input.get_action_strength(Inputs.MOVE_UP)
    )
    body.desired_dir = d.normalized()

var delay_config: Dictionary[StringName, Dictionary] = {
    Inputs.CONFIRM: {
        "last": 0.0,
        "delay": 0.3,
        "func": _try_fire
    },
    Inputs.INTERACT: {
        "last": 0.0,
        "delay": 1.0,
        "func": _try_interact
    }
}

func _unhandled_input(event: InputEvent) -> void:
    for input in delay_config:
        var handler_func: Callable = delay_config[input]["func"]
        if event.is_action_pressed(input) and _can(input):
            if handler_func.call():
                _set_last(input)
            get_viewport().set_input_as_handled() # stop other nodes from also acting

func _get_now() -> float:
    return Time.get_unix_time_from_system()

func _can(input_type: StringName) -> bool:
    var now := _get_now()
    var last: float = delay_config[input_type]["last"]
    var delay: float = delay_config[input_type]["delay"]
    return now >= last + delay

func _set_last(input_type: StringName) -> void:
    delay_config[input_type]["last"] = _get_now()

func _try_fire() -> bool:
    return player_aim_fire_controller.try_fire()

func _try_interact() -> bool:
    return interactable_detector_component.try_interact()
