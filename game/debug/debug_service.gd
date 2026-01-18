class_name DebugService
extends Node
## A small "more serious" debug subsystem:
## - Owns DebugState (toggles)
## - Owns selection (selected combatant)
## - Emits high-level debug requests (e.g., override directives) via signals
## - Optionally applies overlay toggles by group

signal state_changed(state: DebugState)
signal selection_changed(selected: Node)
# Debug command plumbing (hook SquadManager to these later).
signal request_force_move_squad(squad_id: int, target_pos: Vector2)

@export var apply_overlay_groups: bool = true

var state: DebugState = DebugState.new()
var _selected_combatant_ref: WeakRef


func _ready() -> void:
    # DebugService is typically an AutoLoad named "Debug".
    state.state_changed.connect(_on_state_changed)
    _on_state_changed()


func set_selected_combatant(node: Node) -> void:
    if node == null:
        _selected_combatant_ref = null
        selection_changed.emit(null)
        _apply_overlay_groups_if_enabled()
        return

    _selected_combatant_ref = weakref(node)
    selection_changed.emit(node)
    _apply_overlay_groups_if_enabled()


func get_selected_combatant() -> CombatantBase:
    if _selected_combatant_ref == null:
        return null
    var obj := _selected_combatant_ref.get_ref() as CombatantBase
    return obj if obj != null else null


func get_selected_squad_id() -> int:
    var c := get_selected_combatant()
    if c == null:
        return -1
    var sl: SquadLink = c.squad_link
    if sl == null:
        return -1
    return sl.get_squad_id()


func toggle(flag: StringName) -> void:
    state.toggle(flag)


func select_combatant_under_mouse(viewport: Viewport) -> void:
    if viewport == null:
        return
    var cam := viewport.get_camera_2d()
    if cam == null:
        return
    var world_pos := cam.get_global_mouse_position()
    var found := _pick_combatant_at_world_pos(viewport, world_pos)
    set_selected_combatant(found)


func cycle_selected_combatant(step: int = 1) -> void:
    print("Cycling combatants: %s" % step)
    var nodes := get_tree().get_nodes_in_group("combatants")
    if nodes.is_empty():
        set_selected_combatant(null)
        return

    # Stable-ish order by NodePath string.
    nodes.sort_custom(
        func(a, b):
            return String(a.get_path()) < String(b.get_path())
    )

    var cur := get_selected_combatant()
    var idx := -1
    if cur != null:
        idx = nodes.find(cur)

    if idx < 0:
        idx = 0
    else:
        idx = (idx + step) % nodes.size()
        if idx < 0:
            idx += nodes.size()

    set_selected_combatant(nodes[idx])


func request_force_move_selected_squad(target_pos: Vector2) -> void:
    var squad_id := get_selected_squad_id()
    if squad_id < 0:
        push_warning("Debug: no selected squad to force-move.")
        return
    request_force_move_squad.emit(squad_id, target_pos)


# -------------------------
# Internals
# -------------------------
func _on_state_changed() -> void:
    state_changed.emit(state)
    _apply_overlay_groups_if_enabled()


func _apply_overlay_groups_if_enabled() -> void:
    if not apply_overlay_groups:
        return

    # This is intentionally simple and non-invasive:
    # - Set `enabled` if present
    # - Otherwise use `visible`
    _apply_overlay_group(Groups.DEBUG_OVERLAY_SQUAD, state.enabled and state.overlay_squad)
    _apply_overlay_group(Groups.DEBUG_OVERLAY_COMBATANT, state.enabled and state.overlay_combatant)
    _apply_overlay_group(Groups.DEBUG_OVERLAY_NAV, state.enabled and state.overlay_navigation)

    # Selection overlays are often useful only when there is a selection.
    var has_sel := get_selected_combatant() != null
    _apply_overlay_group(Groups.DEBUG_OVERLAY_SELECTION, state.enabled and state.overlay_selection and has_sel)


func _apply_overlay_group(group_name: StringName, on: bool) -> void:
    for n in get_tree().get_nodes_in_group(String(group_name)):
        print("Node %s in group %s" % [n, group_name])
        if n == null:
            continue

        if "enabled" in n:
            print("Setting %s enabled to %s" % [n, on])
            n.set("enabled", on)

        if n is CanvasItem:
            print("Setting %s visibility to %s" % [n, on])
            (n as CanvasItem).visible = on


func _pick_combatant_at_world_pos(viewport: Viewport, world_pos: Vector2) -> Node:
    # Point query first (precise).
    var space := viewport.get_world_2d().direct_space_state
    var params := PhysicsPointQueryParameters2D.new()
    params.position = world_pos
    params.collide_with_areas = true
    params.collide_with_bodies = true
    params.collision_mask = 0x7fffffff

    var hits := space.intersect_point(params, 16)
    for h in hits:
        var col: Object = h.get("collider")
        var c := _resolve_combatant_from_node(col)
        if c != null:
            return c

    # Fallback: nearest combatant within radius.
    var nearest: CombatantBase
    var best_d2 := INF
    for c in get_tree().get_nodes_in_group("combatants"):
        if c == null or not (c is CombatantBase):
            continue
        var d2 := (c as CombatantBase).global_position.distance_squared_to(world_pos)
        if d2 < best_d2 and d2 <= (64.0 * 64.0):
            best_d2 = d2
            nearest = c
    return nearest


func _resolve_combatant_from_node(n: Object) -> Node:
    var cur := n
    while cur != null and cur is Node:
        var node := cur as Node
        if node.is_in_group("combatants"):
            return node
        cur = node.get_parent()
    return null
