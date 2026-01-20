class_name IconRenderer
extends RendererBase


## Purpose: Scene script for the minimap icon renderer.
func _init() -> void:
    rebake_cadence = RebakeCadence.EVERY_FRAME


func bake(ctx: RenderContext) -> void:
    var icon_polys_root := ctx.poly_containers_root.get_node("%IconPolysRoot")
    _clear_polys_root(icon_polys_root)

    _bake_by_group(icon_polys_root, Groups.COMBATANTS)
    _bake_by_group(icon_polys_root, Groups.LOOT)
    # _bake_by_group(icon_polys_root, Groups.INTERACTABLES)


func _bake_by_group(polys_root: Node2D, group: StringName) -> void:
    for node in get_tree().get_nodes_in_group(group):
        if "definition" not in node:
            push_warning("Found a node with no definition property! %s" % node)
            continue

        var scene: PackedScene = node.definition.minimap_icon_scene
        if scene == null:
            continue

        var icon_node: Node = scene.instantiate()
        var icon := icon_node as MinimapIconBase
        if icon == null:
            push_error("Got an icon scene that doesn't inherit MinimapIconBase! %s" % icon_node)
            continue

        icon.configure(node.global_position, node.definition.minimap_icon_color)

        polys_root.add_child(icon)
