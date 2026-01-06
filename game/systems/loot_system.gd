class_name LootSystem
extends Node

@onready var level_container: LevelContainer = get_parent()
@onready var loot_container: Node2D = $LootContainer

var lootable_base_scene: PackedScene = preload("res://game/actors/loot/lootable_base.tscn")

func _ready() -> void:
    _connect_existing()
    get_tree().node_added.connect(_on_node_added)

func _connect_existing() -> void:
    for n in get_tree().get_nodes_in_group("loot_emitters"):
        _try_connect(n)

func _on_node_added(n: Node) -> void:
    _try_connect(n)

func _try_connect(n: Node) -> void:
    # You can group either the LootableComponent itself, or a parent that owns it.
    if n is LootableComponent:
        var c := Callable(self, "_on_loot_generated")
        if not n.loot_generated.is_connected(c):
            n.loot_generated.connect(c)

func _on_loot_generated(ctx: LootableSpawnContext) -> void:
    for loot in ctx.drops:
        if not loot.is_nothing():
            spawn(loot, ctx.origin, ctx.direction)

func spawn(loot: LootDrop, origin: Vector2, direction: Vector2) -> LootableBase:
    var node = lootable_base_scene.instantiate()

    var lootable := node as LootableBase
    if lootable == null:
        push_error("Lootable scene does not inherit LootableBase.")
        return null

    lootable.configure(loot, origin, direction)

    loot_container.add_child(lootable)
    if not lootable.is_node_ready():
        await lootable.ready

    print("Generated %s loot!" % loot.loot_id)
    return lootable
