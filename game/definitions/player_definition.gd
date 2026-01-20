class_name PlayerDefinition
extends CombatantDefinition

## Purpose: Definition resource for the player combatant.
@export var starting_items: Dictionary[StringName, int] = { } # item_id -> qty
@export var inventory_capacity = 10
