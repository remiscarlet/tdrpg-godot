class_name CombatantSystem
extends Node

@onready var level_container: LevelContainer = get_parent()
@onready var combatants_container: Node2D = $CombatantsContainer
@onready var projectile_system: ProjectileSystem = $"../ProjectileSystem"

func spawn(ctx: CombatantSpawnContext) -> CombatantBase:
    print("Spawning %s" % ctx.combatant_id)

    var combatant_definition := DefinitionDB.get_combatant(ctx.combatant_id)

    var node = combatant_definition.scene.instantiate()
    var combatant := node as CombatantBase
    if combatant == null:
        push_error("Combatant scene does not inherit CombatantBase.")
        return null

    combatant.configure_combatant_pre_ready(ctx, combatant_definition)

    combatants_container.add_child(combatant)
    if not combatant.is_node_ready():
        await combatant.ready

    combatant.configure_combatant_post_ready(ctx, combatant_definition, level_container)

    return combatant
