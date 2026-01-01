extends Node2D
class_name PlayerAimFireController

@onready var attachments_root: Node2D = get_parent().get_parent() # CombatantBase/AttachmentsRoot/Controllers
@onready var aim_component: AimToTarget2DComponent = attachments_root.get_node("AimToTarget2DComponent")
@onready var fire_component: FireWeaponComponent = attachments_root.get_node("FireWeaponComponent")

var player_fire_mode = true

func _process(_delta: float) -> void:
	aim_at_mouse_pos()

func aim_at_mouse_pos() -> void:
	aim_component.set_target_angle(_get_target_dir())

func fire_at_mouse_pos() -> bool:
	return fire_component.fire(_get_target_dir())

func _get_target_dir() -> Vector2:
	return MouseUtils.get_dir_to_mouse(self)
