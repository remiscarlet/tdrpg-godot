class_name DamageEvent
extends RefCounted

## Purpose: Data event describing damage details.
enum DamageType { KINETIC, EXPLOSIVE, ENERGY }

var amount: float
var damage_type: DamageType
var source: Node


func _init(
        _amount: float,
        _source: Node,
        _damage_type: DamageType = DamageType.KINETIC,
) -> void:
    amount = _amount
    damage_type = _damage_type
    source = _source
