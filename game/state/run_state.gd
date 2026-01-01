extends Resource
class_name RunState

## Run/session identity
@export var run_id: StringName = &""
@export var rng_seed: int = 0
@export var started_unix: float = 0.0

## Core currencies / generic resources
@export var credits: int = 0
@export var scrap: int = 0
@export var power_cells: int = 0

## Inventory: item_id -> quantity
## (StringName is cheap to compare and avoids a lot of string churn.)
@export var inventory: Dictionary = {} # Dictionary[StringName, int]

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

	credits = 0
	scrap = 0
	power_cells = 0

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
		Loot.CREDIT: return credits
		Loot.SCRAP: return scrap
		Loot.POWER_CELL: return power_cells
		_: return 0

func add_currency(currency_id: StringName, delta: int) -> void:
	if delta == 0:
		return

	match currency_id:
		Loot.CREDIT:
			credits = max(0, credits + delta)
			currency_changed.emit(currency_id, credits)
		Loot.SCRAP:
			scrap = max(0, scrap + delta)
			currency_changed.emit(currency_id, scrap)
		Loot.POWER_CELL:
			power_cells = max(0, power_cells + delta)
			currency_changed.emit(currency_id, power_cells)
		_:
			return

	state_changed.emit()


# ---------------------------
# Inventory helpers
# ---------------------------

func get_item_qty(item_id: StringName) -> int:
	return int(inventory.get(item_id, 0))

func add_item(item_id: StringName, delta: int) -> void:
	if delta == 0:
		return

	var current := get_item_qty(item_id)
	var next := current + delta

	if next <= 0:
		inventory.erase(item_id)
		next = 0
	else:
		inventory[item_id] = next

	inventory_changed.emit(item_id, next)
	state_changed.emit()

func has_item(item_id: StringName, qty: int = 1) -> bool:
	return get_item_qty(item_id) >= qty

func consume_item(item_id: StringName, qty: int = 1) -> bool:
	if qty <= 0:
		return true
	if not has_item(item_id, qty):
		return false
	add_item(item_id, -qty)
	return true