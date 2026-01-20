extends GdUnitTestSuite
## Purpose: Validates hauler task selection and claim expiry handling.

# Testee: res://game/systems/hauler_task_system.gd
# Scope: unit
# Tags: hauling, systems
const HaulerTaskSystem = preload("res://game/systems/hauler_task_system.gd")
const HaulTask = preload("res://game/utils/haul_task.gd")
const Groups = preload("res://game/utils/constants/groups.gd")


## Picks the nearest loot/collector pair and claims a haul task for the requester.
func test_request_task_claims_best_available() -> void:
    var system: HaulerTaskSystem = auto_free(HaulerTaskSystem.new())
    add_child(system)

    var loot_far := _make_node(Vector2(1000, 0), Groups.LOOT)
    var loot_near := _make_node(Vector2(10, 0), Groups.LOOT)
    var collector := _make_node(Vector2(20, 0), Groups.COLLECTORS)
    var hauler := _make_node(Vector2.ZERO, Groups.COMBATANTS) # group unused, but keeps symmetry

    var task := system.request_task(hauler)

    assert_object(task).is_not_null()
    assert_int(task.loot_id).is_equal(loot_near.get_instance_id())
    assert_int(task.collector_id).is_equal(collector.get_instance_id())
    assert_int(task.status).is_equal(HaulTask.Status.CLAIMED)
    assert_int(task.claimed_by_id).is_equal(hauler.get_instance_id())


## Reaps expired claims and reopens tasks so they can be reassigned.
func test_reap_expired_claims_reopens_task() -> void:
    var system: HaulerTaskSystem = auto_free(HaulerTaskSystem.new())
    add_child(system)

    var loot := _make_node(Vector2.ZERO, Groups.LOOT)
    var collector := _make_node(Vector2(5, 0), Groups.COLLECTORS)

    var task := HaulTask.new()
    task.loot_id = loot.get_instance_id()
    task.collector_id = collector.get_instance_id()
    task.status = HaulTask.Status.CLAIMED
    task.claim_started_msec = Time.get_ticks_msec() - 20_000
    task.claim_ttl_msec = 1_000

    system._tasks.append(task)

    system._reap_expired_claims()

    assert_int(task.status).is_equal(HaulTask.Status.OPEN)
    assert_int(task.claimed_by_id).is_equal(0)


func _make_node(pos: Vector2, group: StringName) -> Node2D:
    var n: Node2D = auto_free(Node2D.new())
    n.global_position = pos
    add_child(n)
    n.add_to_group(group)
    return n
