extends RendererBase
class_name IconRenderer

func _init() -> void:
    rebake_cadence = RebakeCadence.EVERY_FRAME

func bake(ctx: RenderContext) -> void:
    var icon_polys_root := ctx.poly_containers_root.get_node("%IconPolysRoot")
    _bake_combatants(icon_polys_root)
    _bake_

func _bake_combatants(polys_root: Node2D) -> void:
    _clear_polys_root(polys_root)

    for node in get_tree().get_nodes_in_group(Groups.COMBATANTS):
        var combatant := node as CombatantBase
        if combatant == null:
            push_warning("Found a node with 'Combatants' group that doesn't extend CombatantBase! %s" % node)
            continue

        var scene := combatant.definition.minimap_icon_scene
        if scene == null:
            continue

        var icon_node: Node = scene.instantiate()
        var icon := icon_node as MinimapIconBase
        if icon == null:
            push_error("Got an icon scene that doesn't inherit MinimapIconBase! %s" % icon_node)
            continue

        icon.configure(combatant)

        polys_root.add_child(icon)
