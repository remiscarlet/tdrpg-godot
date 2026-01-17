class_name CombatantAiContext
extends RefCounted

var actor: Node2D
# Optional providers (duck typing):
var slot_provider: Node # expects get_assigned_slot_world_position()
var directive_provider: Node # expects has_active_directive() / get_active_directive()


func has_slot() -> bool:
    return slot_provider != null and slot_provider.has_method("get_assigned_slot_world_position")


func slot_world_pos() -> Vector2:
    return slot_provider.get_assigned_slot_world_position()


func has_directive() -> bool:
    if directive_provider == null:
        return false
    if directive_provider.has_method("has_active_directive"):
        return directive_provider.has_active_directive()
    return directive_provider.has_method("get_active_directive") and directive_provider.get_active_directive() != null
