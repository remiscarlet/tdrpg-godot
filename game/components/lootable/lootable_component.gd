class_name LootableComponent
extends Node2D

signal loot_generated(ctx: LootableSpawnContext)

@export var loot_table: LootTable

var rng := RandomNumberGenerator.new()

@onready var health_component: HealthComponent = $"../HealthComponent"
@onready var root: Node = get_parent().get_parent() # AttachmentsRoot/LootableComponent


func _ready() -> void:
    health_component.died.connect(_on_HealthComponent_died)


func generate_loot(ctx: LootContext = null) -> Array[LootDrop]:
    if loot_table == null:
        push_error("No loot generated due to a null loot_table!")
        return []
    var drops := loot_table.roll(rng, ctx)
    return drops


func _on_HealthComponent_died(_source: Node) -> void:
    var ctx = LootableSpawnContext.new(root, global_position, generate_loot())
    loot_generated.emit(ctx)
