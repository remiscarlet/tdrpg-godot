class_name LootEntryTable
extends LootEntry

@export var table: LootTable


func resolve(rng: RandomNumberGenerator, ctx: LootContext, depth: int) -> Array[LootDrop]:
    if table == null:
        return []
    return table.roll(rng, ctx, depth)
