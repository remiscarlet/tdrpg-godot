class_name PhysicsUtils

class TeamPhysics:
	var projectile_layer: PackedInt32Array
	var projectile_mask: PackedInt32Array
	var hurtbox_layer: PackedInt32Array
	var hurtbox_mask: PackedInt32Array

	func _init(
		p_layer: PackedInt32Array,
		p_mask: PackedInt32Array,
		h_layer: PackedInt32Array,
		h_mask: PackedInt32Array
	) -> void:
		projectile_layer = p_layer
		projectile_mask = p_mask
		hurtbox_layer = h_layer
		hurtbox_mask = h_mask

static var _cfg_by_team: Dictionary[int, TeamPhysics] = _build()

static func _build() -> Dictionary[int, TeamPhysics]:
	return {
		CombatantTeam.PLAYER: TeamPhysics.new(
			PackedInt32Array([Layers.PLAYER_PROJECTILE]),
			PackedInt32Array([Layers.ENEMY1_HURTBOX, Layers.ENEMY2_HURTBOX]),
			PackedInt32Array([Layers.PLAYER_HURTBOX]),
			PackedInt32Array([Layers.ENEMY1_PROJECTILE, Layers.ENEMY2_PROJECTILE, Layers.AREA_SENSOR]),
		),
		CombatantTeam.BOT: TeamPhysics.new(
			PackedInt32Array([Layers.ENEMY1_PROJECTILE]),
			PackedInt32Array([Layers.ENEMY2_HURTBOX, Layers.PLAYER_HURTBOX]),
			PackedInt32Array([Layers.ENEMY1_HURTBOX]),
			PackedInt32Array([Layers.ENEMY2_PROJECTILE, Layers.PLAYER_PROJECTILE, Layers.AREA_SENSOR]),
		),
		CombatantTeam.MUTANT: TeamPhysics.new(
			PackedInt32Array([Layers.ENEMY2_PROJECTILE]),
			PackedInt32Array([Layers.ENEMY1_HURTBOX, Layers.PLAYER_HURTBOX]),
			PackedInt32Array([Layers.ENEMY2_HURTBOX]),
			PackedInt32Array([Layers.ENEMY1_PROJECTILE, Layers.PLAYER_PROJECTILE, Layers.AREA_SENSOR]),
		),
	}

static func _get_cfg(team_id: int) -> TeamPhysics:
	var cfg: TeamPhysics = _cfg_by_team.get(team_id)
	assert(cfg != null, "Unknown team_id: %d" % team_id)
	return cfg

static func get_projectile_layer(team_id: int) -> PackedInt32Array:
	return _get_cfg(team_id).projectile_layer

static func get_projectile_mask(team_id: int) -> PackedInt32Array:
	return _get_cfg(team_id).projectile_mask

static func get_hurtbox_layer(team_id: int) -> PackedInt32Array:
	return _get_cfg(team_id).hurtbox_layer

static func get_hurtbox_mask(team_id: int) -> PackedInt32Array:
	return _get_cfg(team_id).hurtbox_mask

static func set_projectile_physics_for_team(proj: CollisionObject2D, team_id: int) -> void:
	var cfg := _get_cfg(team_id)
	for layer in cfg.projectile_layer:
		proj.set_collision_layer_value(layer, true)
	for layer in cfg.projectile_mask:
		proj.set_collision_mask_value(layer, true)

static func set_hurtbox_physics_for_team(hurtbox: CollisionObject2D, team_id: int) -> void:
	var cfg := _get_cfg(team_id)
	for layer in cfg.hurtbox_layer:
		hurtbox.set_collision_layer_value(layer, true)
	for layer in cfg.hurtbox_mask:
		hurtbox.set_collision_mask_value(layer, true)
