class_name FireWeaponComponent
extends Node2D

var ranged_attack_system: RangedAttackSystem

func fire(type: StringName, direction: Vector2) -> bool:
    var ctx = RangedAttackSpawnContext.new(type, self, global_position, CombatantTeam.PLAYER)
    ctx.direction = direction
    var proj = ranged_attack_system.spawn(ctx) as RangedAttackBase
    return proj != null


func bind_ranged_attack_system(system: RangedAttackSystem) -> void:
    ranged_attack_system = system
