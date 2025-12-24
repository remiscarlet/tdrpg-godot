class_name DamageEvent
extends RefCounted

enum DamageType { KINETIC, EXPLOSIVE, ENERGY }

var amount: float
var damage_type: DamageType
var source: Node

func _init(
	amount_: float,
	source_: Node,
	damage_type_: DamageType = DamageType.KINETIC,
) -> void:
	amount = amount_
	damage_type = damage_type_
	source = source_