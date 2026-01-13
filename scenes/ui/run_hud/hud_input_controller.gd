extends Node

var delay_config: Dictionary[StringName, Dictionary] = {
    Inputs.ZOOM_IN: {
        "last": 0.0,
        "delay": 0.25,
        "func": func(): minimap.zoom_in(),
        "held": false,
    },
    Inputs.ZOOM_OUT: {
        "last": 0.0,
        "delay": 0.25,
        "func": func(): minimap.zoom_out(),
        "held": false,
    },
    Inputs.ZOOM_RESET: {
        "last": 0.0,
        "delay": 0.25,
        "func": func(): minimap.zoom_reset(),
        "held": false,
    },
}

@onready var minimap: Minimap = %Minimap


func _process(_delay: float) -> void:
    for input in delay_config:
        var cfg = delay_config[input]
        if cfg["held"] and Input.is_action_pressed(input) and _can(input):
            if cfg["func"].call():
                _set_last(input)


func _unhandled_input(event: InputEvent) -> void:
    for input in delay_config:
        if event.is_action_pressed(input): # initial press only
            delay_config[input]["held"] = true
            get_viewport().set_input_as_handled()
        elif event.is_action_released(input):
            delay_config[input]["held"] = false


func _get_now() -> float:
    return Time.get_unix_time_from_system()


func _can(input_type: StringName) -> bool:
    var now := _get_now()
    var last: float = delay_config[input_type]["last"]
    var delay: float = delay_config[input_type]["delay"]
    return now >= last + delay


func _set_last(input_type: StringName) -> void:
    delay_config[input_type]["last"] = _get_now()
