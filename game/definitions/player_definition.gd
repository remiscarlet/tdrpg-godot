class_name PlayerDefinition
extends CombatantDefinition

@export var starting_items: Dictionary[StringName, int] = { } # item_id -> qty
@export var inventory_capacity = 10

var scene: PackedScene = preload("res://scenes/player/player.tscn")
