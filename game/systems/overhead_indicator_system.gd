class_name OverheadIndicatorSystem
extends Node

@export var indicator_scene: PackedScene
@export var anchor_rel_path: NodePath = NodePath("AttachmentsRig/ViewsRoot/OverheadIndicatorAnchor")

# Map combatant -> indicator
var _indicators := { } # Dictionary[Node, Control]

@onready var indicators_root: Control = %"IndicatorsRoot"


func _ready() -> void:
    # Handle existing combatants.
    for c in get_tree().get_nodes_in_group(Groups.COMBATANTS):
        _register_combatant(c)

    # Handle future spawns/despawns.
    get_tree().node_added.connect(_on_node_added)
    get_tree().node_removed.connect(_on_node_removed)


func _process(_dt: float) -> void:
    for combatant in _indicators.keys():
        if not is_instance_valid(combatant):
            continue

        var indicator := _indicators[combatant] as Control
        var anchor := combatant.get_node_or_null(anchor_rel_path) as Node2D
        if anchor == null:
            indicator.visible = false
            continue

        indicator.visible = true

        # World anchor -> viewport coordinates (screen space).
        # This works because Node2D/Marker2D are CanvasItems.
        var screen_pos := anchor.get_global_transform_with_canvas().origin
        indicator.set_attach_screen_pos(screen_pos)


func _on_node_added(node: Node) -> void:
    # Groups are sometimes assigned in the node's _ready, so defer one tick.
    call_deferred("_maybe_register", node)


func _maybe_register(node: Node) -> void:
    if is_instance_valid(node) and node.is_in_group(Groups.COMBATANTS):
        _register_combatant(node)


func _on_node_removed(node: Node) -> void:
    _unregister_combatant(node)


func _register_combatant(combatant: Node) -> void:
    if _indicators.has(combatant):
        return
    if indicator_scene == null:
        return

    var indicator := indicator_scene.instantiate() as Control
    if indicator == null:
        return

    var rig = combatant.get_node("AttachmentsRig")
    var health_component := rig.get_node("%ComponentsRoot/HealthComponent")
    indicator.bind_health_component(health_component)

    var inventory_component := rig.get_node("%ComponentsRoot/InventoryComponent")
    indicator.bind_inventory_component(inventory_component)

    indicators_root.add_child(indicator)
    _indicators[combatant] = indicator


func _unregister_combatant(combatant: Node) -> void:
    if not _indicators.has(combatant):
        return
    var indicator := _indicators[combatant] as Control
    _indicators.erase(combatant)

    if is_instance_valid(indicator):
        indicator.queue_free()
