@tool
extends Node2D

@export_tool_button("Re-anchor TileMapLayers to (0,0)", "TileMap") var reanchor_action = reanchor_to_top_left

@export var include_nested_children := true

func reanchor_to_top_left() -> void:
	var layers := _gather_tilemap_layers(self, include_nested_children)
	if layers.is_empty():
		return

	# Find the minimum (top-left) used cell across ALL layers.
	var have_any := false
	var min_cell := Vector2i.ZERO

	for layer in layers:
		var rect: Rect2i = layer.get_used_rect() # encloses used tiles 
		if rect.size == Vector2i.ZERO:
			continue
		if not have_any:
			min_cell = rect.position
			have_any = true
		else:
			min_cell.x = min(min_cell.x, rect.position.x)
			min_cell.y = min(min_cell.y, rect.position.y)

	if not have_any:
		return

	# Shift so that min used cell becomes (0,0).
	var delta := -min_cell
	if delta == Vector2i.ZERO:
		return

	for layer in layers:
		_shift_layer_cells(layer, delta)

func _shift_layer_cells(layer: TileMapLayer, delta: Vector2i) -> void:
	var cells: Array[Vector2i] = layer.get_used_cells() # all non-empty cells
	if cells.is_empty():
		return

	# Snapshot the cell identifiers.
	var snapshot: Array[Dictionary] = []
	snapshot.resize(cells.size())
	for i in cells.size():
		var c := cells[i]
		snapshot[i] = {
			"coords": c,
			"source_id": layer.get_cell_source_id(c),
			"atlas": layer.get_cell_atlas_coords(c),
			"alt": layer.get_cell_alternative_tile(c), # preserves flip/rotate flags
		}

	layer.clear() # Clears all cells 

	for entry in snapshot:
		layer.set_cell(entry.coords + delta, entry.source_id, entry.atlas, entry.alt)

	# Optional, but makes editor refresh immediately (otherwise end-of-frame).
	layer.update_internals()

func _gather_tilemap_layers(root: Node, recursive: bool) -> Array[TileMapLayer]:
	var out: Array[TileMapLayer] = []
	_collect_layers(root, recursive, out)
	return out

func _collect_layers(node: Node, recursive: bool, out: Array[TileMapLayer]) -> void:
	for child in node.get_children():
		if child is TileMapLayer:
			out.append(child)
		if recursive and child.get_child_count() > 0:
			_collect_layers(child, true, out)