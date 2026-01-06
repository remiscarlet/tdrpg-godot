extends Area2D
class_name LootableBase

@onready var sprite: Sprite2D = $Sprite2D

var drop: LootDrop

func configure(loot: LootDrop, origin: Vector2, direction: Vector2) -> void:
    drop = loot
    global_position = origin
    rotation = direction.normalized().angle()

func _ready() -> void:
    _configure_sprite()

func _configure_sprite() -> void:
    var def := DefinitionDB.get_item(drop.loot_id)
    sprite.texture = def.icon
