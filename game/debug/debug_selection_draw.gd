class_name DebugSelectionDraw
extends Node2D

@export var enabled: bool = true
@export_range(1.0, 120.0, 1.0) var refresh_hz: float = 30.0

@export var ring_radius: float = 22.0
@export_range(1.0, 8.0, 0.5) var ring_width: float = 2.0
@export var ring_color: Color = Color(0.2, 1.0, 0.2, 0.9)
@export var label_color: Color = Color(1.0, 1.0, 1.0, 0.95)
@export var label_font: Font
@export_range(6, 32, 1) var label_font_size: int = 11
@export var label_offset: Vector2 = Vector2(10.0, -14.0)

var _accum: float = 0.0


func _process(delta: float) -> void:
	if not enabled:
		return
	if refresh_hz <= 0.0:
		queue_redraw()
		return
	_accum += delta
	if _accum >= (1.0 / refresh_hz):
		_accum = 0.0
		queue_redraw()


func _draw() -> void:
	if not enabled:
		return

	var dbg := get_node_or_null("/root/Debug") as DebugService
	if dbg == null or not dbg.state.enabled or not dbg.state.overlay_selection:
		return

	var sel := dbg.get_selected_combatant()
	if sel == null or not (sel is Node2D):
		return

	var target := sel as Node2D
	var p := to_local(target.global_position)
	draw_arc(p, ring_radius, 0.0, TAU, 64, ring_color, ring_width, true)

	var f: Font = label_font if label_font != null else ThemeDB.fallback_font
	var fs: int = label_font_size if label_font_size > 0 else ThemeDB.fallback_font_size
	if f != null:
		draw_string(f, p + label_offset, target.name, HORIZONTAL_ALIGNMENT_LEFT, -1.0, fs, label_color)
