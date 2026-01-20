class_name MapRendererTilebake
extends RendererBase

## Purpose: Scene script for the minimap tile bake renderer.
@export var floor_fill_color: Color = Color(1, 1, 1, 0.12)
@export var floor_outline_color: Color = Color(1, 1, 1, 0.65)
@export_range(1.0, 12.0, 0.5) var floor_outline_width: float = 2.0
# var wall_fill_color: Color = Color(1, 0, 0, 0.5)
@export var wall_outline_color: Color = Color(1, 1, 1, 0.65)
@export_range(1.0, 12.0, 0.5) var wall_outline_width: float = 2.0
@export var tile_size: Vector2i = Vector2i(48, 48)

var wall_fill_color: Color
var contour_epsilon: float = 0.0 # Always render exact edges


func _ready() -> void:
    wall_fill_color = ProjectSettings.get_setting(
        "rendering/environment/defaults/default_clear_color",
    )


func bake(ctx: RenderContext) -> void:
    # You’ll need to provide this in your ctx, similar to nav_root.
    var layer := ctx.tilemap_layer as TileMapLayer
    if layer == null:
        push_warning("MapRendererTiles: ctx.tilemap_layer is null.")
        return

    var polys_root := ctx.poly_containers_root.get_node("%MapPolysRoot") as Node2D
    _clear_polys_root(polys_root)

    var cells := layer.get_used_cells()
    print("TileMapLayer used cells:", cells.size())
    if not cells.is_empty():
        print("Sample cell:", cells[0], " source_id=", layer.get_cell_source_id(cells[0]))
        layer.update_internals()

    var layermap_rect: Rect2i = layer.get_used_rect()
    print("layermap_rect: %s" % layermap_rect)
    if layermap_rect.size == Vector2i.ZERO:
        print("Got a TileMapLayer that was zero-sized! Aborting. Are you trying to bake too early?")
        return

    _generate_floor_polys(polys_root, layer, layermap_rect)
    _generate_wall_island_polys(polys_root, layer, layermap_rect)


func _generate_floor_polys(polys_root: Node2D, layer: TileMapLayer, layermap_rect: Rect2i) -> void:
    var bm := BitMap.new()
    bm.create(layermap_rect.size)

    for cell in layer.get_used_cells():
        if _is_walkable_cell(layer, cell):
            var map_cell := _map_to_bm(layermap_rect, cell.x, cell.y)
            bm.set_bitv(map_cell, true)

    _bake_bitmap_into_polys(
        polys_root,
        layer,
        bm,
        layermap_rect,
        floor_fill_color,
        floor_outline_color,
        floor_outline_width,
    )


func _generate_wall_island_polys(polys_root: Node2D, layer: TileMapLayer, layermap_rect: Rect2i) -> void:
    # Create bitmap of wall tiles (both inner and outer)
    var wall_bm := BitMap.new()
    wall_bm.create(layermap_rect.size)

    for cell in layer.get_used_cells():
        if _is_wall_cell(layer, cell):
            var bm_cell: Vector2i = _map_to_bm(layermap_rect, cell.x, cell.y)
            wall_bm.set_bitv(bm_cell, true)

    # Scan top row of tiles for a wall tile
    var col_with_wall := -1
    for x in layermap_rect.size.x:
        if wall_bm.get_bit(x, 0):
            col_with_wall = x
            break
    if col_with_wall == -1:
        push_warning("No border wall found")
        return

    var outer_wall_bm := _floodfill_outer_wall(col_with_wall, 0, wall_bm, layermap_rect)

    # Loop over outer wall bm. Cross reference with TileMapLayer.
    # Any TML cell that's a wall but not in outer_wall_bm is an inner wall.
    var inner_walls_bm := _bitmap_subtract(wall_bm, outer_wall_bm, layermap_rect.size)

    # Generate polygons for inner_walls_bm bits.
    _bake_bitmap_into_polys(
        polys_root,
        layer,
        inner_walls_bm,
        layermap_rect,
        wall_fill_color,
        wall_outline_color,
        wall_outline_width,
    )


func _floodfill_outer_wall(start_x: int, start_y: int, wall_bm: BitMap, layermap_rect: Rect2i) -> BitMap:
    var size: Vector2i = layermap_rect.size
    var w: int = size.x
    var h: int = size.y

    var visited := BitMap.new()
    visited.create(size)

    var outer_wall := BitMap.new()
    outer_wall.create(size)

    var stack := PackedInt32Array()
    stack.push_back(start_y * w + start_x)

    while stack.size() > 0:
        var i := stack[stack.size() - 1]
        stack.resize(stack.size() - 1)

        var x := i % w
        var y := i / w

        if visited.get_bit(x, y):
            continue
        visited.set_bit(x, y, true)

        if not wall_bm.get_bit(x, y):
            continue

        outer_wall.set_bit(x, y, true)

        # push neighbors (N4)
        if x > 0:
            stack.push_back(i - 1)
        if x < w - 1:
            stack.push_back(i + 1)
        if y > 0:
            stack.push_back(i - w)
        if y < h - 1:
            stack.push_back(i + w)

    return outer_wall


func _bm_to_map(rect: Rect2i, x: int, y: int) -> Vector2i:
    return rect.position + Vector2i(x, y)


func _map_to_bm(rect: Rect2i, x: int, y: int) -> Vector2i:
    return Vector2i(x, y) - rect.position


func _bake_bitmap_into_polys(
        polys_root: Node,
        layer: TileMapLayer,
        bm: BitMap,
        rect: Rect2i,
        fill_color: Color,
        outline_color: Color,
        outline_width: float,
) -> void:
    var polys: Array[PackedVector2Array] = bm.opaque_to_polygons(
        Rect2i(Vector2i.ZERO, rect.size),
        contour_epsilon,
    )

    var ts: Vector2i = tile_size # consider reading from TileSet instead
    var origin_layer_local := layer.map_to_local(rect.position) - (Vector2(ts) * 0.5)

    for poly in polys:
        var pts := PackedVector2Array()
        pts.resize(poly.size())

        for i in poly.size():
            var v := poly[i]
            var p_layer_local := origin_layer_local + Vector2(v.x * ts.x, v.y * ts.y)

            # If polys_root is not in the same space as layer, convert:
            pts[i] = polys_root.to_local(layer.to_global(p_layer_local))

        _add_poly(polys_root, pts, fill_color, outline_color, outline_width)


func _add_poly(root: Node2D, pts: PackedVector2Array, fill: Color, outline: Color, width: float) -> void:
    var poly := Polygon2D.new()
    poly.polygon = pts
    poly.color = fill
    root.add_child(poly)

    var line := Line2D.new()
    line.points = pts
    line.closed = true
    line.width = width
    line.default_color = outline
    root.add_child(line)


func _is_walkable_cell(layer: TileMapLayer, cell: Vector2i) -> bool:
    var td: TileData = layer.get_cell_tile_data(cell)
    if td == null:
        return false
    return td.has_custom_data(TileCustomData.WALKABLE) and bool(td.get_custom_data(TileCustomData.WALKABLE))


func _is_wall_cell(layer: TileMapLayer, cell: Vector2i) -> bool:
    var td := layer.get_cell_tile_data(cell)
    if td == null:
        return false
    return td.has_custom_data(TileCustomData.IS_WALL) and bool(td.get_custom_data(TileCustomData.IS_WALL))


func _bitmap_subtract(a: BitMap, b: BitMap, size: Vector2i) -> BitMap:
    var out := BitMap.new()
    out.create(size)
    for y in size.y:
        for x in size.x:
            if a.get_bit(x, y) and not b.get_bit(x, y):
                out.set_bit(x, y, true)
    return out
