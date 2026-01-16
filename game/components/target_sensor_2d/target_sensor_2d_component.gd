class_name TargetSensor2DComponent
extends Area2D

signal target_sensed(node: Hurtbox2DComponent)

var sensor_radius: float
var team_id: int
var _candidates: Array[Hurtbox2DComponent] = []

@onready var shape = $CollisionShape2D


func _ready() -> void:
    print("Sensor radius: %s" % sensor_radius)
    shape.shape.radius = sensor_radius
    monitoring = true

    area_entered.connect(_on_area_entered)
    area_exited.connect(_on_area_exited)

    PhysicsUtils.set_target_detector_collisions_for_team(self, team_id)


func set_target_sensor_radius(radius: float) -> void:
    sensor_radius = radius


func set_team_id(id: int) -> void:
    team_id = id


func get_candidates() -> Array[Hurtbox2DComponent]:
    _prune_invalid()
    return _candidates


func _on_area_entered(body: Node) -> void:
    print("Target Sensor detected: %s" % body)
    var hurtbox := body as Hurtbox2DComponent
    if hurtbox == null:
        return
    _candidates.append(hurtbox)
    target_sensed.emit(hurtbox)


func _on_area_exited(body: Node) -> void:
    var hurtbox := body as Hurtbox2DComponent
    if hurtbox == null:
        return
    _candidates.erase(hurtbox)


func _prune_invalid() -> void:
    for i in range(_candidates.size() - 1, -1, -1):
        if not is_instance_valid(_candidates[i]):
            _candidates.remove_at(i)
