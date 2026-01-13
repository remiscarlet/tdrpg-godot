class_name HaulTask
extends RefCounted

enum Status { OPEN, CLAIMED, IN_PROGRESS, DONE, FAILED }

var loot_id: int
var loot_loc: Vector2
var collector_id: int
var collector_loc: Vector2
var status: Status = Status.OPEN
var claimed_by_id: int = 0
var claim_started_msec: int = 0
var claim_ttl_msec: int = 15_000


func is_claim_expired(now_msec: int) -> bool:
    return status == Status.CLAIMED and (now_msec - claim_started_msec) > claim_ttl_msec
