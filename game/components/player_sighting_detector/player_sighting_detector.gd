class_name PlayerSightingDetector
extends Area2D

## Purpose: Detector that senses the player in range.
@export_range(32.0, 1024.0, 1.0) var detection_radius: float = 512.0
@export var intensity: float = 1.0

@onready var _shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
    monitoring = true
    if _shape != null and _shape.shape is CircleShape2D:
        (_shape.shape as CircleShape2D).radius = detection_radius

    body_entered.connect(_on_body)
    area_entered.connect(_on_area)


func _on_body(body: Node) -> void:
    _handle_collider(body)


func _on_area(area: Area2D) -> void:
    _handle_collider(area)


func _handle_collider(obj: Node) -> void:
    var hurtbox := obj as Hurtbox2DComponent
    if hurtbox == null:
        print("Not hurtbox: %s" % obj)
        return

    var team_id := _get_team_id(obj)
    if team_id != CombatantTeam.PLAYER:
        return

    var pos := _get_world_position(obj)
    Director.emit_observation(
        DirectorObservationEvent.at_position(
            DirectorObservationEvent.Kind.PLAYER_SIGHTING,
            pos,
            intensity,
            StringNames.PLAYER_SIGHTING_DETECTOR,
        ),
    )


func _get_team_id(hb: Hurtbox2DComponent) -> int:
    if hb == null:
        return -1

    if "definition" in hb.root and hb.root.definition != null and "team_id" in hb.root.definition:
        return int(hb.root.definition.team_id)

    if hb.has_method("get_team_id"):
        return int(hb.call("get_team_id"))

    return -1


func _get_world_position(obj: Node) -> Vector2:
    if obj != null and obj.has_method("get_global_position"):
        return obj.call("get_global_position")
    if obj is Node2D:
        return (obj as Node2D).global_position
    return global_position
