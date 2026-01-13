class_name MinimapNavBake
extends SubViewport

@export var nav_root: Node
@export var bake_resolution: Vector2i = Vector2i(512, 512)
@export_range(0.0, 0.45, 0.01) var frame_padding: float = 0.08

var player_root: Player
var render_context: RenderContext
var per_frame_rebakes: Array[RendererBase] = []

@onready var bake_camera: Camera2D = %BakeCamera
@onready var polys_root: Node2D = %MapPolysRoot
@onready var renderers_root: Node = %Renderers


func _ready() -> void:
    print("Readying minimap? (%s)" % bake_resolution)
    # Make sure the SubViewport has a valid size.
    size = bake_resolution
    # Clear each time we render once (2D-friendly).
    render_target_clear_mode = SubViewport.CLEAR_MODE_ALWAYS
    # Start disabled until activated
    render_target_update_mode = SubViewport.UPDATE_DISABLED

    for node in renderers_root.get_children():
        var renderer := node as RendererBase
        if renderer == null:
            continue
        if renderer.rebake_cadence != RebakeCadence.EVERY_FRAME:
            continue
        per_frame_rebakes.append(renderer)

    _activate_if_possible()


func _process(_delta: float) -> void:
    for renderer in per_frame_rebakes:
        renderer.bake(render_context)


func configure(nav: Node, player: Player) -> void:
    nav_root = nav
    player_root = player

    _init_camera()
    _activate_if_possible()


func rebake() -> void:
    if nav_root == null:
        return
    # Call this when you regenerate the navmesh / swap sectors / etc.
    call_deferred("_bake_all_now")


func _activate_if_possible() -> void:
    if nav_root == null:
        return
    if player_root == null:
        return

    render_target_update_mode = SubViewport.UPDATE_WHEN_VISIBLE

    render_context = RenderContext.new(
        nav_root,
        polys_root,
    )

    rebake()


func _bake_all_now() -> void:
    for node in renderers_root.get_children():
        var renderer := node as RendererBase
        if renderer == null:
            push_warning("Got a renderer node that wasn't actually a renderer! %s" % node)
            continue
        renderer.bake(render_context)


func _init_camera() -> void:
    bake_camera.zoom = Vector2.ONE
    bake_camera.enabled = true
    bake_camera.make_current()
    bake_camera.set_target(player_root)
