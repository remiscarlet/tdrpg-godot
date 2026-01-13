extends Node2D
class_name LootableComponent

signal loot_generated(ctx: LootableSpawnContext)

@export var loot_table: LootTable
@onready var health_component: HealthComponent = $"../HealthComponent"
@onready var root: Node = get_parent().get_parent()  # AttachmentsRoot/LootableComponent

var loot_system: LootSystem
var rng := RandomNumberGenerator.new()


func _ready() -> void:
    health_component.died.connect(_on_HealthComponent_died)


func _on_HealthComponent_died(_source: Node) -> void:
    var ctx = LootableSpawnContext.new(root, global_position, generate_loot())
    loot_generated.emit(ctx)


func generate_loot(ctx: LootContext = null) -> Array[LootDrop]:
    if loot_table == null:
        push_error("No loot generated due to a null loot_table!")
        return []
    var drops := loot_table.roll(rng, ctx)
    return drops


func bind_loot_system(system: LootSystem) -> void:
    loot_system = system
