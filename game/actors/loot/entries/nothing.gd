class_name LootEntryNothing
extends LootEntry


func _init() -> void:
    item_id = StringNames.EMPTY


func resolve(_rng: RandomNumberGenerator, _ctx: LootContext, _depth: int) -> Array[LootDrop]:
    return []
