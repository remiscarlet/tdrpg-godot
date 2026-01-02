extends CombatantBase
class_name Player

var _screen_size: Vector2

@export var speed = 400
@onready var sprite = $BodySprite

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_screen_size = get_viewport_rect().size