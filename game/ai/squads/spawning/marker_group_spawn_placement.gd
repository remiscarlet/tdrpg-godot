class_name MarkerGroupSpawnPlacement
extends SquadSpawnPlacement

@export var fallback_to_any_marker2d: bool = true


func pick(ctx: SquadSpawnPlacementContext) -> SquadSpawnPlacementResult:
    if ctx == null or ctx.spawner == null:
        return null

    var tree := ctx.spawner.get_tree()
    if tree == null:
        return null

    var nodes := tree.get_nodes_in_group(ctx.spawn_group)
    if nodes.is_empty():
        return null

    var points: Array[SquadSpawnPoint] = []
    var markers: Array[Marker2D] = []

    for n in nodes:
        if n is SquadSpawnPoint:
            var p := n as SquadSpawnPoint
            if p.enabled:
                points.append(p)
        elif n is Marker2D:
            markers.append(n as Marker2D)

    if not points.is_empty():
        var chosen := _pick_weighted(points)
        return SquadSpawnPlacementResult.new(chosen.get_spawn_position(), chosen)

    if fallback_to_any_marker2d and not markers.is_empty():
        var m: Marker2D = markers.pick_random()
        return SquadSpawnPlacementResult.new(m.global_position, m)

    return null


func _pick_weighted(points: Array[SquadSpawnPoint]) -> SquadSpawnPoint:
    if points.size() == 1:
        return points[0]

    var total: float = 0.0
    for p in points:
        total += max(p.weight, 0.0)

    if total <= 0.0:
        return points.pick_random()

    var r := randf() * total
    var acc: float = 0.0
    for p in points:
        acc += max(p.weight, 0.0)
        if r <= acc:
            return p

    return points[points.size() - 1]
