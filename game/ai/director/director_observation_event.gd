class_name DirectorObservationEvent
extends RefCounted

enum Kind {
    UNKNOWN,
    PLAYER_SIGHTING,
    PLAYER_ATTACK,
    STRUCTURE_DAMAGE,
    SQUAD_STATUS,
    COMBATANT_STATUS,
}

var kind: Kind = Kind.UNKNOWN
var position: Vector2 = Vector2.ZERO
var intensity: float = 1.0
var source_id: StringName = &""
var timestamp_ms: int = 0
var metadata: Dictionary = { }


static func at_position(kind: Kind, pos: Vector2, intensity: float = 1.0, source_id: StringName = &"") -> DirectorObservationEvent:
    var e := DirectorObservationEvent.new()
    e.kind = kind
    e.position = pos
    e.intensity = max(0.0, intensity)
    e.source_id = source_id
    e.timestamp_ms = Time.get_ticks_msec()
    return e


static func copy_from(other: DirectorObservationEvent) -> DirectorObservationEvent:
    if other == null:
        return null
    var e := DirectorObservationEvent.new()
    e.kind = other.kind
    e.position = other.position
    e.intensity = other.intensity
    e.source_id = other.source_id
    e.timestamp_ms = other.timestamp_ms
    e.metadata = other.metadata.duplicate(true)
    return e
