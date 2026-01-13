class_name Player
extends CombatantBase

@export var speed = 400

var _screen_size: Vector2


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    _screen_size = get_viewport_rect().size

    AimFireController.wire_aim_fire_controller(self)

    var aim_fire_controller = rig.get_node("%ControllersRoot/AimFireController")
    player_ctrl.bind_player_aim_fire_controller(aim_fire_controller)

    super()
