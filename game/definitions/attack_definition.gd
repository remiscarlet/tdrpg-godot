class_name AttackDefinition
extends DefinitionBase

## Purpose: Definition resource for attack stats.
## For multi-projectile/hit attacks, damage is split evenly across them.
## Specific subclasses may have randomizing parameters for each hit to emulate randomized damage per hit
@export var damage: float
