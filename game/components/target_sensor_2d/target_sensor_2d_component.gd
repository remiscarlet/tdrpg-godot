class_name TargetSensor2DComponent
extends Area2D

signal target_sensed(node: Hurtbox2DComponent)

var sensor_radius: float
var team_id: int = -1
var _candidates: Array[Hurtbox2DComponent] = []

@onready var shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
    _apply_radius()
    _apply_team()
    monitoring = true
    area_entered.connect(_on_area_entered)
    area_exited.connect(_on_area_exited)


func set_target_sensor_radius(radius: float) -> void:
    sensor_radius = radius
    _apply_radius()


func set_team_id(id: int) -> void:
    team_id = id
    _apply_team()


func get_candidates() -> Array[Hurtbox2DComponent]:
    _prune_invalid()
    return _candidates


func _apply_radius() -> void:
    if shape == null or shape.shape == null:
        return
    if shape.shape is CircleShape2D:
        (shape.shape as CircleShape2D).radius = sensor_radius


func _apply_team() -> void:
    if is_inside_tree() and team_id > -1:
        print("Applying detector collisions for team %d for %s" % [team_id, self])
        PhysicsUtils.set_target_detector_collisions_for_team(self, team_id)


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
