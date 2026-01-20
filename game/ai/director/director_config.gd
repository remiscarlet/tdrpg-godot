class_name DirectorConfig
extends Resource

## Purpose: Configuration resource for the director system.
@export var enabled: bool = false
@export var tick_interval_sec: float = 1.0
@export var max_observation_queue: int = 128
@export var heat_cell_size: float = UIConsts.TILE_WIDTH_HEIGHT_PX
@export var heat_decay_per_sec: float = 0.5
@export var heat_write_default: float = 1.0
@export var allow_debug_overlay: bool = false
@export var enable_directives: bool = false
@export var drop_unknown_events: bool = true
@export var placeholder_directive_interval_sec: float = 8.0
@export var placeholder_directive_radius: float = 512.0
@export var emit_placeholder_on_start: bool = true
@export var belief_cell_size: float = UIConsts.TILE_WIDTH_HEIGHT_PX
@export var belief_decay_per_sec: float = 0.15
@export var belief_diffusion_rate: float = 0.25


func clone() -> DirectorConfig:
    var c := DirectorConfig.new()
    c.enabled = enabled
    c.tick_interval_sec = tick_interval_sec
    c.max_observation_queue = max_observation_queue
    c.heat_cell_size = heat_cell_size
    c.heat_decay_per_sec = heat_decay_per_sec
    c.heat_write_default = heat_write_default
    c.allow_debug_overlay = allow_debug_overlay
    c.enable_directives = enable_directives
    c.drop_unknown_events = drop_unknown_events
    c.placeholder_directive_interval_sec = placeholder_directive_interval_sec
    c.placeholder_directive_radius = placeholder_directive_radius
    c.emit_placeholder_on_start = emit_placeholder_on_start
    c.belief_cell_size = belief_cell_size
    c.belief_decay_per_sec = belief_decay_per_sec
    c.belief_diffusion_rate = belief_diffusion_rate
    return c
