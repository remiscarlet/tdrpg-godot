class_name DebugFlags
extends RefCounted

# DebugState flags
const ENABLED := &"enabled"
const SHOW_UI := &"show_ui"
const OVERLAY_SQUAD := &"overlay_squad"
const OVERLAY_COMBATANT := &"overlay_combatant"
const OVERLAY_NAVIGATION := &"overlay_navigation"
const OVERLAY_SELECTION := &"overlay_selection"
const OVERLAY_HEATMAP := &"overlay_heatmap"
const OVERLAY_BELIEF := &"overlay_belief"

# Debug input actions (InputMap)
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
