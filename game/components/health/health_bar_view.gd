class_name HealthBarView
extends Node2D

@export var size := Vector2(32, 5)
@export var y_offset := -20.0
var ratio := 1.0


func _ready() -> void:
    # Center it above the parent by default.
    position = Vector2(-size.x * 0.5, y_offset)
    queue_redraw()


func set_ratio(r: float) -> void:
    ratio = clampf(r, 0.0, 1.0)
    queue_redraw()


func _draw() -> void:
    # Background
    draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, 0.6), true)
    # Fill
    draw_rect(Rect2(Vector2.ZERO, Vector2(size.x * ratio, size.y)), Color(0.2, 1.0, 0.2, 1.0), true)
