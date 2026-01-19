class_name DebugPanel
extends PanelContainer

var _debug: DebugService

@onready var _enabled_cb: CheckBox = %EnabledCheckBox
@onready var _show_ui_cb: CheckBox = %ShowUICheckBox
@onready var _squad_cb: CheckBox = %SquadOverlayCheckBox
@onready var _combatant_cb: CheckBox = %CombatantOverlayCheckBox
@onready var _nav_cb: CheckBox = %NavOverlayCheckBox
@onready var _sel_cb: CheckBox = %SelectionOverlayCheckBox
@onready var _heatmap_cb: CheckBox = %HeatmapOverlayCheckBox
@onready var _belief_cb: CheckBox = %BeliefOverlayCheckBox
@onready var _selected_lbl: Label = %SelectedTargetLabel
@onready var _selected_squad_lbl: Label = %SelectedSquadLabel


func _ready() -> void:
    _debug = get_node_or_null("/root/Debug") as DebugService
    if _debug == null:
        _selected_lbl.text = "DebugService not found at /root/Debug (set AutoLoad name to 'Debug')."
        return

    _debug.state_changed.connect(_on_debug_state_changed)
    _debug.selection_changed.connect(_on_selection_changed)

    _enabled_cb.toggled.connect(
        func(v: bool) -> void:
            _debug.toggle(&"enabled")
    )
    _show_ui_cb.toggled.connect(
        func(v: bool) -> void:
            _debug.toggle(&"show_ui")
    )
    _squad_cb.toggled.connect(
        func(v: bool) -> void:
            _debug.toggle(&"overlay_squad")
    )
    _combatant_cb.toggled.connect(
        func(v: bool) -> void:
            _debug.toggle(&"overlay_combatant")
    )
    _nav_cb.toggled.connect(
        func(v: bool) -> void:
            _debug.toggle(&"overlay_navigation")
    )
    _sel_cb.toggled.connect(
        func(v: bool) -> void:
            _debug.toggle(&"overlay_selection")
    )
    _heatmap_cb.toggled.connect(
        func(v: bool) -> void:
            _debug.toggle(&"overlay_heatmap")
    )
    _belief_cb.toggled.connect(
        func(v: bool) -> void:
            _debug.toggle(&"overlay_belief")
    )

    _on_debug_state_changed(_debug.state)
    _on_selection_changed(_debug.get_selected_combatant())


func _on_debug_state_changed(state: DebugState) -> void:
    # When show_ui is off, keep the node alive but hidden.
    visible = state.show_ui

    _set_checkbox_silent(_enabled_cb, state.enabled)
    _set_checkbox_silent(_show_ui_cb, state.show_ui)
    _set_checkbox_silent(_squad_cb, state.overlay_squad)
    _set_checkbox_silent(_combatant_cb, state.overlay_combatant)
    _set_checkbox_silent(_nav_cb, state.overlay_navigation)
    _set_checkbox_silent(_sel_cb, state.overlay_selection)
    _set_checkbox_silent(_heatmap_cb, state.overlay_heatmap)
    _set_checkbox_silent(_belief_cb, state.overlay_belief)


func _on_selection_changed(selected: Node) -> void:
    if selected == null:
        _selected_lbl.text = "Selected: <none>"
        _selected_squad_lbl.text = "Squad: <none>"
        return

    _selected_lbl.text = "Selected: %s" % selected.name
    if _debug != null:
        var sid := _debug.get_selected_squad_id()
        _selected_squad_lbl.text = "Squad: %d" % sid if sid >= 0 else "Squad: <none>"


func _set_checkbox_silent(cb: CheckBox, v: bool) -> void:
    if cb == null:
        return
    cb.set_block_signals(true)
    cb.button_pressed = v
    cb.set_block_signals(false)
