class_name HealthComponent
extends Node

signal health_changed(current: float, max: float)
signal died(source: Node)

@export var max_health: float = 100.0
var current_health: float

func _ready() -> void:
    current_health = max_health

func apply_damage(amount: float, source: Node = null) -> void:
    if amount <= 0.0:
        push_warning("Tried applying negative damage (%d) from %s" % [amount, source])
        return
    if current_health <= 0.0:
        push_warning("Tried applying damage from %s to an already dead entity (%s)!" % [source, self])
        return

    current_health = max(0.0, current_health - amount)
    health_changed.emit(current_health, max_health)
    if current_health <= 0.0:
        died.emit(source)

func heal(amount: float, source: Node = null) -> void:
    if amount <= 0.0:
        push_warning("Tried healing a negative amount (%d) from %s" % [amount, source])
        return
    if current_health <= 0.0:
        push_warning("Tried healing an already dead entity (%s)!" % self)
        return

    current_health = min(max_health, current_health + amount)
    health_changed.emit(current_health, max_health)