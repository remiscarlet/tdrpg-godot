class_name ModuleHost
extends Node

enum Stage { PRE_TREE = 1, READY = 2, POST_READY = 4 }

@export var strict := true

var ctx := RigContext.new()
var _ran_stage := 0
var _modules: Array[FeatureModuleBase] = [
    DamageableCoreModule.new(),
    LootableWiringModule.new(),
    InventoryWiringModule.new(),
    AIHaulerWiringModule.new(),
    InteractableWiringModule.new(),
    AimFireWiringModule.new(),
    PlayerMouseAimingWiringModule.new(),
    MeleeAttackWiringModule.new(),
    RangedAttackWiringModule.new(),
    TurretAutofireWiringModule.new(),

    # PlayerInputBindingsModule.new(),
    # HaulerBindingsModule.new(),
    # SystemsBindingsModule.new(),
]


func _ready() -> void:
    # ctx may or may not already be configured; modules should handle nulls.
    if ctx.rig == null:
        var rig := get_parent() as AttachmentsRig
        ctx.rig = rig
        ctx.actor = rig.actor()
    _run(Stage.READY)


func configure_pre_tree(definition: DefinitionBase, team_id: int, spawn_ctx: RefCounted = null) -> void:
    var rig := get_parent() as AttachmentsRig
    ctx.rig = rig
    ctx.actor = rig.actor()
    ctx.definition = definition
    ctx.team_id = team_id
    ctx.spawn_context = spawn_ctx
    _run(Stage.PRE_TREE)


func configure_post_ready(level_container: Node) -> void:
    ctx.level_container = level_container
    _run(Stage.POST_READY)


func _run(stage: int) -> void:
    if (_ran_stage & stage) != 0:
        return
    _ran_stage |= stage

    for m in _modules:
        if (m.stages() & stage) == 0:
            continue
        if not m.is_applicable(ctx):
            continue
        var ok := m.install(ctx, stage)
        if strict and not ok:
            push_error("%s Module failed: %s" % [ctx.tag(), m.id()])
