extends Node2D

var _last_fired: float = 0.0
@onready var body: CombatantBase = get_parent().get_parent().get_parent() # CombatantBase/AttachmentsRoot/Controllers
@onready var player_aim_fire_controller: AimFireController = $"../AimFireController"

func _physics_process(_delta: float) -> void:
    var d := Vector2(
        Input.get_action_strength(Inputs.MOVE_RIGHT) - Input.get_action_strength(Inputs.MOVE_LEFT),
        Input.get_action_strength(Inputs.MOVE_DOWN) - Input.get_action_strength(Inputs.MOVE_UP)
    )
    body.desired_dir = d.normalized()

func _process(_delta: float) -> void:
    if Input.is_action_pressed(Inputs.CONFIRM):
        _handle_fire()


func _get_now() -> float:
    return Time.get_unix_time_from_system()


func _can_fire(delay: float) -> bool:
    var now := _get_now()
    return now >= _last_fired + delay


func _get_fire_delay() -> float:
    return 0.3


func _handle_fire() -> void:
    if not _can_fire(_get_fire_delay()):
        return

    if player_aim_fire_controller.fire():
        _last_fired = _get_now()
