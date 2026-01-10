extends Area2D
class_name TargetSensor2DComponent

signal target_sensed(node: Node)

@export var target_group: StringName = &"targetable"
@onready var shape = $CollisionShape2D

var sensor_radius: float
var team_id: int
var _candidates: Array[Node2D] = []

func set_sensor_radius(radius: float) -> void:
    sensor_radius = radius

func set_team_id(id: int) -> void:
    team_id = id

func _ready() -> void:
    print("Sensor radius: %s" % sensor_radius)
    shape.shape.radius = sensor_radius
    monitoring = true

    area_entered.connect(_on_area_entered)
    area_exited.connect(_on_area_exited)

    PhysicsUtils.set_target_detector_collisions_for_team(self, team_id)

func get_candidates() -> Array[Node2D]:
    _prune_invalid()
    return _candidates

func _on_area_entered(body: Node) -> void:
    print("Target Sensor detected: %s" % body)
    var node2d := body as Node2D
    if node2d == null:
        return
    # if target_group != &"" and not node2d.is_in_group(target_group):
    # 	return
    _candidates.append(node2d)
    target_sensed.emit(node2d)

func _on_area_exited(body: Node) -> void:
    var node2d := body as Node2D
    if node2d == null:
        return
    _candidates.erase(node2d)

func _prune_invalid() -> void:
    for i in range(_candidates.size() - 1, -1, -1):
        if not is_instance_valid(_candidates[i]):
            _candidates.remove_at(i)
