extends CombatantDefinition
class_name PlayerDefinition

var scene: PackedScene = preload("res://scenes/player/player.tscn")

@export var starting_items: Dictionary[StringName, int] = {} # item_id -> qty
@export var inventory_capacity = 10