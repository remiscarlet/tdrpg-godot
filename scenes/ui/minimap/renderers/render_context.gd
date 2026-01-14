class_name RenderContext
extends Resource

var nav_root: Node
var poly_containers_root: Node2D
var tilemap_layer: TileMapLayer


func _init(nav: Node, poly_containers: Node2D, layer: TileMapLayer) -> void:
    nav_root = nav
    poly_containers_root = poly_containers
    tilemap_layer = layer