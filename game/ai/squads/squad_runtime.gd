class_name SquadRuntime
extends RefCounted

signal directive_changed(old_directive: SquadDirective, new_directive: SquadDirective, reason: String)

var anchor_position: Vector2 = Vector2.ZERO
var directive: SquadDirective:
    get:
        return _directive
var path: PackedVector2Array = PackedVector2Array()
var path_index: int = 0
var patrol_index: int = 0
var slot_offsets: PackedVector2Array = PackedVector2Array()
var slot_assignment: Dictionary = { } # instance_id -> slot_index
var slots_dirty: bool = true
var _directive: SquadDirective = null
var _last_directive_change: float = 0.0


func set_anchor_position(vec: Vector2) -> void:
    anchor_position = vec


func set_directive(new_directive: SquadDirective, reason: String = "") -> void:
    if new_directive == _directive:
        return

    assert(new_directive != null)

    var old := _directive
    _directive = new_directive
    directive_changed.emit(old, new_directive, reason)

    _last_directive_change = _get_now()


func get_time_since_last_directive_change() -> float:
    return _get_now() - _last_directive_change


func get_patrol_point() -> Vector2:
    return directive.patrol_points[patrol_index]


## If Looping, resets index to 0 on completion. If false, keeps at last valid index.
func increment_patrol_index() -> void:
    patrol_index += 1
    if patrol_index >= directive.patrol_points.size():
        patrol_index = 0 if directive.patrol_loop else (directive.patrol_points.size() - 1)


func _get_now() -> float:
    return Time.get_unix_time_from_system()
