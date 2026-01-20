class_name RigContext
extends RefCounted

## Purpose: Context data passed to feature modules during rig setup.
var actor: Node2D # e.g., CombatantBase, DefaultTurret, Door, etc.
var rig: AttachmentsRig
var definition: DefinitionBase # or null
var team_id: int = -1
var spawn_context: RefCounted # optional
var level_container: LevelContainer # optional (your LevelContainer type)


func tag() -> String:
    var a: StringName = actor.name if actor else StringNames.UNKNOWN
    var d := definition.id if definition and "id" in definition else StringNames.NO_DEF
    return "[%s|%s]" % [a, d]
