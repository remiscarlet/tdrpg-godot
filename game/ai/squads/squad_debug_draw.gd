class_name SquadDebugDraw
extends Node2D

## Purpose: Debug draw node for squad visualization.
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
@export var metadata_font: Font
@export var metadata_font_size: int = 9
@export var metadata_padding: Vector2 = Vector2(5.0, 5.0)
@export var metadata_pos_offset: Vector2 = Vector2(-150.0, -150.0)
@export var metadata_bg: Color = Color.BLUE
@export var metadata_border: Color = Color.BLACK
@export var metadata_outline_size: int = 1
@export var metadata_text_outline: Color = Color.BLACK
@export var metadata_text_color: Color = Color.WHITE

var _debug: DebugService


func _ready() -> void:
    _debug = get_node_or_null("/root/Debug") as DebugService
    if _debug != null:
        _debug.state_changed.connect(func(_s: DebugState) -> void: queue_redraw())


func _process(_delta: float) -> void:
    if _is_debug_active():
        queue_redraw()


func _draw() -> void:
    if not _is_debug_active():
        return

    var mgr := get_node_or_null(squad_manager_path) as SquadSystem
    if mgr == null:
        return

    for s in mgr.get_all_squads():
        _draw_anchor(s)
        if draw_cohesion_radius:
            draw_circle(s.rt.anchor_position, s.get_current_cohesion_radius(), color_radius)

        if draw_slots:
            var offsets := s.get_debug_slot_offsets()
            for off in offsets:
                draw_circle(s.rt.anchor_position + off, slot_dot_radius, color_slots)

        if draw_anchor_path:
            var p := s.get_debug_path()
            for i in range(1, p.size()):
                draw_line(p[i - 1], p[i], color_path, path_width)

        _draw_metadata(s)


func _draw_anchor(s: Squad) -> void:
    var p := s.rt.anchor_position
    draw_line(p + Vector2.LEFT * anchor_cross_size, p + Vector2.RIGHT * anchor_cross_size, color_anchor, 2.0)
    draw_line(p + Vector2.UP * anchor_cross_size, p + Vector2.DOWN * anchor_cross_size, color_anchor, 2.0)


func _draw_metadata(s: Squad) -> void:
    # Pick a font + size (safe for Node2D / CanvasItem)
    var font: Font = metadata_font if metadata_font != null else ThemeDB.fallback_font
    var font_size: int = metadata_font_size if metadata_font_size > 0 else ThemeDB.fallback_font_size

    if font == null:
        return # extremely unlikely, but keeps the draw safe

    # Build lines (keep them short; debug overlays get noisy fast)
    var rt := s.rt
    var dir := rt.directive
    var dir_kind := str(dir.kind)

    var lines: PackedStringArray = []
    lines.append("Squad %d (team %d)" % [s.squad_id, s.team_id])
    lines.append("members %d / desired %d" % [s.members.size(), s.desired_count])
    lines.append("directive %s" % [dir_kind])
    lines.append("last directive change: %.2f" % [rt.get_time_since_last_directive_change()])
    lines.append("anchor (%.1f, %.1f)" % [rt.anchor_position.x, rt.anchor_position.y])
    lines.append("path pts %d idx %d" % [rt.path.size(), rt.path_index])
    lines.append("slots %d dirty %s" % [rt.slot_offsets.size(), str(rt.slots_dirty)])

    # Measure box size
    var max_w: float = 0.0
    for line in lines:
        # Font.get_string_size gives you a tight bounding size for that line.
        var sz: Vector2 = font.get_string_size(line, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size)
        max_w = max(max_w, sz.x)

    var line_h: float = font.get_height(font_size) # average line height
    var ascent: float = font.get_ascent(font_size) # needed because draw_string pos is baseline

    var text_size := Vector2(max_w, line_h * lines.size())
    var box_size := text_size + metadata_padding * 2.0

    # Position the box near the anchor (world-space; it will scale with camera zoom)
    var top_left: Vector2 = rt.anchor_position + metadata_pos_offset
    var rect := Rect2(top_left, box_size)

    # Background + border
    draw_rect(rect, metadata_bg, true)
    draw_rect(rect, metadata_border, false, 1.0)

    # Draw each line.
    # Important: draw_string uses the BASELINE, not the top-left. Add ascent to y.
    var pen := top_left + metadata_padding
    for i in range(lines.size()):
        var baseline_pos := pen + Vector2(0.0, ascent + line_h * i)

        # Outline first for readability (optional but very nice on busy backgrounds)
        if metadata_outline_size > 0:
            draw_string_outline(
                font,
                baseline_pos,
                lines[i],
                HORIZONTAL_ALIGNMENT_LEFT,
                -1.0,
                font_size,
                metadata_outline_size,
                metadata_text_outline,
            )

        draw_string(
            font,
            baseline_pos,
            lines[i],
            HORIZONTAL_ALIGNMENT_LEFT,
            -1.0,
            font_size,
            metadata_text_color,
        )


func _is_debug_active() -> bool:
    var on := enabled

    if _debug == null:
        return on

    var st := _debug.state
    if st == null:
        return on

    return on and st.enabled and st.overlay_squad
