class_name DirectorDebugOverlay
extends Node2D

## Purpose: Debug overlay for director diagnostics.
@export var director_path: NodePath
@export var color: Color = Color(1, 0, 0, 0.3)
@export var enabled: bool = false

var cell_draw_size: float = UIConsts.TILE_WIDTH_HEIGHT_PX
var _director: Director


func _ready() -> void:
    if director_path != NodePath():
        _director = get_node_or_null(director_path)
    if _director == null:
        _director = Director.get_instance()


func _process(_delta: float) -> void:
    if enabled and _director != null:
        queue_redraw()


func _draw() -> void:
    if not enabled or _director == null:
        return
    var cells := _director.get_heat_map_snapshot()
    for k in cells.keys():
        var pos := Vector2(k.x * cell_draw_size, k.y * cell_draw_size)
        var rect := Rect2(pos, Vector2(cell_draw_size, cell_draw_size))
        var v: float = cells[k]
        var alpha := clampf(v, 0.02, 1.0) * color.a
        var c := Color(color.r, color.g, color.b, alpha)
        draw_rect(rect, c, true)
