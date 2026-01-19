class_name TargetSensor2DComponent
extends AreaCandidateDetectorBase

signal target_sensed(node: Hurtbox2DComponent)

var sensor_radius: float
var team_id: int = -1

@onready var shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
    _apply_radius()
    _apply_team()
    monitoring = true
    super._ready()


func set_target_sensor_radius(radius: float) -> void:
    sensor_radius = radius
    _apply_radius()


func set_team_id(id: int) -> void:
    team_id = id
    _apply_team()


func get_candidates() -> Array[Hurtbox2DComponent]:
    var typed: Array[Hurtbox2DComponent] = []
    for candidate in super.get_candidates():
        var hurtbox := candidate as Hurtbox2DComponent
        if hurtbox != null:
            typed.append(hurtbox)
    return typed


func _apply_radius() -> void:
    if shape == null or shape.shape == null:
        return
    if shape.shape is CircleShape2D:
        (shape.shape as CircleShape2D).radius = sensor_radius


func _apply_team() -> void:
    if is_inside_tree() and team_id > -1:
        print("Applying detector collisions for team %d for %s" % [team_id, self])
        PhysicsUtils.set_target_detector_collisions_for_team(self, team_id)


func _get_candidate_from_area(area: Area2D):
    return area as Hurtbox2DComponent


func _candidate_entered(candidate) -> void:
    target_sensed.emit(candidate)
