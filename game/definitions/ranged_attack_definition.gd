@tool
class_name RangedAttackDefinition
extends AttackDefinition

## Purpose: Definition resource for ranged attacks.
## Choose the firemode for this projectile, which also affects tagging
@export var kind: ShotModeDefinition
# Despawn range? Might be annoying to sync with detection range
