class_name MapRendererTilebake
extends RendererBase

@export var fill_color: Color = Color(1, 1, 1, 0.12)
@export var outline_color: Color = Color(1, 1, 1, 0.65)
@export_range(1.0, 12.0, 0.5) var outline_width: float = 2.0
@export var tile_size: Vector2i = Vector2i(48, 48)
@export var walkable_key: StringName = &"walkable"

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

    var used_rect: Rect2i = layer.get_used_rect()
    print("used_rect: %s" % used_rect)
    if used_rect.size == Vector2i.ZERO:
        return

    var bm := BitMap.new()
    bm.create(used_rect.size)

    for cell in layer.get_used_cells():
        if _is_walkable_cell(layer, cell):
            bm.set_bitv(cell - used_rect.position, true)

    var polys: Array[PackedVector2Array] = bm.opaque_to_polygons(
        Rect2i(Vector2i.ZERO, used_rect.size),
        contour_epsilon,
    )

    # Convert bitmap coords -> world coords.
    # map_to_local() returns the CENTER of a cell.
    # Our bitmap polygons are on cell corners, so we shift by -half tile to get top-left corner.
    var origin_local: Vector2 = layer.map_to_local(used_rect.position) - (Vector2(tile_size) * 0.5)
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


func _is_walkable_cell(layer: TileMapLayer, cell: Vector2i) -> bool:
    var td: TileData = layer.get_cell_tile_data(cell)
    if td == null:
        return false
    # You can invert this logic depending on how your tiles are authored.
    return td.has_custom_data(walkable_key) and bool(td.get_custom_data(walkable_key))
