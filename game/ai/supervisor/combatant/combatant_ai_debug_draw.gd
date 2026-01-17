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
#   - Directive details (kind/target/patrol) via SquadLink -> SquadRuntime
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
# Directive visuals
@export var draw_directive_target: bool = true
@export var draw_patrol_points: bool = false
@export_range(1.0, 32.0, 0.5) var patrol_point_radius: float = 6.0
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
# Directive colors
@export var color_directive_target: Color = Color(0.3, 1.0, 0.4, 0.85)
@export var color_patrol_point: Color = Color(0.3, 1.0, 0.4, 0.65)

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
    var squad := _get_squad(sl)
    var rt := squad.rt if squad != null else null
    var directive: SquadDirective = rt.directive if rt != null else null

    if sl != null:
        var has_slot := _squadlink_has_assigned_slot(sl)
        if has_slot:
            var slot_pos := _squadlink_get_assigned_slot_pos(sl)
            var slot_local := to_local(slot_pos)
            draw_line(origin, slot_local, color_slot, 2.0)

            if draw_tether_rings and _supervisor != null:
                draw_circle(slot_local, _supervisor.max_slot_distance, color_slot_ring_max)
                draw_circle(slot_local, _supervisor.recover_slot_distance, color_slot_ring_recover)

        # Follow goal (what FollowDirectiveState will target).
        if _squadlink_has_active_move_directive(sl):
            var follow_pos := _squadlink_get_follow_directive_pos(sl)
            if follow_pos.is_finite():
                draw_line(origin, to_local(follow_pos), color_follow_goal, 2.0)

    # Directive target / patrol points (final “directive truth”, not the anchor/follow pos)
    if draw_directive_target and directive != null:
        match directive.kind:
            SquadDirective.Kind.HOLD, SquadDirective.Kind.MOVE_TO:
                var tp := directive.target_position
                if tp.is_finite():
                    var tp_local := to_local(tp)
                    draw_line(origin, tp_local, color_directive_target, 2.0)
                    draw_circle(tp_local, patrol_point_radius, color_directive_target)
            SquadDirective.Kind.PATROL:
                if rt != null and directive.patrol_points.size() > 0:
                    var p := rt.get_patrol_point()
                    if p.is_finite():
                        var p_local := to_local(p)
                        draw_line(origin, p_local, color_directive_target, 2.0)
                        draw_circle(p_local, patrol_point_radius, color_directive_target)

                if draw_patrol_points:
                    for i in range(directive.patrol_points.size()):
                        var pt := directive.patrol_points[i]
                        if not pt.is_finite():
                            continue
                        draw_circle(to_local(pt), patrol_point_radius * 0.6, color_patrol_point)

    # Driver goal (what the agent is currently targeting).
    if _driver != null:
        var last_goal := _driver_get_last_goal(_driver)
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
    lines.append("pos:(%.1f, %.1f)" % [_body.global_position.x, _body.global_position.y])
    lines.append("vel:(%.1f, %.1f)  move_speed:%.1f" % [_body.velocity.x, _body.velocity.y, move_speed])

    # Motor intent (what will be applied by CombatantBase)
    lines.append(
        "desired dir:(%.2f, %.2f) scale:%.2f" % [
            _body_get_desired_dir(_body).x,
            _body_get_desired_dir(_body).y,
            _body_get_desired_speed_scale(_body),
        ],
    )

    # Supervisor state
    if _supervisor != null:
        var active_state := _supervisor_get_active_state(_supervisor)
        var active_name: StringName = active_state.name if active_state != null else &"<none>"
        lines.append(
            "supervisor:%s state:%s returning:%s" % [
                str(_supervisor.enabled),
                active_name,
                str(_supervisor_is_returning(_supervisor)),
            ],
        )

    # Squad link / slot / directive summary
    var sl := _get_squad_link()
    var squad := _get_squad(sl)
    var rt := squad.rt if squad != null else null
    var directive: SquadDirective = rt.directive if rt != null else null

    if sl == null:
        lines.append("squad_link <null>")
    else:
        lines.append("squad_link squad_id %d" % [_squadlink_get_squad_id(sl)])

        if _squadlink_has_assigned_slot(sl):
            var slot_pos := _squadlink_get_assigned_slot_pos(sl)
            var d := _body.global_position.distance_to(slot_pos)
            var max_d := _supervisor.max_slot_distance if _supervisor != null else -1.0
            var rec_d := _supervisor.recover_slot_distance if _supervisor != null else -1.0

            lines.append(
                "slot d:%.1f (max %.1f / recover %.1f)" % [d, max_d, rec_d],
            )
            lines.append("slot:(%.1f, %.1f)" % [slot_pos.x, slot_pos.y])
        else:
            lines.append("slot:<none>")

        # Directive summary (slightly more verbose now for combatant-level debugging).
        if directive == null:
            lines.append("directive:<null>")
        else:
            lines.append("directive kind:%s age:%.1fs" % [_directive_kind_str(directive.kind), rt.get_time_since_last_directive_change()])

            match directive.kind:
                SquadDirective.Kind.HOLD, SquadDirective.Kind.MOVE_TO:
                    lines.append("directive target:(%.1f, %.1f)" % [directive.target_position.x, directive.target_position.y])
                SquadDirective.Kind.PATROL:
                    var n := directive.patrol_points.size()
                    var idx := rt.patrol_index if rt != null else -1
                    lines.append("patrol n:%d idx:%d loop:%s" % [n, idx, str(directive.patrol_loop)])
                    if rt != null and n > 0:
                        var p := rt.get_patrol_point()
                        lines.append("patrol pt:(%.1f, %.1f)" % [p.x, p.y])

        # Directive-follow / return helpers (these are what your combatant layer consumes)
        var has_move := _squadlink_has_active_move_directive(sl)
        lines.append("directive move:%s" % [str(has_move)])
        if has_move:
            var follow_pos := _squadlink_get_follow_directive_pos(sl)
            lines.append("follow_goal:(%.1f, %.1f)" % [follow_pos.x, follow_pos.y])

        var ret_pos := _squadlink_get_return_pos(sl)
        if ret_pos.is_finite():
            lines.append("return_pos:(%.1f, %.1f)" % [ret_pos.x, ret_pos.y])

    # Driver
    if _driver == null:
        lines.append("driver:<null>")
    else:
        var intent_id := _driver_current_intent_id(_driver)
        lines.append(
            "driver enabled:%s intent:%s" % [str(_driver.enabled), String(intent_id)],
        )
        var lg := _driver_get_last_goal(_driver)
        lines.append("driver last_goal:(%.1f, %.1f)" % [lg.x, lg.y])

        var agent := _driver_get_agent(_driver)
        if agent != null:
            lines.append(
                "agent finished:%s target:(%.1f, %.1f)" % [
                    str(agent.is_navigation_finished()),
                    agent.target_position.x,
                    agent.target_position.y,
                ],
            )

    # Process ordering sanity check (common footgun)
    if _driver != null:
        var body_p := _body.process_physics_priority
        var driver_p := _driver.process_physics_priority
        var will_order_by_tree := (body_p == driver_p)
        if will_order_by_tree and _body.is_ancestor_of(_driver):
            lines.append(
                "WARN: motor may tick before driver (same physics priority) (Body: %d, Driver: %d)" % [body_p, driver_p],
            )

    return lines


# --------------------------
# Squad / directive helpers
# --------------------------
func _get_squad_link() -> SquadLink:
    # Most combatants will have this installed by your module system.
    return _body.squad_link as SquadLink


func _get_squad(sl: SquadLink) -> Squad:
    if sl == null:
        return null
    # SquadLink in your repo has a private-ish _get_squad() helper; debug can use it.
    if sl.has_method("_get_squad"):
        return sl.call("_get_squad") as Squad
    return null


func _directive_kind_str(k: int) -> String:
    match k:
        SquadDirective.Kind.HOLD:
            return "HOLD"
        SquadDirective.Kind.MOVE_TO:
            return "MOVE_TO"
        SquadDirective.Kind.PATROL:
            return "PATROL"
    return "UNKNOWN(%d)" % k


func _squadlink_get_squad_id(sl: SquadLink) -> int:
    if sl == null:
        return -1
    if sl.has_method("get_squad_id"):
        return int(sl.call("get_squad_id"))
    # fallback for older SquadLink implementations
    if "_squad_id" in sl:
        return int(sl.get("_squad_id"))
    return -1


func _squadlink_has_assigned_slot(sl: SquadLink) -> bool:
    if sl == null:
        return false
    if sl.has_method("has_assigned_slot"):
        return bool(sl.call("has_assigned_slot"))
    # fallback: assume true if getter exists
    return sl.has_method("get_assigned_slot_pos")


func _squadlink_get_assigned_slot_pos(sl: SquadLink) -> Vector2:
    if sl == null:
        return Vector2.INF
    if sl.has_method("get_assigned_slot_pos"):
        return sl.call("get_assigned_slot_pos")
    return Vector2.INF


func _squadlink_has_active_move_directive(sl: SquadLink) -> bool:
    if sl == null:
        return false
    if sl.has_method("has_active_move_directive"):
        return bool(sl.call("has_active_move_directive"))
    return false


func _squadlink_get_follow_directive_pos(sl: SquadLink) -> Vector2:
    if sl == null:
        return Vector2.INF
    if sl.has_method("get_follow_directive_pos"):
        return sl.call("get_follow_directive_pos")
    return Vector2.INF


func _squadlink_get_return_pos(sl: SquadLink) -> Vector2:
    if sl == null:
        return Vector2.INF
    if sl.has_method("get_return_pos"):
        return sl.call("get_return_pos")
    return Vector2.INF


# --------------------------
# Driver / body / supervisor compatibility helpers
# --------------------------
func _driver_get_last_goal(d: Object) -> Vector2:
    if d == null:
        return Vector2.INF
    if d.has_method("get_last_goal"):
        return d.call("get_last_goal")
    if "_last_goal" in d:
        return d.get("_last_goal")
    return Vector2.INF


func _driver_get_agent(d: Object) -> NavigationAgent2D:
    if d == null:
        return null
    if d.has_method("get_agent"):
        return d.call("get_agent") as NavigationAgent2D
    if "_agent" in d:
        return d.get("_agent") as NavigationAgent2D
    return null


func _driver_current_intent_id(d: Object) -> StringName:
    if d == null:
        return &""
    if d.has_method("current_intent_id"):
        return d.call("current_intent_id")
    return &""


func _body_get_desired_dir(b: Object) -> Vector2:
    if b == null:
        return Vector2.ZERO
    if b.has_method("get_desired_dir"):
        return b.call("get_desired_dir")
    # fallback if you kept _desired_dir internally
    if "_desired_dir" in b:
        return b.get("_desired_dir")
    return Vector2.ZERO


func _body_get_desired_speed_scale(b: Object) -> float:
    if b == null:
        return 1.0
    if b.has_method("get_desired_speed_scale"):
        return float(b.call("get_desired_speed_scale"))
    # fallback if you kept _desired_speed_scale internally
    if "_desired_speed_scale" in b:
        return float(b.get("_desired_speed_scale"))
    return 1.0


func _supervisor_get_active_state(s: Object) -> Node:
    if s == null:
        return null
    if s.has_method("get_active_state"):
        return s.call("get_active_state") as Node
    if "_active_state" in s:
        return s.get("_active_state") as Node
    return null


func _supervisor_is_returning(s: Object) -> bool:
    if s == null:
        return false
    if s.has_method("is_returning_to_slot"):
        return bool(s.call("is_returning_to_slot"))
    if "_returning_to_slot" in s:
        return bool(s.get("_returning_to_slot"))
    return false


# --------------------------
# Binding resolution
# --------------------------
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
