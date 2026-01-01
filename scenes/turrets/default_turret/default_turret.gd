extends Area2D

var level_container: LevelContainer

@onready var shot_timer: Timer = $ShotDelayTimer
@onready var attachments_root: Node2D = $AttachmentsRoot
@onready var aim_controller: AimFireController = attachments_root.get_node("Controllers/AimFireController")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	shot_timer.timeout.connect(aim_controller.fire)

func set_level_container_ref(container: LevelContainer) -> void:
	level_container = container

	var fire: FireWeaponComponent = $"AttachmentsRoot/FireWeaponComponent"
	fire.set_projectile_system(level_container.get_node("%ProjectileSystem"))

func set_target_provider(provider: TargetBaseProvider) -> void:
	aim_controller.set_target_provider(provider)
