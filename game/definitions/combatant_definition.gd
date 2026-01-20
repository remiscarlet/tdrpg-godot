class_name CombatantDefinition
extends DefinitionBase
## Purpose: Definition resource for combatant actors.

# Basic stats (expand later)
@export var team_id: int = CombatantTeam.PLAYER
@export var max_hp: int = 10
@export var move_speed: float = 100.0
# Optional: “archetype tags” for balancing / squad composition, etc.
@export var combat_tags: Array[StringName] = [] # e.g. ["swarm", "armored"]
