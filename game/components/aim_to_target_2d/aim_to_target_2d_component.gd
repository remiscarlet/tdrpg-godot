extends Node2D
class_name AimToTarget2DComponent

@onready var _parent: Node2D = get_parent().get_parent()
var _angle_vector: Vector2

func set_target_angle(angle_vector: Vector2) -> void:
	_angle_vector = angle_vector

func _physics_process(_delta: float):
	_parent.rotation = _angle_vector.normalized().angle()
