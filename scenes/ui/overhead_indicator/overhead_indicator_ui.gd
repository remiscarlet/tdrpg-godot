extends Control

@export var attach_frac: Vector2 = Vector2(0.5, 1.0) # (0.5,1.0) == bottom-center

var health_component: HealthComponent
var inventory_component: InventoryComponent
var _attach_screen_pos: Vector2

@onready var health_bar: HealthBarUI = %HealthBar
@onready var inventory_bar: InventoryBarUI = %InventoryBar


# Lifecycle Methods
func _ready() -> void:
    health_component.health_changed.connect(health_bar.on_HealthComponent_health_changed)
    health_bar.on_HealthComponent_health_changed(
        health_component.current_health,
        health_component.max_health,
    )

    if inventory_component:
        inventory_bar.bind_inventory_component(inventory_component)
        inventory_component.inventory_changed.connect(
            inventory_bar.on_InventoryComponent_inventory_changed,
        )


# Public Methods
func bind_health_component(component: HealthComponent) -> void:
    health_component = component


func bind_inventory_component(component: InventoryComponent) -> void:
    inventory_component = component


func set_attach_screen_pos(p: Vector2) -> void:
    _attach_screen_pos = p
    _reposition()


# Helpers
func _reposition() -> void:
    # size can be (0,0) very early; minimum size is a decent fallback for UI.
    var s := size
    if s == Vector2.ZERO:
        s = get_combined_minimum_size()

    # Place so attach point hits the anchor.
    global_position = _attach_screen_pos - Vector2(s.x * attach_frac.x, s.y * attach_frac.y)
