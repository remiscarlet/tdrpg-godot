extends Node2D
class_name AimToTarget2DComponent

var facing_root: Node2D
var _angle_vector: Vector2


func bind_facing_root(node: Node2D) -> void:
    facing_root = node


func set_target_angle(angle_vector: Vector2) -> void:
    _angle_vector = angle_vector


func _physics_process(_delta: float):
    facing_root.rotation = _angle_vector.normalized().angle()
