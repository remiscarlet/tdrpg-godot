extends Node2D

@export var target_path: NodePath
@export var follow_speed: float = 12.0 # higher = snappier

@onready var target: Node2D = get_node(target_path)


func _process(delta: float) -> void:
    if target == null:
        return

    # Exponential smoothing: stable across FPS changes
    var t := 1.0 - exp(-follow_speed * delta)
    global_position = global_position.lerp(target.global_position, t)


func set_target(new_target: Node2D) -> void:
    target = new_target
