extends Node2D

signal place_turret_requested(world_pos: Vector2, turret_scene: PackedScene)

var was_pressed_last_iter: bool
var pressed_duration: float

var turret1_scene: PackedScene = preload("res://scenes/turrets/default_turret/default_turret.tscn")

var selected_turret: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass  # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    var is_pressed = Input.is_action_pressed(Inputs.TURRET_KEY)

    var short_press = false
    var long_press_held = false
    var long_press_released = false
    """
    Short press: Hold less than 500ms and release
    Long press Held: Hold longer than 500ms
    Long Press Released: Long press released this frame
    """

    # Pre process
    if is_pressed:
        if was_pressed_last_iter:
            # Was pressed last iter, still pressed, extend duration
            pressed_duration += delta
    else:
        if was_pressed_last_iter:
            # Was pressed last iter, no longer pressed, check if short or long press
            if pressed_duration < Inputs.LONG_PRESS_DURATION_SEC:
                short_press = true
            else:
                long_press_released = true

    if pressed_duration >= Inputs.LONG_PRESS_DURATION_SEC:
        # Check if in long press duration regardless of key press state
        long_press_held = true
        print("++++")
        print("is_pressed: %s" % is_pressed)
        print("was_pressed_last_iter: %s" % was_pressed_last_iter)
        print("pressed_duration: %s" % pressed_duration)

        print("short_press: %s" % short_press)
        print("long_press_held: %s" % long_press_held)
        print("long_press_released: %s" % long_press_released)

    # Process
    if short_press or long_press_released:
        request_build_turret()
    elif long_press_held:
        configure_turret()

    # Post process
    if is_pressed:
        was_pressed_last_iter = true
    else:
        was_pressed_last_iter = false
        pressed_duration = 0.0


func configure_turret() -> void:
    # Allows modifying the "settings" at which request_build_turret() will atetmpt to build
    # a turret with. Eg, turret type, modifiers, etc
    pass


func get_turret_scene() -> PackedScene:
    # TODO: Multi turret selection
    return turret1_scene


func request_build_turret() -> void:
    var turret_scene = get_turret_scene()
    var world_pos = global_position

    place_turret_requested.emit(world_pos, turret_scene)
