class_name TestUtils
extends RefCounted
## Purpose: Shared test utilities for GdUnit engine-bound suites.


static func await_physics_frames(tree: SceneTree, count: int = 1) -> void:
    for _i in range(max(1, count)):
        await tree.physics_frame


static func make_scene_root(tree: SceneTree, make_current: bool = true) -> Node:
    var root := Node.new()
    tree.root.add_child(root)
    if make_current:
        tree.current_scene = root
    return root


static func add_child_and_await_ready(parent: Node, child: Node) -> Node:
    parent.add_child(child)
    if not child.is_node_ready():
        await child.ready
    return child


static func seed_rng(seed: int) -> RandomNumberGenerator:
    var rng := RandomNumberGenerator.new()
    rng.seed = seed
    return rng


static func with_autoload_stub(tree: SceneTree, name: String, stub: Node, fn: Callable) -> Variant:
    var root := tree.root
    var existing := root.get_node_or_null(name)
    var existing_parent := existing.get_parent() if existing != null else null
    var existing_name := existing.name if existing != null else ""

    if existing_parent != null:
        existing_parent.remove_child(existing)

    if stub.get_parent() != null:
        stub.get_parent().remove_child(stub)
    stub.name = name
    root.add_child(stub)

    var result := fn.call()
    if result is GDScriptFunctionState or result is Signal:
        result = await result

    root.remove_child(stub)
    stub.queue_free()

    if existing_parent != null:
        existing.name = existing_name
        existing_parent.add_child(existing)

    return result


static func make_nav_map_2d(set_active: bool = true) -> RID:
    var map := NavigationServer2D.map_create()
    if set_active:
        NavigationServer2D.map_set_active(map, true)
    return map


static func free_nav_map_2d(map: RID) -> void:
    if map == RID():
        return
    if ClassDB.class_has_method("NavigationServer2D", "free_rid"):
        NavigationServer2D.free_rid(map)
