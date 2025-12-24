class_name CombatantSystem
extends Node

@onready var combatants_container: Node2D = $CombatantsContainer

func spawn(combatant_scene: PackedScene, ctx: CombatantSpawnContext) -> CombatantBase:
	var node := combatant_scene.instantiate()
	var combatant := node as CombatantBase
	if combatant == null:
		push_error("Projectile scene does not inherit ProjectileBase.")
		return null

	combatant.projectile_system = ctx.projectile_system

	combatants_container.add_child(combatant)
	return combatant
