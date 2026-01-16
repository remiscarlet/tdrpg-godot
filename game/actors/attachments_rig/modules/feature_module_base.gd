class_name FeatureModuleBase
extends RefCounted


func id() -> StringName:
    return &"feature_module"


func stages() -> int:
    return 0


func is_applicable(_ctx: RigContext) -> bool:
    return false


# Return false if required nodes are missing / binding failed.
func install(_ctx: RigContext, _stage: int) -> bool:
    return true
