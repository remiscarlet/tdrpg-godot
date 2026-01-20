class_name MapRenderer
extends RendererBase

## Purpose: Scene script for the minimap navpoly renderer.
@export var fill_color: Color = Color(1, 1, 1, 0.12)
@export var outline_color: Color = Color(1, 1, 1, 0.65)
@export_range(1.0, 12.0, 0.5) var outline_width: float = 2.0


func bake(ctx: RenderContext) -> void:
    print("Baking minimap map")
    var regions := _collect_nav_regions(ctx.nav_root)
    if regions.is_empty():
        push_warning(
            "MinimapNavBake: no NavigationRegion2D nodes found under navigation_root_path.",
        )
        return

    var map_polys_root := ctx.poly_containers_root.get_node("%MapPolysRoot")
    _build_poly_nodes(regions, map_polys_root)


func _collect_nav_regions(root: Node) -> Array[NavigationRegion2D]:
    var out: Array[NavigationRegion2D] = []
    _collect_nav_regions_rec(root, out)
    return out


func _collect_nav_regions_rec(node: Node, out: Array[NavigationRegion2D]) -> void:
    if node is NavigationRegion2D:
        out.append(node)
    for c in node.get_children():
        _collect_nav_regions_rec(c, out)


func _build_poly_nodes(regions: Array[NavigationRegion2D], polys_root: Node2D) -> void:
    _clear_polys_root(polys_root)

    for region in regions:
        var nav_poly: NavigationPolygon = region.navigation_polygon
        if nav_poly == null:
            continue

        # Outlines are editor/script-created boundaries; use them for your low-fidelity map.
        var verts: PackedVector2Array = nav_poly.get_vertices()
        for i in nav_poly.get_polygon_count():
            var idxs: PackedInt32Array = nav_poly.get_polygon(i)
            var pts := PackedVector2Array()
            pts.resize(idxs.size())

            for j in idxs.size():
                var v_local: Vector2 = verts[idxs[j]]
                # verts are in the region's local space; convert to global if your BakeWorld expects globals
                pts[j] = region.to_global(v_local)

            # Filled shape
            var poly := Polygon2D.new()
            poly.polygon = pts
            poly.color = fill_color
            polys_root.add_child(poly)

            # Outline stroke
            var line := Line2D.new()
            line.points = pts
            line.closed = true
            line.width = outline_width
            line.default_color = outline_color
            polys_root.add_child(line)
