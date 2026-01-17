class_name Minimap
extends PanelContainer

# TODO: Eventually, zooming will show different BakeTextures/unit icons (a la Factorio zoom)
@export var min_zoom: float = 0.15
@export var max_zoom: float = 2.0
@export var default_zoom: float = 1.0

var zoom_in_mod: float = 1.05
var zoom_out_mod: float = 0.95
var max_zoom_out: Vector2
var player_root: Player
var nav_root: Node
var tilemap_layer: TileMapLayer

@onready var map_texture: TextureRect = %MapTexture
@onready var bake_viewport: MinimapNavBake = %BakeViewport
@onready var bake_camera: Camera2D = %BakeCamera
@onready var zoom_label: Label = %ZoomLabel


func _ready() -> void:
    _apply_bake_to_map_texture()
    _push_config()

    zoom_reset()


func zoom_in() -> bool:
    var new_zoom = clamp(_get_zoom() * zoom_in_mod, min_zoom, max_zoom)
    return _set_zoom(new_zoom)


func zoom_out() -> bool:
    var new_zoom = clamp(_get_zoom() * zoom_out_mod, min_zoom, max_zoom)
    return _set_zoom(new_zoom)


func zoom_reset() -> bool:
    return _set_zoom(default_zoom)


func bind_nav_root(root: Node) -> void:
    nav_root = root
    _push_config()


func bind_player_root(root: Player) -> void:
    player_root = root
    _push_config()


func bind_tilemap_layer(layer: TileMapLayer) -> void:
    tilemap_layer = layer
    _push_config()


func _get_zoom() -> float:
    return bake_camera.zoom.x


func _set_zoom(zoom: float) -> bool:
    bake_camera.zoom = Vector2(zoom, zoom)
    zoom_label.text = "x%.2f" % zoom
    return true


func _apply_bake_to_map_texture() -> void:
    # ViewportTexture is acquired via Viewport.get_texture().
    map_texture.texture = bake_viewport.get_texture()


func _push_config() -> void:
    if player_root == null:
        return
    if nav_root == null:
        return
    if tilemap_layer == null:
        return

    if not is_node_ready():
        return

    bake_viewport.configure(nav_root, player_root, tilemap_layer)
