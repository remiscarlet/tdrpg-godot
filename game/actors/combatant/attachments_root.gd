extends Node2D


func _process(_delta: float) -> void:
	rotation = -get_parent().global_rotation
