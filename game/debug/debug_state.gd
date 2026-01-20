class_name DebugState
extends Resource

signal state_changed

@export var enabled: bool = true:
    set = _set_enabled
@export var show_ui: bool = true:
    set = _set_show_ui
@export_group("Overlays")
@export var overlay_squad: bool = true:
    set = _set_overlay_squad
@export var overlay_combatant: bool = true:
    set = _set_overlay_combatant
@export var overlay_navigation: bool = false:
    set = _set_overlay_navigation
@export var overlay_selection: bool = true:
    set = _set_overlay_selection
@export var overlay_heatmap: bool = true:
    set = _set_overlay_heatmap
@export var overlay_belief: bool = true:
    set = _set_overlay_belief


func toggle(flag: StringName) -> void:
    match flag:
        DebugFlags.ENABLED:
            enabled = not enabled
        DebugFlags.SHOW_UI:
            show_ui = not show_ui
        DebugFlags.OVERLAY_SQUAD:
            overlay_squad = not overlay_squad
        DebugFlags.OVERLAY_COMBATANT:
            overlay_combatant = not overlay_combatant
        DebugFlags.OVERLAY_NAVIGATION:
            overlay_navigation = not overlay_navigation
        DebugFlags.OVERLAY_SELECTION:
            overlay_selection = not overlay_selection
        DebugFlags.OVERLAY_HEATMAP:
            overlay_heatmap = not overlay_heatmap
        DebugFlags.OVERLAY_BELIEF:
            overlay_belief = not overlay_belief
        _:
            push_warning("DebugState.toggle(): unknown flag '%s'" % String(flag))


func _emit_changed() -> void:
    state_changed.emit()


func _set_enabled(v: bool) -> void:
    if v == enabled:
        return
    enabled = v
    _emit_changed()


func _set_show_ui(v: bool) -> void:
    if v == show_ui:
        return
    show_ui = v
    _emit_changed()


func _set_overlay_squad(v: bool) -> void:
    if v == overlay_squad:
        return
    overlay_squad = v
    _emit_changed()


func _set_overlay_combatant(v: bool) -> void:
    if v == overlay_combatant:
        return
    overlay_combatant = v
    _emit_changed()


func _set_overlay_navigation(v: bool) -> void:
    if v == overlay_navigation:
        return
    overlay_navigation = v
    _emit_changed()


func _set_overlay_selection(v: bool) -> void:
    if v == overlay_selection:
        return
    overlay_selection = v
    _emit_changed()


func _set_overlay_heatmap(v: bool) -> void:
    if v == overlay_heatmap:
        return
    overlay_heatmap = v
    _emit_changed()


func _set_overlay_belief(v: bool) -> void:
    if v == overlay_belief:
        return
    overlay_belief = v
    _emit_changed()
