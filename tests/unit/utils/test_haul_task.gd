extends GdUnitTestSuite

const HaulTask = preload("res://game/utils/haul_task.gd")


## Verifies new haul tasks start open and unexpired with default timestamps.
func test_defaults_are_open_and_not_expired() -> void:
    var task := HaulTask.new()
    assert_int(task.status).is_equal(HaulTask.Status.OPEN)
    assert_bool(task.is_claim_expired(10_000)).is_false()


## Confirms claims only expire when marked claimed and TTL has elapsed.
func test_claim_expiration_only_when_claimed_and_ttl_passed() -> void:
    var task := HaulTask.new()
    task.status = HaulTask.Status.CLAIMED
    task.claim_started_msec = 1_000
    task.claim_ttl_msec = 200

    assert_bool(task.is_claim_expired(1_150)).is_false()
    assert_bool(task.is_claim_expired(1_250)).is_true()


## Ensures non-claimed statuses never report expired claims regardless of timing.
func test_other_statuses_never_expire_claim() -> void:
    var task := HaulTask.new()
    task.status = HaulTask.Status.IN_PROGRESS
    task.claim_started_msec = 0
    task.claim_ttl_msec = 10

    assert_bool(task.is_claim_expired(1_000)).is_false()
