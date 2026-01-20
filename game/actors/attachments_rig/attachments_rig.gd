class_name AttachmentsRig
extends Node2D
## Purpose: Actor rig exposing roots and module host for wiring.

# Cached slot roots (available pre-tree)
var _components_root: Node
var _controllers_root: Node
var _facing_root: Node
var _misc_root: Node
var _views_root: Node
var _module_host: ModuleHost
var _cached := false


func _notification(what: int) -> void:
    if what == NOTIFICATION_SCENE_INSTANTIATED:
        _ensure_cached()


func actor() -> Node2D:
    return get_parent() as Node2D


# --- Slot getters (safe in PRE_TREE) ---
func components_root() -> Node:
    _ensure_cached()
    return _components_root


func controllers_root() -> Node:
    _ensure_cached()
    return _controllers_root


func facing_root() -> Node:
    _ensure_cached()
    return _facing_root


func misc_root() -> Node:
    _ensure_cached()
    return _misc_root


func views_root() -> Node:
    _ensure_cached()
    return _views_root


func module_host() -> ModuleHost:
    _ensure_cached()
    return _module_host


# --- Optional helpers (return null if absent) ---
# Roots
func sensors_root() -> Node:
    var fr := facing_root()
    return fr.get_node_or_null("Sensors") if fr != null else null


# Components
func health() -> HealthComponent:
    var cr := components_root()
    return cr.get_node_or_null("HealthComponent") as HealthComponent if cr != null else null


func inventory() -> InventoryComponent:
    var cr := components_root()
    return cr.get_node_or_null("InventoryComponent") as InventoryComponent if cr != null else null


func lootable() -> LootableComponent:
    var cr := components_root()
    return cr.get_node_or_null("LootableComponent") as LootableComponent if cr != null else null


func fire_weapon() -> FireWeaponComponent:
    var cr := components_root()
    return cr.get_node_or_null("FireWeaponComponent") as FireWeaponComponent if cr != null else null


func aim_to_target() -> AimToTarget2DComponent:
    var cr := components_root()
    return cr.get_node_or_null("AimToTarget2DComponent") as AimToTarget2DComponent if cr != null else null


func melee_attack() -> MeleeAttackComponent:
    var cr := components_root()
    return cr.get_node_or_null("MeleeAttackComponent") as MeleeAttackComponent if cr != null else null


# Controllers
func player_input() -> PlayerInputController:
    var ctr := controllers_root()
    return ctr.get_node_or_null("PlayerInputController") as PlayerInputController if ctr != null else null


func aim_fire_controller() -> AimFireController:
    var ctr := controllers_root()
    return ctr.get_node_or_null("AimFireController") as AimFireController if ctr != null else null


func hauler_ai() -> AIHaulerController:
    var ctr := controllers_root()
    return ctr.get_node_or_null("AIHaulerController") as AIHaulerController if ctr != null else null


# Sensor Components
func interactable_detector() -> InteractableDetectorComponent:
    var sr := sensors_root()
    return sr.get_node_or_null("InteractableDetectorComponent") as InteractableDetectorComponent if sr != null else null


func hurtbox() -> Hurtbox2DComponent:
    var sr := sensors_root()
    return sr.get_node_or_null("Hurtbox2DComponent") as Hurtbox2DComponent if sr != null else null


func pickupbox() -> PickupboxComponent:
    var sr := sensors_root()
    return sr.get_node_or_null("PickupboxComponent") as PickupboxComponent if sr != null else null


func target_sensor() -> TargetSensor2DComponent:
    var sr := sensors_root()
    return sr.get_node_or_null("TargetSensor2DComponent") as TargetSensor2DComponent if sr != null else null


func sword() -> BasicSword:
    var sr := sensors_root()
    return sr.get_node_or_null("BasicSword") as BasicSword if sr != null else null


# Misc
func shot_delay_timer() -> Timer:
    var mr := misc_root()
    return mr.get_node_or_null("ShotDelayTimer") as Timer if mr != null else null


func _ensure_cached() -> void:
    if _cached:
        return
    _cached = true

    # Use plain names inside the rig scene (no barrier issue here).
    _components_root = get_node_or_null("ComponentsRoot")
    _controllers_root = get_node_or_null("ControllersRoot")
    _facing_root = get_node_or_null("FacingRoot")
    _misc_root = get_node_or_null("MiscRoot")
    _views_root = get_node_or_null("ViewsRoot")
    _module_host = get_node_or_null("ModuleHost") as ModuleHost
