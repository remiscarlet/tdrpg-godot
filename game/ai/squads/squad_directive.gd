class_name SquadDirective
extends RefCounted

enum Kind { HOLD, MOVE_TO, PATROL }

var kind: Kind = Kind.HOLD
# HOLD / MOVE_TO
var target_position: Vector2 = Vector2.ZERO
# PATROL
var patrol_points: PackedVector2Array = PackedVector2Array()
var patrol_loop: bool = true


static func hold(at: Vector2) -> SquadDirective:
    var d := SquadDirective.new()
    d.kind = Kind.HOLD
    d.target_position = at
    return d


static func move_to(pos: Vector2) -> SquadDirective:
    var d := SquadDirective.new()
    d.kind = Kind.MOVE_TO
    d.target_position = pos
    return d


static func patrol(points: PackedVector2Array, loop: bool = true) -> SquadDirective:
    var d := SquadDirective.new()
    d.kind = Kind.PATROL
    d.patrol_points = points
    d.patrol_loop = loop
    return d
