class_name HeatMap
extends RefCounted

## Purpose: Heat map data used by the director.
var cell_size: float = UIConsts.TILE_WIDTH_HEIGHT_PX
var decay_per_sec: float = 0.5
var _cells: Dictionary = { } # Vector2i -> float


func configure(cell_size_in: float, decay_per_sec_in: float) -> void:
    cell_size = max(1.0, cell_size_in)
    decay_per_sec = max(0.0, decay_per_sec_in)


func clear() -> void:
    _cells.clear()


func add_heat(world_pos: Vector2, amount: float) -> void:
    if amount <= 0.0:
        return
    var key := _world_to_cell(world_pos)
    _cells[key] = _cells.get(key, 0.0) + amount


func decay(delta: float) -> void:
    if _cells.is_empty():
        return
    var factor: float = max(0.0, 1.0 - (decay_per_sec * delta))
    var to_erase: Array = []
    for k in _cells.keys():
        var v: float = _cells[k] * factor
        if v <= 0.001:
            to_erase.append(k)
        else:
            _cells[k] = v
    for k in to_erase:
        _cells.erase(k)


func sample_cell(world_pos: Vector2) -> float:
    return _cells.get(_world_to_cell(world_pos), 0.0)


func get_all_cells() -> Dictionary:
    return _cells.duplicate(false)


func _world_to_cell(world_pos: Vector2) -> Vector2i:
    return Vector2i(floor(world_pos.x / cell_size), floor(world_pos.y / cell_size))
