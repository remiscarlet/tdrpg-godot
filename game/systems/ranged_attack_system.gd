class_name RangedAttackSystem
extends Node

@onready var ranged_attack_container: Node2D = $RangedAttackContainer


func spawn(ctx: RangedAttackSpawnContext) -> RangedAttackBase:
    var def := DefinitionDB.get_ranged_attack(ctx.ranged_attack_type_id)
    if def == null:
        push_error("Could not find definition for ranged attack '%s'!" % ctx.ranged_attack_type_id)
        return null

    var node := def.scene.instantiate()
    var projectile := node as RangedAttackBase
    if projectile == null:
        push_error("Projectile scene does not inherit RangedAttackBase.")
        return null

    ranged_attack_container.add_child(projectile)
    projectile.configure(ctx)

    return projectile
