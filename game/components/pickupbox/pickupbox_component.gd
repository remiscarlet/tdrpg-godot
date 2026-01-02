extends Node2D
class_name PickupboxComponent

signal loot_encountered(loot: LootableBase)
@export var area: Area2D

func _ready() -> void:
    if area == null:
        # Common convention: child named "TargetSensorArea"
        area = get_node_or_null("PickupSensorArea") as Area2D
        assert(area != null, "Pickupbox needs an Area2D reference.")

    area.monitoring = true
    area.area_entered.connect(_on_area_entered)

func _on_area_entered(node: Node) -> void:
    var loot := node as LootableBase
    if loot == null:
        return

    loot_encountered.emit(loot)
