class_name AimingTargetResult
extends RefCounted

var has_target: bool
var dir: Vector2


func _init(new_has_target: bool, new_dir: Vector2) -> void:
    has_target = new_has_target
    dir = new_dir
