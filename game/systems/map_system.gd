extends Node

@export var map_scene: PackedScene = preload("res://scenes/world/maps/test_map.tscn")


func _ready() -> void:
    var map = map_scene.instantiate()
    add_child(map)
