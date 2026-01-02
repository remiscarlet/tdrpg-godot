extends Resource
class_name RunState

## Run/session identity
@export var run_id: StringName = &""
@export var rng_seed: int = 0
@export var started_unix: float = 0.0

## Inventory
@export var inventory: Inventory = Inventory.new(1000)

## Run flags: arbitrary booleans keyed by id (tutorial steps, one-time events, etc.)
@export var flags: Dictionary = {} # Dictionary[StringName, bool]

## Discovered/cleared content across maps
## e.g. sector_id -> "discovered"/"cleared"/etc (you can evolve this later)
@export var sectors: Dictionary = {} # Dictionary[StringName, Dictionary]

## Persisted “hub” state across levels
## hub_id -> hub data (minimal starter shape)
@export var hubs: Dictionary = {} # Dictionary[StringName, Dictionary]


# ---------------------------
# Convenience API
# ---------------------------

signal state_changed
signal currency_changed(currency_id: StringName, new_value: int)
signal inventory_changed(item_id: StringName, new_qty: int)

func reset_for_new_run(new_run_id: StringName, new_seed: int) -> void:
    run_id = new_run_id
    rng_seed = new_seed
    started_unix = Time.get_unix_time_from_system()

    inventory.clear()
    flags.clear()
    sectors.clear()
    hubs.clear()

    state_changed.emit()


# ---------------------------
# Currency helpers
# ---------------------------

func get_currency(currency_id: StringName) -> int:
    match currency_id:
        Loot.CREDIT: return get_item_qty(Loot.CREDIT)
        Loot.SCRAP: return get_item_qty(Loot.SCRAP)
        Loot.POWER_CELL: return get_item_qty(Loot.POWER_CELL)
        _: return 0

func add_currency(currency_id: StringName, delta: int) -> void:
    if delta == 0:
        return

    match currency_id:
        Loot.CREDIT:
            if add_item(Loot.CREDIT, delta):
                currency_changed.emit(currency_id, get_item_qty(Loot.CREDIT))
        Loot.SCRAP:
            if add_item(Loot.SCRAP, delta):
                currency_changed.emit(currency_id, get_item_qty(Loot.SCRAP))
        Loot.POWER_CELL:
            if add_item(Loot.POWER_CELL, delta):
                currency_changed.emit(currency_id, get_item_qty(Loot.POWER_CELL))
        _:
            return

    state_changed.emit()


# ---------------------------
# Inventory helpers
# ---------------------------

func get_item_qty(item_id: StringName) -> int:
    return int(inventory.get_item_qty_or_default(item_id, 0))

func has_item(item_id: StringName, qty: int = 1) -> bool:
    return get_item_qty(item_id) >= qty

func add_item(item_id: StringName, delta: int) -> bool:
    if not inventory.add_item(item_id, delta):
        push_error("Failed to add item to RunState! (item: %s)(qty: %d)" % [item_id, delta])
        return false

    inventory_changed.emit(item_id, get_item_qty(item_id))
    state_changed.emit()
    return true

func consume_item(item_id: StringName, delta: int = 1) -> bool:
    if not inventory.remove_item(item_id, delta):
        push_error("Failed to remove item from RunState! (item: %s)(qty: %d)" % [item_id, delta])
        return false

    inventory_changed.emit(item_id, get_item_qty(item_id))
    state_changed.emit()
    return true
