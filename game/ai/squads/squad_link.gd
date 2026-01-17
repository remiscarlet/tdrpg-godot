class_name SquadLink
extends RefCounted

var _combatant: CombatantBase
var _squad_id: int
var _squad_system: SquadSystem

func get_squad_id() -> int:
    return _squad_id

func _init(combatant: CombatantBase, id: int, system: SquadSystem) -> void:
    _combatant = combatant
    _squad_id = id
    _squad_system = system


func has_assigned_slot() -> bool:
    var squad := _get_squad()
    return squad.has_slot_target_for(_combatant)


func get_assigned_slot_pos() -> Vector2:
    var squad := _get_squad()
    return squad.get_slot_target_for(_combatant)


func get_return_pos() -> Vector2:
    var squad := _get_squad()
    return squad.rt.spawner_position


func has_active_move_directive() -> bool:
    var squad := _get_squad()
    # (As of writing) The only directive that isn't moving is HOLD.
    return squad.rt.directive.kind != SquadDirective.Kind.HOLD


func get_follow_directive_pos() -> Vector2:
    var squad := _get_squad()
    return squad.rt.anchor_position


func _get_squad() -> Squad:
    return _squad_system.get_squad(_squad_id)
