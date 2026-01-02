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
    print("Spawning %s" % ctx.type)

    var combatant_config := _get_combatant_config(ctx.type)
    var node := combatant_config.scene.instantiate()

    var combatant := node as CombatantBase
    if combatant == null:
        push_error("Projectile scene does not inherit ProjectileBase.")
        return null

    combatant.global_position = ctx.origin

    var team_id = combatant_config.team_id
    var hurtbox = combatant.get_node("Hurtbox2DComponent")
    PhysicsUtils.set_hurtbox_physics_for_team(hurtbox, team_id)

    var pickupbox = combatant.get_node("AttachmentsRoot/PickupboxComponent/PickupSensorArea")
    PhysicsUtils.set_pickupbox_physics_for_team(pickupbox, team_id)

    combatants_container.add_child(combatant)
    if not combatant.is_node_ready():
        await combatant.ready

    combatant.set_level_container_ref(level_container)
    combatant.set_controller_by_team_id(team_id)
    

    return combatant
