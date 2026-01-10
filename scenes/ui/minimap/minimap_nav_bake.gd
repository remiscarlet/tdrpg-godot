extends PanelContainer
class_name MinimapNavBake

@export var nav_root: Node
@export var bake_resolution: Vector2i = Vector2i(512, 512)
@export_range(0.0, 0.45, 0.01) var frame_padding: float = 0.08

@export var fill_color: Color = Color(1, 1, 1, 0.12)
@export var outline_color: Color = Color(1, 1, 1, 0.65)
@export_range(1.0, 12.0, 0.5) var outline_width: float = 2.0

@onready var base_map: TextureRect = $ClipControl/BaseMap
@onready var bake_viewport: SubViewport = $ClipControl/BakeViewport
@onready var bake_camera: Camera2D = $ClipControl/BakeViewport/BakeWorld/BakeCamera
@onready var polys_root: Node2D = $ClipControl/BakeViewport/BakeWorld/PolysRoot

var player_root: Player
# @onready var base_map: TextureRect = $BaseMap
# @onready var bake_viewport: SubViewport = $BakeViewport
# @onready var bake_camera: Camera2D = $BakeViewport/BakeWorld/BakeCamera
# @onready var polys_root: Node2D = $BakeViewport/BakeWorld/PolysRoot

var max_zoom_out: Vector2

func _enter_tree() -> void:
    set_physics_process(false)
    set_process(false)

func bind_nav_root(root: Node) -> void:
    nav_root = root

    _try_activate()

func bind_player_root(root: Player) -> void:
    player_root = root

    _try_activate()

func rebake() -> void:
    # Call this when you regenerate the navmesh / swap sectors / etc.
    call_deferred("_bake_now")

func _ready() -> void:
    print("Readying minimap?")
    # Make sure the SubViewport has a valid size.
    bake_viewport.size = bake_resolution
    # Clear each time we render once (2D-friendly).
    bake_viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ALWAYS
    bake_viewport.render_target_update_mode = SubViewport.UPDATE_WHEN_VISIBLE

    # Optional: make the TextureRect behave like a minimap background.
    base_map.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    base_map.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

    # Defer a tick so your LevelSystem has time to finish setup if needed.
    call_deferred("_bake_now")

func _bake_now() -> void:
    var regions := _collect_nav_regions(nav_root)
    if regions.is_empty():
        push_warning("MinimapNavBake: no NavigationRegion2D nodes found under navigation_root_path.")
        return

    _build_poly_nodes(regions)

    var world_rect := _compute_bounds_from_poly_nodes()
    if world_rect.size.x <= 0.001 or world_rect.size.y <= 0.001:
        push_warning("MinimapNavBake: computed empty bounds; nothing to frame.")
        return

    _frame_camera_to_rect(world_rect)

    # Wait at least one frame so the viewport actually renders.
    await get_tree().process_frame

    # ViewportTexture is acquired via Viewport.get_texture().
    base_map.texture = bake_viewport.get_texture()
    print("Baked?")

func _collect_nav_regions(root: Node) -> Array[NavigationRegion2D]:
    var out: Array[NavigationRegion2D] = []
    _collect_nav_regions_rec(root, out)
    return out

func _collect_nav_regions_rec(node: Node, out: Array[NavigationRegion2D]) -> void:
    if node is NavigationRegion2D:
        out.append(node)
    for c in node.get_children():
        _collect_nav_regions_rec(c, out)

func _clear_polys_root() -> void:
    for c in polys_root.get_children():
        c.queue_free()

func _build_poly_nodes(regions: Array[NavigationRegion2D]) -> void:
    _clear_polys_root()

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

func _compute_bounds_from_poly_nodes() -> Rect2:
    var min_v := Vector2(INF, INF)
    var max_v := Vector2(-INF, -INF)
    var found := false

    for c in polys_root.get_children():
        if c is Polygon2D:
            var pts := (c as Polygon2D).polygon
            for p in pts:
                found = true
                min_v.x = min(min_v.x, p.x)
                min_v.y = min(min_v.y, p.y)
                max_v.x = max(max_v.x, p.x)
                max_v.y = max(max_v.y, p.y)

    if not found:
        return Rect2()

    return Rect2(min_v, max_v - min_v)

func _frame_camera_to_rect(rect: Rect2) -> void:
    # Camera2D.zoom: higher values zoom in; lower values zoom out.
    var vp := Vector2(bake_viewport.size)
    var size := rect.size

    # Avoid division by zero.
    size.x = max(size.x, 0.001)
    size.y = max(size.y, 0.001)

    # We want visible_area >= rect. Since visible_area ≈ vp / zoom, choose zoom <= vp / rect.
    var zoom_fit: float = min(vp.x / size.x, vp.y / size.y)
    zoom_fit *= (1.0 - frame_padding)

    # Clamp to something sane.
    zoom_fit = clamp(zoom_fit, 0.001, 1000.0)
    max_zoom_out = Vector2(zoom_fit, zoom_fit)

    bake_camera.position = rect.position + rect.size * 0.5
    bake_camera.zoom = Vector2.ONE
    bake_camera.enabled = true
    bake_camera.make_current()
    bake_camera.set_target(player_root)

func _try_activate() -> void:
    if player_root == null:
        return
    if nav_root == null:
        return

    set_physics_process(true)
    set_process(true)
