class_name LootTable
extends Resource

const MAX_NESTING_DEPTH := 16

@export var rolls_min: int = 1
@export var rolls_max: int = 1
@export var entries: Array[LootEntry] = []


func roll(rng: RandomNumberGenerator, ctx: LootContext = null, depth: int = 0) -> Array[LootDrop]:
    if depth > MAX_NESTING_DEPTH:
        push_warning("LootTable nesting exceeded MAX_NESTING_DEPTH. Possible cycle?")
        return []

    if entries.is_empty():
        print("LootTable had no entries! No loot generated.")
        return []

    var rolls := rng.randi_range(rolls_min, rolls_max)
    var out: Array[LootDrop] = []

    for _i in range(rolls):
        out.append_array(_roll_once(rng, ctx, depth))

    return out


func _roll_once(rng: RandomNumberGenerator, ctx: LootContext, depth: int) -> Array[LootDrop]:
    # Filter eligible entries and compute total weight
    var eligible: Array[LootEntry] = []
    var total_weight := 0.0

    for e in entries:
        if e == null:
            # print("Null entry - skipping")
            continue
        if e.weight <= 0.0:
            # print("Invalid weight! Skipping")
            continue
        if not e.is_eligible(ctx):
            # print("Skipping %s due to ineligibility", e)
            continue
        eligible.append(e)
        total_weight += e.weight

    if eligible.is_empty() or total_weight <= 0.0:
        print("Returning empty due to no eligible loot or invalid total weight")
        return []

    # Weighted pick
    var r := rng.randf() * total_weight
    var acc := 0.0

    for e in eligible:
        acc += e.weight
        if r <= acc:
            return e.resolve(rng, ctx, depth + 1)

    # Fallback (floating point edge case)
    return eligible.back().resolve(rng, ctx, depth + 1)
