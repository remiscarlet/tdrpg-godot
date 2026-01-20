class_name AimToTarget2DComponent
extends Node2D

## Purpose: Component that rotates aim toward a target.
var facing_root: Node2D
var _angle_vector: Vector2


func _physics_process(_delta: float):
    facing_root.rotation = _angle_vector.normalized().angle()


func bind_facing_root(node: Node2D) -> void:
    facing_root = node


func set_target_angle(angle_vector: Vector2) -> void:
    _angle_vector = angle_vector
