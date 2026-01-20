class_name BeliefMap
extends RefCounted
## Purpose: Belief map data used by the director.

# Simple grid-based probabilistic field with diffusion + decay (Markov-like).
var cell_size: float = UIConsts.TILE_WIDTH_HEIGHT_PX
var decay_per_sec: float = 0.15
var diffusion_rate: float = 0.25 # 0..1 fraction of mass that diffuses outward each tick.
var _cells: Dictionary = { } # Vector2i -> float


func configure(cell_size_in: float, decay_per_sec_in: float, diffusion_rate_in: float) -> void:
    cell_size = max(1.0, cell_size_in)
    decay_per_sec = max(0.0, decay_per_sec_in)
    diffusion_rate = clampf(diffusion_rate_in, 0.0, 1.0)


func clear() -> void:
    _cells.clear()


func add_belief(world_pos: Vector2, amount: float) -> void:
    if amount <= 0.0:
        return
    var key := _world_to_cell(world_pos)
    _cells[key] = _cells.get(key, 0.0) + amount


func diffuse_and_decay(delta: float) -> void:
    if _cells.is_empty():
        return

    var decay_factor: float = max(0.0, 1.0 - decay_per_sec * delta)
    var next: Dictionary = { }

    for key in _cells.keys():
        var mass: float = _cells[key] * decay_factor
        if mass <= 0.0:
            continue

        var stay_mass := mass * (1.0 - diffusion_rate)
        _accumulate(next, key, stay_mass)

        var spread_mass := mass * diffusion_rate
        if spread_mass <= 0.0:
            continue

        var neighbors := _neighbors(key)
        var share := spread_mass / float(neighbors.size())
        for n in neighbors:
            _accumulate(next, n, share)

    # Prune near-zero cells.
    for k in next.keys():
        if next[k] <= 0.0005:
            next.erase(k)

    _cells = next


func get_all_cells() -> Dictionary:
    return _cells.duplicate(false)


func _accumulate(dict: Dictionary, key: Vector2i, amount: float) -> void:
    if amount <= 0.0:
        return
    dict[key] = dict.get(key, 0.0) + amount


func _neighbors(key: Vector2i) -> Array[Vector2i]:
    return [
        key + Vector2i(1, 0),
        key + Vector2i(-1, 0),
        key + Vector2i(0, 1),
        key + Vector2i(0, -1),
    ]


func _world_to_cell(world_pos: Vector2) -> Vector2i:
    return Vector2i(floor(world_pos.x / cell_size), floor(world_pos.y / cell_size))
