class_name DebugInputController
extends Node

# Actions (created automatically if missing).
const ACT_TOGGLE_UI := &"debug_toggle_ui"
const ACT_TOGGLE_ENABLED := &"debug_toggle_enabled"
const ACT_TOGGLE_SQUAD := &"debug_toggle_squad_overlay"
const ACT_TOGGLE_COMBATANT := &"debug_toggle_combatant_overlay"
const ACT_TOGGLE_NAV := &"debug_toggle_navigation_overlay"
const ACT_TOGGLE_SELECTION := &"debug_toggle_selection_overlay"
const ACT_TOGGLE_HEATMAP := &"debug_toggle_heatmap_overlay"
const ACT_TOGGLE_BELIEF := &"debug_toggle_belief_overlay"
const ACT_CYCLE_TARGET_PREV := &"debug_cycle_target_prev"
const ACT_CYCLE_TARGET_NEXT := &"debug_cycle_target_next"
const ACT_FORCE_MOVE_SQUAD_HERE := &"debug_force_move_squad_here"

@export var enabled: bool = true

var _debug: DebugService
var _debug_ui_root: Control


func _ready() -> void:
    _debug = get_node_or_null("/root/Debug") as DebugService
    _debug_ui_root = get_node_or_null("../") as Control
    _ensure_default_actions()


func _input(event: InputEvent) -> void:
    if not enabled:
        return
    if _debug == null:
        return
    if not _debug.state.enabled:
        return

    # Ctrl (or Command on macOS) + left-click to select a combatant under the mouse.
    if event is InputEventMouseButton:
        var mb := event as InputEventMouseButton
        if mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT and (mb.ctrl_pressed or mb.meta_pressed):
            if _is_mouse_over_debug_ui():
                return

            _debug.select_combatant_under_mouse(get_viewport())
            get_viewport().set_input_as_handled()


func _unhandled_input(event: InputEvent) -> void:
    if not enabled:
        return
    if _debug == null:
        return

    # Always allow toggling debug globally.
    if event.is_action_pressed(String(ACT_TOGGLE_ENABLED)):
        _debug.toggle(&"enabled")
        get_viewport().set_input_as_handled()
        return

    # If debug is disabled, we generally don't handle other debug inputs.
    if not _debug.state.enabled:
        return

    if event.is_action_pressed(String(ACT_TOGGLE_UI)):
        _debug.toggle(&"show_ui")
        get_viewport().set_input_as_handled()
        return

    if event.is_action_pressed(String(ACT_TOGGLE_SQUAD)):
        _debug.toggle(&"overlay_squad")
        get_viewport().set_input_as_handled()
        return

    if event.is_action_pressed(String(ACT_TOGGLE_COMBATANT)):
        _debug.toggle(&"overlay_combatant")
        get_viewport().set_input_as_handled()
        return

    if event.is_action_pressed(String(ACT_TOGGLE_NAV)):
        _debug.toggle(&"overlay_navigation")
        get_viewport().set_input_as_handled()
        return

    if event.is_action_pressed(String(ACT_TOGGLE_SELECTION)):
        _debug.toggle(&"overlay_selection")
        get_viewport().set_input_as_handled()
        return

    if event.is_action_pressed(String(ACT_TOGGLE_HEATMAP)):
        _debug.toggle(&"overlay_heatmap")
        get_viewport().set_input_as_handled()
        return

    if event.is_action_pressed(String(ACT_TOGGLE_BELIEF)):
        _debug.toggle(&"overlay_belief")
        get_viewport().set_input_as_handled()
        return

    if event.is_action_pressed(String(ACT_CYCLE_TARGET_PREV)):
        _debug.cycle_selected_combatant(-1)
        get_viewport().set_input_as_handled()
        return

    if event.is_action_pressed(String(ACT_CYCLE_TARGET_NEXT)):
        _debug.cycle_selected_combatant(1)
        get_viewport().set_input_as_handled()
        return

    # Emit a debug request to force-move the selected squad to the mouse.
    if event.is_action_pressed(String(ACT_FORCE_MOVE_SQUAD_HERE)):
        var cam := get_viewport().get_camera_2d()
        if cam != null:
            _debug.request_force_move_selected_squad(cam.get_global_mouse_position())
        get_viewport().set_input_as_handled()
        return


func _ensure_default_actions() -> void:
    # Minimal defaults. You can (and probably should) override these in Project Settings.
    _ensure_key_action(ACT_TOGGLE_UI, KEY_F1)
    _ensure_key_action(ACT_TOGGLE_ENABLED, KEY_F2)
    _ensure_key_action(ACT_TOGGLE_SQUAD, KEY_F3)
    _ensure_key_action(ACT_TOGGLE_COMBATANT, KEY_F4)
    _ensure_key_action(ACT_TOGGLE_NAV, KEY_F5)
    _ensure_key_action(ACT_TOGGLE_SELECTION, KEY_F6)
    _ensure_key_action(ACT_TOGGLE_HEATMAP, KEY_F7)
    _ensure_key_action(ACT_TOGGLE_BELIEF, KEY_F8)
    _ensure_key_action(ACT_CYCLE_TARGET_PREV, KEY_PAGEUP)
    _ensure_key_action(ACT_CYCLE_TARGET_NEXT, KEY_PAGEDOWN)
    _ensure_key_action(ACT_FORCE_MOVE_SQUAD_HERE, KEY_F9)


func _ensure_key_action(action: StringName, keycode: Key) -> void:
    var a := String(action)
    if not InputMap.has_action(a):
        InputMap.add_action(a)

    # Only add our default binding if the action has no events.
    if InputMap.action_get_events(a).size() > 0:
        return

    var ev := InputEventKey.new()
    ev.keycode = keycode
    InputMap.action_add_event(a, ev)


func _is_mouse_over_debug_ui() -> bool:
    if _debug_ui_root == null:
        return false

    var hovered := get_viewport().gui_get_hovered_control()
    var c := hovered
    while c != null:
        if c == _debug_ui_root:
            return true
        c = c.get_parent() as Control
    return false
