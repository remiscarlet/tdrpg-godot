extends Control
class_name RunHUD

@export var resource_row_scene: PackedScene
@onready var resource_list: VBoxContainer = %ResourceList

var run_state: RunState
var rows: Dictionary[StringName, Node] = {}

func bind_run_state(rs: RunState) -> void:
    # Unbind old
    if run_state and run_state.inventory_changed.is_connected(_on_inventory_changed):
        run_state.inventory_changed.disconnect(_on_inventory_changed)

    run_state = rs
    rows.clear()
    for child in resource_list.get_children():
        if not child.is_in_group("persistent_ui"):
            child.queue_free()

    if not run_state:
        return

    # Bind new
    run_state.inventory_changed.connect(_on_inventory_changed)

    # Initial population (whatever exists already)
    for id in run_state.inventory.list_item_ids():
        _ensure_row(id)
        _update_row(id, run_state.get_resource(id))

func _on_inventory_changed(id: StringName, new_value: int) -> void:
    _ensure_row(id)
    _update_row(id, new_value)

func _ensure_row(id: StringName) -> void:
    if id in rows:
        return
    var row := resource_row_scene.instantiate()
    resource_list.add_child(row)
    rows[id] = row
    # Assumes row has %Name and %Value labels (recommended)
    row.get_node("%Name").text = String(id)

func _update_row(id: StringName, value: int) -> void:
    var row = rows[id]
    row.get_node("%Value").text = str(value)
