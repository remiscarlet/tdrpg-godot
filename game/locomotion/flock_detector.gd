class_name FlockDetector
extends AreaCandidateDetectorBase

@export var flock_radius: float = 80.0
@export var auto_enable_monitoring: bool = true

@onready var shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
    _apply_radius()
    _configure_collisions()
    if auto_enable_monitoring:
        monitoring = true
    super._ready()


func set_flock_radius(radius: float) -> void:
    flock_radius = radius
    _apply_radius()


func _get_candidate_from_area(area: Area2D):
    # Each detector lives under a NavIntentLocomotionDriver; return the driver for boids logic.
    return area.get_parent() as NavIntentLocomotionDriver


func _apply_radius() -> void:
    if shape == null or shape.shape == null:
        return
    if shape.shape is CircleShape2D:
        (shape.shape as CircleShape2D).radius = flock_radius


func _configure_collisions() -> void:
    # Keep detectors on a shared sensor layer so they can see each other.
    set_collision_layer_value(Layers.FLOCK, true)
    set_collision_mask_value(Layers.FLOCK, true)
