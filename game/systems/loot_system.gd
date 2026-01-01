class_name LootSystem
extends Node

@onready var level_container: LevelContainer = get_parent()
@onready var loot_container: Node2D = $LootContainer

class LootConfig:
    var scene: PackedScene

    func _init(
        c_scene: PackedScene,
    ):
        scene = c_scene

var mapping: Dictionary[StringName, LootConfig] = {
    Loot.CREDIT: LootConfig.new(preload("res://scenes/objects/loot/credit/credit.tscn")),
    Loot.SCRAP: LootConfig.new(preload("res://scenes/objects/loot/scrap/scrap.tscn")),
    Loot.POWER_CELL: LootConfig.new(preload("res://scenes/objects/loot/power_cell/power_cell.tscn")),
}

func _get_loot_config(type: StringName) -> LootConfig:
    if not mapping.has(type):
        push_error("Tried getting a CombatantConfig for an unknown CombatantTypes! Got: %s" % type)
    return mapping.get(type)

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
    print("SPAWNING: %s at %s facing %s" % [loot.item_id, origin, direction])

    assert(loot.scene != null)

    var node := loot.scene.instantiate()

    var lootable := node as LootableBase
    if lootable == null:
        push_error("Lootable scene does not inherit LootableBase.")
        return null

    lootable.global_position = origin
    lootable.rotation = direction.normalized().angle()

    loot_container.add_child(lootable)
    if not lootable.is_node_ready():
        await lootable.ready

    print("Generated %s loot!" % loot.item_id)
    return lootable
