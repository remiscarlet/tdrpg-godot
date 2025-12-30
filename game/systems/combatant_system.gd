class_name CombatantSystem
extends Node

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
	Const.CombatantType.PLAYER: CombatantConfig.new(preload("res://scenes/player/player.tscn"), Const.TEAM_PLAYER),
	Const.CombatantType.DEFAULT_ENEMY: CombatantConfig.new(preload("res://scenes/enemies/default_enemy/default_enemy.tscn"), Const.TEAM_MUTANT),
}

func _get_combatant_config(type: Const.CombatantType) -> CombatantConfig:
	if not mapping.has(type):
		push_error("Tried getting a CombatantConfig for an unknown CombatantType! Got: %s" % type)
	return mapping.get(type)

func spawn(ctx: CombatantSpawnContext) -> CombatantBase:
	var combatant_config := _get_combatant_config(ctx.type)
	var node := combatant_config.scene.instantiate()

	var combatant := node as CombatantBase
	if combatant == null:
		push_error("Projectile scene does not inherit ProjectileBase.")
		return null

	combatant.projectile_system = projectile_system
	combatant.global_position = ctx.origin

	var hurtbox = combatant.get_node("Hurtbox2DComponent")
	PhysicsUtils.set_hurtbox_physics_for_team(hurtbox, combatant_config.team_id)

	combatants_container.add_child(combatant)
	return combatant
