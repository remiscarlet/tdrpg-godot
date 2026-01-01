extends Node2D
class_name AimFireController

@onready var target_provider: TargetBaseProvider = MouseTargetProvider.new()

@onready var root: Node2D = get_parent().get_parent().get_parent() # Root/AttachmentsRoot/Controllers
@onready var attachments_root: Node2D = root.get_node("AttachmentsRoot")
@onready var aim_component: AimToTarget2DComponent = attachments_root.get_node("AimToTarget2DComponent")
@onready var fire_component: FireWeaponComponent = attachments_root.get_node("FireWeaponComponent")

var last_dir = Vector2.ZERO

func _process(_delta: float) -> void:
	aim()

func aim() -> void:
	var target = _get_target()
	aim_component.set_target_angle(target.dir)

func fire() -> bool:
	var target = _get_target()

	if not target.has_target:
		# Did not fire/no valid target
		return false

	return fire_component.fire(target.dir)

func set_target_provider(provider: TargetBaseProvider) -> void:
	target_provider = provider

func _get_target() -> AimingTargetResult:
	var dir = target_provider.get_target_direction(root)

	if dir == Vector2.ZERO:
		# No target - return the same dir as the last known target
		return AimingTargetResult.new(false, last_dir)

	last_dir = dir
	return AimingTargetResult.new(true, dir)

