extends Resource
class_name MetaState

@export var started_unix: float = 0.0

## Upgrade currencies / generic resources
@export var mystery_item: int = 0

## Run flags: arbitrary booleans keyed by id (tutorial steps, one-time events, etc.)
@export var flags: Dictionary = {} # Dictionary[StringName, bool]


# ---------------------------
# Convenience API
# ---------------------------

signal meta_state_changed
signal meta_currency_changed(currency_id: StringName, new_value: int)

func _init() -> void:
    started_unix = Time.get_unix_time_from_system()

    mystery_item = 0

    flags.clear()

    meta_state_changed.emit()


# ---------------------------
# Currency helpers
# ---------------------------

func get_currency(currency_id: StringName) -> int:
    match currency_id:
        &"mystery_item": return mystery_item
        _: return 0

func add_currency(currency_id: StringName, delta: int) -> void:
    if delta == 0:
        return

    match currency_id:
        &"mystery_item":
            mystery_item = max(0, mystery_item + delta)
            meta_currency_changed.emit(currency_id, mystery_item)
        _:
            return

    meta_state_changed.emit()
