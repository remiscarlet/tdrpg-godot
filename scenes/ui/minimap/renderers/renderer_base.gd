class_name RendererBase
extends Node

## Purpose: Base class for Renderer.
var rebake_cadence: int = RebakeCadence.ON_INIT


func bake(_ctx: RenderContext) -> void:
    pass


func _clear_polys_root(polys_root: Node2D) -> void:
    for c in polys_root.get_children():
        c.queue_free()
