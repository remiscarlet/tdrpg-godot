class_name DirectorState
extends RefCounted

var heat_map := HeatMap.new()
var belief_map := BeliefMap.new()
var last_tick_ms: int = 0
var alert_level: float = 0.0
var directives: Array[DirectorDirective] = []
var directive_timer_accum: float = 0.0


func reset(config: DirectorConfig) -> void:
    heat_map.configure(config.heat_cell_size, config.heat_decay_per_sec)
    heat_map.clear()
    belief_map.configure(
        config.belief_cell_size,
        config.belief_decay_per_sec,
        config.belief_diffusion_rate,
    )
    belief_map.clear()
    alert_level = 0.0
    directives.clear()
    last_tick_ms = Time.get_ticks_msec()
    directive_timer_accum = config.placeholder_directive_interval_sec if config.emit_placeholder_on_start else 0.0
