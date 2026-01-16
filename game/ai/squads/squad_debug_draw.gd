class_name SquadDebugDraw
extends Node2D

@export var squad_manager_path: NodePath
@export var enabled: bool = true

@export var draw_cohesion_radius: bool = true
@export var draw_slots: bool = true
@export var draw_anchor_path: bool = true

@export var anchor_cross_size: float = 8.0
@export var slot_dot_radius: float = 2.5
@export var path_width: float = 2.0

@export var color_anchor: Color = Color(0.2, 0.9, 0.9, 0.9)
@export var color_radius: Color = Color(0.2, 0.9, 0.9, 0.25)
@export var color_slots: Color = Color(1.0, 1.0, 0.3, 0.85)
@export var color_path: Color = Color(0.9, 0.4, 1.0, 0.8)

func _process(_delta: float) -> void:
	if enabled:
		queue_redraw()

func _draw() -> void:
	if not enabled:
		return

	var mgr := get_node_or_null(squad_manager_path) as SquadManager
	if mgr == null:
		return

	for s in mgr.get_all_squads():
		_draw_anchor(s)
		if draw_cohesion_radius:
			draw_circle(s.anchor_position, s.get_current_cohesion_radius(), color_radius)

		if draw_slots:
			var offsets := s.get_debug_slot_offsets()
			for off in offsets:
				draw_circle(s.anchor_position + off, slot_dot_radius, color_slots)

		if draw_anchor_path:
			var p := s.get_debug_path()
			for i in range(1, p.size()):
				draw_line(p[i - 1], p[i], color_path, path_width)

func _draw_anchor(s: Squad) -> void:
	var p := s.anchor_position
	draw_line(p + Vector2.LEFT * anchor_cross_size, p + Vector2.RIGHT * anchor_cross_size, color_anchor, 2.0)
	draw_line(p + Vector2.UP * anchor_cross_size, p + Vector2.DOWN * anchor_cross_size, color_anchor, 2.0)
