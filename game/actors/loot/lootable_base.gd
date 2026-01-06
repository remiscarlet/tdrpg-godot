extends Area2D
class_name LootableBase

@onready var sprite: Sprite2D = $Sprite2D

var drop: LootDrop

## Returns a "positionless" instance of LootableBase configured as `item_id`
static func instantiate_by_id(item_id: StringName) -> LootableBase:
    var lootable = load("res://game/actors/loot/lootable_base.tscn").instantiate()
    lootable.configure(LootDrop.new(item_id), Vector2.ZERO, Vector2.ZERO)
    return lootable

func configure(loot: LootDrop, origin: Vector2, direction: Vector2) -> void:
    drop = loot
    global_position = origin
    rotation = direction.normalized().angle()

func _ready() -> void:
    _configure_sprite()

func _configure_sprite() -> void:
    var def := DefinitionDB.get_item(drop.loot_id)
    sprite.texture = def.icon
