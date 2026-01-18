class_name SquadSpawnPolicyContext
extends RefCounted

var spawner: Node
var squad_system: SquadSystem
var now_sec: float


func _init(p_spawner: Node, p_squad_system: SquadSystem, p_now_sec: float) -> void:
    spawner = p_spawner
    squad_system = p_squad_system
    now_sec = p_now_sec
