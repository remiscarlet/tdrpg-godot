class_name MapRendererTilebake
extends RendererBase

@export var floor_fill_color: Color = Color(1, 1, 1, 0.12)
@export var floor_outline_color: Color = Color(1, 1, 1, 0.65)
@export_range(1.0, 12.0, 0.5) var floor_outline_width: float = 2.0

var wall_fill_color: Color = ProjectSettings.get_setting(
    "rendering/environment/defaults/default_clear_color"
)
# var wall_fill_color: Color = Color(1, 0, 0, 0.5)
@export var wall_outline_color: Color = Color(1, 1, 1, 0.65)
@export_range(1.0, 12.0, 0.5) var wall_outline_width: float = 2.0

@export var tile_size: Vector2i = Vector2i(48, 48)

var contour_epsilon: float = 0.0 # Always render exact edges


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
            bm.set_bitv(cell - layermap_rect.position, true)

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

    for x in layermap_rect.size.x:
        for y in layermap_rect.size.y:
            var map_cell := _bm_to_map(layermap_rect, x, y)
            var tile_data: TileData = layer.get_cell_tile_data(map_cell)
            if tile_data == null:
                continue

            var is_wall: bool = tile_data.get_custom_data(TileCustomData.IS_WALL)
            if is_wall:
                wall_bm.set_bit(x, y, true)

    # Scan top row of tiles for a wall tile
    var col_with_wall: int
    for col in layermap_rect.size.x:
        var map_cell := _bm_to_map(layermap_rect, 0, col)
        var tile_data: TileData = layer.get_cell_tile_data(map_cell)
        if tile_data == null:
            continue
        var is_wall: bool = tile_data.get_custom_data(TileCustomData.IS_WALL)
        if is_wall:
            col_with_wall = col
            break

    var outer_wall_bm := _floodfill_outer_wall(col_with_wall, 0, wall_bm, layermap_rect)

    # Loop over outer wall bm. Cross reference with TileMapLayer.
    # Any TML cell that's a wall but not in outer_wall_bm is an inner wall.

    var inner_walls_bm := BitMap.new()
    inner_walls_bm.create(layermap_rect.size)

    for x in layermap_rect.size.x:
        for y in layermap_rect.size.y:
            if wall_bm.get_bit(x, y) and not outer_wall_bm.get_bit(x, y):
                # It's a wall tile but not an outer wall.
                inner_walls_bm.set_bit(x, y, true)

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
        if x > 0:       stack.push_back(i - 1)
        if x < w - 1:   stack.push_back(i + 1)
        if y > 0:       stack.push_back(i - w)
        if y < h - 1:   stack.push_back(i + w)

    return outer_wall

func _bm_to_map(rect: Rect2i, x: int, y: int) -> Vector2i:
    return rect.position + Vector2i(x, y)

func _is_walkable_cell(layer: TileMapLayer, cell: Vector2i) -> bool:
    var td: TileData = layer.get_cell_tile_data(cell)
    if td == null:
        return false
    return td.has_custom_data(TileCustomData.WALKABLE) and bool(td.get_custom_data(TileCustomData.WALKABLE))

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

    # Convert bitmap coords -> world coords.
    # map_to_local() returns the CENTER of a cell.
    # Our bitmap polygons are on cell corners, so we shift by -half tile to get top-left corner.
    var origin_local: Vector2 = layer.map_to_local(rect.position) - (Vector2(tile_size) * 0.5)
    var origin_world: Vector2 = layer.to_global(origin_local)

    for poly_tile_units in polys:
        var pts := PackedVector2Array()
        pts.resize(poly_tile_units.size())

        for i in poly_tile_units.size():
            var v := poly_tile_units[i]
            pts[i] = origin_world + Vector2(v.x * tile_size.x, v.y * tile_size.y)

        var fill := Polygon2D.new()
        fill.polygon = pts
        fill.color = fill_color
        polys_root.add_child(fill)

        var line := Line2D.new()
        line.points = pts
        line.closed = true
        line.width = outline_width
        line.default_color = outline_color
        polys_root.add_child(line)
