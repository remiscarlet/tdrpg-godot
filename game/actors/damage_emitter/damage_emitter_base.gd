class_name DamageEmitterBase
extends Area2D

var damage: float = 1.0
var elemental: Array[StringName] = []


func get_damage_payload() -> DamageEvent:
    return DamageEvent.new(damage, self)


func on_hit_target(_source: Node) -> void:
    pass
