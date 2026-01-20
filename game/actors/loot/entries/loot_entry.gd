class_name LootEntry
extends Resource

@export var item_id: StringName
@export var qty_min: int = 1
@export var qty_max: int = 1
@export var weight: float = 1.0
@export var required_tags: PackedStringArray = PackedStringArray()


func is_eligible(ctx: LootContext) -> bool:
    if required_tags.is_empty():
        return true
    if ctx == null:
        return false
    for t in required_tags:
        if not ctx.has_tag(t):
            return false
    return true


func resolve(rng: RandomNumberGenerator, _ctx: LootContext, _depth: int) -> Array[LootDrop]:
    if item_id == StringNames.EMPTY:
        print("Resolving empty due to empty item_id")
        return []
    var q := rng.randi_range(qty_min, qty_max)
    return [LootDrop.new(item_id, q)]
