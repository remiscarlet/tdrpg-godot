class_name CombatantAIDebugDraw
extends Node2D

# World-space overlay for a single combatant's AI + locomotion.
#
# Intended placement (matches your DefaultEnemy wiring):
#   CombatantBase
#     AttachmentsRig
#       ControllersRoot
#         CombatantAIDebugDraw (this)
#
# It complements SquadDebugDraw by showing per-combatant:
#   - Active intent-state (from CombatantAISupervisor)
#   - Current locomotion intent + nav target (from NavIntentLocomotionDriver)
#   - Slot tether status + distances (from SquadLink + CombatantAISupervisor)
#   - The motor's current desired move and velocity (from CombatantBase)

@export var enabled: bool = true
@export_range(1.0, 120.0, 1.0) var refresh_hz: float = 30.0

@export_group("Bindings")
@export var body_path: NodePath
@export var supervisor_path: NodePath = NodePath("../CombatantAISupervisor")
@export var driver_path: NodePath = NodePath("../NavIntentLocomotionDriver")

@export_group("Draw")
@export var draw_metadata: bool = true
@export var draw_slot_and_goals: bool = true
@export var draw_tether_rings: bool = true

@export var metadata_font: Font
@export_range(6, 32, 1) var metadata_font_size: int = 10
@export var metadata_padding: Vector2 = Vector2(5.0, 5.0)
@export var metadata_pos_offset: Vector2 = Vector2(-170.0, -160.0)
@export var metadata_bg: Color = Color(0.05, 0.05, 0.07, 0.75)
@export var metadata_border: Color = Color(0.0, 0.0, 0.0, 0.9)
@export var metadata_outline_size: int = 1
@export var metadata_text_outline: Color = Color.BLACK
@export var metadata_text_color: Color = Color.WHITE

@export_group("Colors")
@export var color_slot: Color = Color(1.0, 1.0, 0.3, 0.85)
@export var color_slot_ring_max: Color = Color(1.0, 1.0, 0.3, 0.25)
@export var color_slot_ring_recover: Color = Color(1.0, 1.0, 0.3, 0.15)
@export var color_follow_goal: Color = Color(0.2, 0.9, 0.9, 0.9)
@export var color_driver_goal: Color = Color(0.9, 0.4, 1.0, 0.8)

var _body: CombatantBase
var _supervisor: CombatantAISupervisor
var _driver: NavIntentLocomotionDriver

var _accum: float = 0.0


func _ready() -> void:
    _body = _resolve_body()
    _supervisor = _resolve_supervisor()
    _driver = _resolve_driver()


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

    # Refresh bindings opportunistically (helps when adding the node in-editor).
    if _body == null:
        _body = _resolve_body()
    if _supervisor == null:
        _supervisor = _resolve_supervisor()
    if _driver == null:
        _driver = _resolve_driver()

    if _body == null:
        return

    if draw_slot_and_goals:
        _draw_slot_and_goals()

    if draw_metadata:
        _draw_metadata()


func _draw_slot_and_goals() -> void:
    var origin := to_local(_body.global_position)

    # Squad/slot diagnostics.
    var sl := _get_squad_link()
    if sl != null:
        if sl.has_assigned_slot():
            var slot_pos := sl.get_assigned_slot_pos()
            var slot_local := to_local(slot_pos)
            draw_line(origin, slot_local, color_slot, 2.0)

            if draw_tether_rings and _supervisor != null:
                draw_circle(slot_local, _supervisor.max_slot_distance, color_slot_ring_max)
                draw_circle(slot_local, _supervisor.recover_slot_distance, color_slot_ring_recover)

        # Follow goal (what FollowDirectiveState will target).
        if sl.has_active_move_directive():
            var follow_pos := sl.get_follow_directive_pos()
            draw_line(origin, to_local(follow_pos), color_follow_goal, 2.0)

    # Driver goal (what the agent is currently targeting).
    if _driver != null:
        var last_goal := _driver.get_last_goal()
        if last_goal.is_finite():
            draw_line(origin, to_local(last_goal), color_driver_goal, 2.0)


func _draw_metadata() -> void:
    var font: Font = metadata_font if metadata_font != null else ThemeDB.fallback_font
    var font_size: int = metadata_font_size if metadata_font_size > 0 else ThemeDB.fallback_font_size
    if font == null:
        return

    var lines: PackedStringArray = _build_lines()

    # Measure box size
    var max_w: float = 0.0
    for line in lines:
        var sz: Vector2 = font.get_string_size(line, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size)
        max_w = max(max_w, sz.x)

    var line_h: float = font.get_height(font_size)
    var ascent: float = font.get_ascent(font_size)

    var text_size := Vector2(max_w, line_h * lines.size())
    var box_size := text_size + metadata_padding * 2.0

    # Place near the combatant (local space). Use to_local() so this also works if the
    # debug node isn't at the combatant's origin.
    var anchor_local := to_local(_body.global_position)
    var top_left := anchor_local + metadata_pos_offset
    var rect := Rect2(top_left, box_size)

    draw_rect(rect, metadata_bg, true)
    draw_rect(rect, metadata_border, false, 1.0)

    var pen := top_left + metadata_padding
    for i in range(lines.size()):
        var baseline_pos := pen + Vector2(0.0, ascent + line_h * i)

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


func _build_lines() -> PackedStringArray:
    var lines: PackedStringArray = []

    # Combatant basics
    var team_id := -999
    var move_speed := -1.0
    if _body.definition != null:
        team_id = _body.definition.team_id
        move_speed = _body.definition.move_speed

    lines.append("%s (team %d)" % [_body.name, team_id])
    lines.append("pos (%.1f, %.1f)" % [_body.global_position.x, _body.global_position.y])
    lines.append("vel (%.1f, %.1f)  move_speed %.1f" % [_body.velocity.x, _body.velocity.y, move_speed])

    # Motor intent (what will be applied by CombatantBase)
    lines.append(
        "desired dir (%.2f, %.2f) scale %.2f" % [
            _body.get_desired_dir().x,
            _body.get_desired_dir().y,
            _body.get_desired_speed_scale(),
        ],
    )

    # Supervisor state
    if _supervisor != null:
        var active_state := _supervisor.get_active_state()
        var active_name: StringName = active_state.name if active_state != null else &"<none>"
        lines.append(
            "supervisor %s state %s returning %s" % [
                str(_supervisor.enabled),
                active_name,
                str(_supervisor.is_returning_to_slot()),
            ],
        )

    # Squad link / slot / directive summary
    var sl := _get_squad_link()
    if sl == null:
        lines.append("squad_link <null>")
    else:
        lines.append("squad_link squad_id %d" % [sl.get_squad_id()])

        if sl.has_assigned_slot():
            var slot_pos := sl.get_assigned_slot_pos()
            var d := _body.global_position.distance_to(slot_pos)
            var max_d := _supervisor.max_slot_distance if _supervisor != null else -1.0
            var rec_d := _supervisor.recover_slot_distance if _supervisor != null else -1.0

            lines.append(
                "slot d %.1f (max %.1f / recover %.1f)" % [d, max_d, rec_d],
            )
            lines.append("slot (%.1f, %.1f)" % [slot_pos.x, slot_pos.y])
        else:
            lines.append("slot <none>")

        # Directive summary (stay short; squad debug is already the verbose layer).
        var has_move := sl.has_active_move_directive()
        lines.append("directive move %s" % [str(has_move)])
        if has_move:
            var follow_pos := sl.get_follow_directive_pos()
            lines.append("follow_goal (%.1f, %.1f)" % [follow_pos.x, follow_pos.y])

        var ret_pos := sl.get_return_pos()
        if ret_pos.is_finite():
            lines.append("return_pos (%.1f, %.1f)" % [ret_pos.x, ret_pos.y])

    # Driver
    if _driver == null:
        lines.append("driver <null>")
    else:
        var intent_id := _driver.current_intent_id()
        lines.append(
            "driver enabled %s intent %s" % [str(_driver.enabled), String(intent_id)],
        )
        lines.append("driver last_goal (%.1f, %.1f)" % [_driver.get_last_goal().x, _driver.get_last_goal().y])

        if _driver.get_agent() != null:
            lines.append(
                "agent finished %s target (%.1f, %.1f)" % [
                    str(_driver.get_agent().is_navigation_finished()),
                    _driver.get_agent().target_position.x,
                    _driver.get_agent().target_position.y,
                ],
            )

    # Process ordering sanity check (common footgun)
    if _driver != null:
        var body_p := _body.process_physics_priority
        var driver_p := _driver.process_physics_priority
        var will_order_by_tree := (body_p == driver_p)
        if will_order_by_tree and _body.is_ancestor_of(_driver):
            lines.append("WARN: motor may tick before driver (same physics priority)")

    return lines


func _get_squad_link() -> SquadLink:
    # Most combatants will have this installed by your module system.
    return _body.squad_link as SquadLink


func _resolve_body() -> CombatantBase:
    if body_path != NodePath():
        return get_node_or_null(body_path) as CombatantBase

    var n: Node = self
    while n != null:
        if n is CombatantBase:
            return n as CombatantBase
        n = n.get_parent()

    return null


func _resolve_supervisor() -> CombatantAISupervisor:
    if supervisor_path != NodePath():
        return get_node_or_null(supervisor_path) as CombatantAISupervisor

    return _find_supervisor_in_descendants(self)


func _resolve_driver() -> NavIntentLocomotionDriver:
    if driver_path != NodePath():
        return get_node_or_null(driver_path) as NavIntentLocomotionDriver

    return _find_driver_in_descendants(self)


func _find_supervisor_in_descendants(root: Node) -> CombatantAISupervisor:
    # Small recursive search (debug-only; fine for this use).
    for c in root.get_children():
        if c is CombatantAISupervisor:
            return c as CombatantAISupervisor
        var found := _find_supervisor_in_descendants(c)
        if found != null:
            return found
    return null


func _find_driver_in_descendants(root: Node) -> NavIntentLocomotionDriver:
    # Small recursive search (debug-only; fine for this use).
    for c in root.get_children():
        if c is NavIntentLocomotionDriver:
            return c as NavIntentLocomotionDriver
        var found := _find_driver_in_descendants(c)
        if found != null:
            return found
    return null
