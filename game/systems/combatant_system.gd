class_name CombatantSystem
extends Node

@onready var level_container: LevelContainer = get_parent()
@onready var combatants_container: Node2D = $CombatantsContainer
@onready var projectile_system: ProjectileSystem = $"../ProjectileSystem"

class CombatantConfig:
    var scene: PackedScene
    var team_id: int

    func _init(
        c_scene: PackedScene,
        c_team_id: int,
    ):
        scene = c_scene
        team_id = c_team_id

var mapping = {
    CombatantTypes.PLAYER: CombatantConfig.new(preload("res://scenes/player/player.tscn"), CombatantTeam.PLAYER),
    CombatantTypes.DEFAULT_AUTOMATON: CombatantConfig.new(preload("res://scenes/automatons/default_automaton/default_automaton.tscn"), CombatantTeam.PLAYER),
    CombatantTypes.DEFAULT_ENEMY: CombatantConfig.new(preload("res://scenes/enemies/default_enemy/default_enemy.tscn"), CombatantTeam.MUTANT),
}

func _get_combatant_config(type: StringName) -> CombatantConfig:
    if not mapping.has(type):
        push_error("Tried getting a CombatantConfig for an unknown CombatantTypes! Got: %s" % type)
    return mapping.get(type)

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
