class_name FeatureModuleBase
extends RefCounted


func id() -> StringName:
    return &"feature_module"


func stages() -> int:
    return 0


func is_applicable(_ctx: RigContext) -> bool:
    return false


func install(ctx: RigContext, stage: int) -> bool:
    print("Installing %s during stage %d with ctx: %s" % [id(), stage, ctx])
    match stage:
        ModuleHost.Stage.PRE_TREE:
            return _install_pre_tree(ctx)
        ModuleHost.Stage.READY:
            return _install_ready(ctx)
        ModuleHost.Stage.POST_READY:
            return _install_post_ready(ctx)
        _:
            return true


func _install_pre_tree(_ctx: RigContext) -> bool:
    return true


func _install_ready(_ctx: RigContext) -> bool:
    return true


func _install_post_ready(_ctx: RigContext) -> bool:
    return true
