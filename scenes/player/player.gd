extends CombatantBase

var _screen_size: Vector2

@export var speed = 400
@onready var sprite = $BodySprite

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_screen_size = get_viewport_rect().size

func set_level_container_ref(container: LevelContainer) -> void:
	super(container)

	var fire: FireWeaponComponent = $"AttachmentsRoot/FireWeaponComponent"
	fire.set_projectile_system(level_container.get_node("%ProjectileSystem"))
