extends CombatantDefinition
class_name EnemyDefinition

var scene: PackedScene = preload("res://scenes/enemies/default_enemy/default_enemy.tscn")

@export var threat_value: int = 1
@export var loot_table_id: StringName  # or a direct Resource ref later