extends LootEntryBase
class_name LootEntryTable

@export var table: LootTable

func resolve(rng: RandomNumberGenerator, ctx: LootContext, depth: int) -> Array[LootDrop]:
	if table == null:
		return []
	return table.roll(rng, ctx, depth)