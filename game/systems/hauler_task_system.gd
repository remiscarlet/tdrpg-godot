class_name HaulerTaskSystem
extends Node

var _tasks: Array[HaulTask] = []

func _process(_dt: float) -> void:
	_reap_expired_claims()

func request_task(hauler: Node2D) -> HaulTask:
	_prune_invalid_tasks()

	var best := _pick_best_open_task(hauler)
	if best != null:
		_claim(best, hauler)
		return best

	_generate_some_tasks()
	best = _pick_best_open_task(hauler)
	if best != null:
		_claim(best, hauler)
	return best

func _generate_some_tasks() -> void:
	var loots := get_tree().get_nodes_in_group(Groups.LOOT)
	var collectors := get_tree().get_nodes_in_group(Groups.COLLECTORS)
	for loot in loots:
		for col in collectors:
			# Minimal viability: assume compatible; refine later with can_accept(item)
			var t := HaulTask.new()
			t.loot_loc = loot.global_position
			t.collector_loc = col.global_position
			t.loot_id = loot.get_instance_id()
			t.collector_id = col.get_instance_id()
			_tasks.append(t)
	# TODO: don’t generate full cross-product; pick nearest collector per loot.

func _pick_best_open_task(hauler: Node2D) -> HaulTask:
	var best: HaulTask = null
	var best_score := INF
	for t in _tasks:
		if t.status != HaulTask.Status.OPEN:
			continue

		var loot := instance_from_id(t.loot_id)
		var col := instance_from_id(t.collector_id)
		if not (is_instance_valid(loot) and is_instance_valid(col)):
			continue

		var score: float= hauler.global_position.distance_to(loot.global_position) \
			+ loot.global_position.distance_to(col.global_position)

		if score < best_score:
			best_score = score
			best = t
	return best

func _claim(t: HaulTask, hauler: Node) -> void:
	t.status = HaulTask.Status.CLAIMED
	t.claimed_by_id = hauler.get_instance_id()
	t.claim_started_msec = Time.get_ticks_msec()

func _reap_expired_claims() -> void:
	var now := Time.get_ticks_msec()
	for t in _tasks:
		if t.is_claim_expired(now):
			t.status = HaulTask.Status.OPEN
			t.claimed_by_id = 0

func _prune_invalid_tasks() -> void:
	_tasks = _tasks.filter(func(t: HaulTask) -> bool:
		var loot := instance_from_id(t.loot_id)
		var col := instance_from_id(t.collector_id)
		return is_instance_valid(loot) and is_instance_valid(col) and t.status != HaulTask.Status.DONE
	)
