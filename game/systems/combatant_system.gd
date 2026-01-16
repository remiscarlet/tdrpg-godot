class_name CombatantSystem
extends Node

@onready var level_container: LevelContainer = get_parent()
@onready var combatants_container: Node2D = $CombatantsContainer
@onready var ranged_attack_system: RangedAttackSystem = $"../RangedAttackSystem"


func spawn(ctx: CombatantSpawnContext) -> CombatantBase:
    print("Spawning %s" % ctx.combatant_id)

    var def := DefinitionDB.get_combatant(ctx.combatant_id)

    var node = def.scene.instantiate()
    var combatant := node as CombatantBase
    if combatant == null:
        push_error("Combatant scene does not inherit CombatantBase.")
        return null
    var rig := combatant.get_node("AttachmentsRig") as AttachmentsRig

    rig.module_host().configure_pre_tree(def, def.team_id, ctx)
    combatant.configure_pre_ready(ctx, def)

    combatants_container.add_child(combatant)
    if not combatant.is_node_ready():
        await combatant.ready

    rig.module_host().configure_post_ready(level_container)

    return combatant
