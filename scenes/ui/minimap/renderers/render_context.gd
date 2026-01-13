extends Resource
class_name RenderContext

var nav_root: Node
var poly_containers_root: Node2D

func _init(nav: Node, poly_containers: Node2D) -> void:
    nav_root = nav
    poly_containers_root = poly_containers
