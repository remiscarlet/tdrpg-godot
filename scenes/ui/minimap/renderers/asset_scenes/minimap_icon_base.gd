extends Node2D
class_name MinimapIconBase

var configured: bool = false
var color: Color
@onready var shape: Polygon2D = $Polygon2D

func configure(origin: Vector2, icon_color: Color) -> void:
    global_position = origin 
    color = icon_color 
    configured = true
    _activate_if_possible()

func _ready() -> void:
    _activate_if_possible()

func _activate_if_possible():
    if not configured:
        return
    if shape == null:
        return

    shape.color = color
