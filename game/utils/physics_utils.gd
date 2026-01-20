class_name PhysicsUtils

## Purpose: Physics layer and mask helper utilities.
static var _cfg_by_team: Dictionary[int, TeamPhysics] = _build()
static var world_collidables: PackedInt32Array = [Layers.WORLD_SOLID]


static func _build() -> Dictionary[int, TeamPhysics]:
    return {
        CombatantTeam.PLAYER: (
            TeamPhysics.new(
                PackedInt32Array([Layers.PLAYER_HITBOX]), # Hitbox
                PackedInt32Array([Layers.ENEMY1_HURTBOX, Layers.ENEMY2_HURTBOX]),
                PackedInt32Array([Layers.PLAYER_HURTBOX]), # Hurtbox
                PackedInt32Array([Layers.ENEMY1_HITBOX, Layers.ENEMY2_HITBOX]),
                PackedInt32Array([Layers.PLAYER_PICKUPBOX]), # Pickupbox
                PackedInt32Array([Layers.LOOT]),
                PackedInt32Array([Layers.PLAYER_TARGETING_SENSOR]), # Target Detector
                PackedInt32Array([Layers.ENEMY1_HURTBOX, Layers.ENEMY2_HURTBOX]),
                PackedInt32Array([Layers.PLAYER_HOSTILE_SENSOR]), # Hostile (in sight) Detector
                PackedInt32Array([Layers.ENEMY1_HURTBOX, Layers.ENEMY2_HURTBOX]),
            )
        ),
        CombatantTeam.BOT: (
            TeamPhysics.new(
                PackedInt32Array([Layers.ENEMY1_HITBOX]), # Hitbox
                PackedInt32Array([Layers.ENEMY2_HURTBOX, Layers.PLAYER_HURTBOX]),
                PackedInt32Array([Layers.ENEMY1_HURTBOX]), # Hurtbox
                PackedInt32Array([Layers.ENEMY2_HITBOX, Layers.PLAYER_HITBOX]),
                PackedInt32Array([Layers.ENEMY1_PICKUPBOX]), # Pickupbox
                PackedInt32Array([]),
                PackedInt32Array([Layers.ENEMY1_TARGETING_SENSOR]), # Target Detector
                PackedInt32Array([Layers.ENEMY2_HURTBOX, Layers.PLAYER_HURTBOX]),
                PackedInt32Array([Layers.ENEMY1_HOSTILE_SENSOR]), # Hostile (in sight) Detector
                PackedInt32Array([Layers.ENEMY2_HURTBOX, Layers.PLAYER_HURTBOX]),
            )
        ),
        CombatantTeam.MUTANT: (
            TeamPhysics.new(
                PackedInt32Array([Layers.ENEMY2_HITBOX]), # Hitbox
                PackedInt32Array([Layers.ENEMY1_HURTBOX, Layers.PLAYER_HURTBOX]),
                PackedInt32Array([Layers.ENEMY2_HURTBOX]), # Hurtbox
                PackedInt32Array([Layers.ENEMY1_HITBOX, Layers.PLAYER_HITBOX]),
                PackedInt32Array([Layers.ENEMY2_PICKUPBOX]), # Pickupbox
                PackedInt32Array([]),
                PackedInt32Array([Layers.ENEMY2_TARGETING_SENSOR]), # Target Detector
                PackedInt32Array([Layers.ENEMY1_HURTBOX, Layers.PLAYER_HURTBOX]),
                PackedInt32Array([Layers.ENEMY2_HOSTILE_SENSOR]), # Hostile (in sight) Detector
                PackedInt32Array([Layers.ENEMY1_HURTBOX, Layers.PLAYER_HURTBOX]),
            )
        ),
    }


static func _get_cfg(team_id: int) -> TeamPhysics:
    var cfg: TeamPhysics = _cfg_by_team.get(team_id)
    assert(cfg != null, "Unknown team_id: %d" % team_id)
    return cfg


static func get_projectile_layer(team_id: int) -> int:
    return as_mask(_get_cfg(team_id).hitbox_layer)


static func get_projectile_mask(team_id: int) -> int:
    return as_mask(_get_cfg(team_id).hitbox_mask)


static func get_hitbox_layer(team_id: int) -> int:
    return as_mask(_get_cfg(team_id).hitbox_layer)


static func get_hitbox_mask(team_id: int) -> int:
    return as_mask(_get_cfg(team_id).hitbox_mask)


static func get_hurtbox_layer(team_id: int) -> int:
    return as_mask(_get_cfg(team_id).hurtbox_layer)


static func get_hurtbox_mask(team_id: int) -> int:
    return as_mask(_get_cfg(team_id).hurtbox_mask)


static func get_world_collidables_mask() -> int:
    return as_mask(world_collidables)


static func as_mask(layers: PackedInt32Array) -> int:
    var mask := 0
    for layer in layers:
        mask |= 1 << (layer - 1)
    return mask


static func set_hitbox_collisions_for_team(proj: CollisionObject2D, team_id: int) -> void:
    var cfg := _get_cfg(team_id)
    for layer in cfg.hitbox_layer:
        proj.set_collision_layer_value(layer, true)
    for layer in cfg.hitbox_mask:
        proj.set_collision_mask_value(layer, true)


static func set_hurtbox_collisions_for_team(hurtbox: CollisionObject2D, team_id: int) -> void:
    var cfg := _get_cfg(team_id)
    for layer in cfg.hurtbox_layer:
        hurtbox.set_collision_layer_value(layer, true)
    for layer in cfg.hurtbox_mask:
        hurtbox.set_collision_mask_value(layer, true)


static func set_pickupbox_collisions_for_team(pickupbox: CollisionObject2D, team_id: int) -> void:
    var cfg := _get_cfg(team_id)
    for layer in cfg.pickupbox_layer:
        pickupbox.set_collision_layer_value(layer, true)
    for layer in cfg.pickupbox_mask:
        pickupbox.set_collision_mask_value(layer, true)


static func set_target_detector_collisions_for_team(
        detector: CollisionObject2D,
        team_id: int,
) -> void:
    var cfg := _get_cfg(team_id)
    for layer in cfg.targeting_layer:
        detector.set_collision_layer_value(layer, true)
    for layer in cfg.targeting_mask:
        detector.set_collision_mask_value(layer, true)


static func set_hostile_detector_collisions_for_team(
        detector: CollisionObject2D,
        team_id: int,
) -> void:
    var cfg := _get_cfg(team_id)
    for layer in cfg.hostile_layer:
        detector.set_collision_layer_value(layer, true)
    for layer in cfg.hostile_mask:
        detector.set_collision_mask_value(layer, true)


class TeamPhysics:
    var hitbox_layer: PackedInt32Array
    var hitbox_mask: PackedInt32Array
    var hurtbox_layer: PackedInt32Array
    var hurtbox_mask: PackedInt32Array
    var pickupbox_layer: PackedInt32Array
    var pickupbox_mask: PackedInt32Array
    var targeting_layer: PackedInt32Array
    var targeting_mask: PackedInt32Array
    var hostile_layer: PackedInt32Array
    var hostile_mask: PackedInt32Array


    func _init(
            hit_layer: PackedInt32Array,
            hit_mask: PackedInt32Array,
            hurt_layer: PackedInt32Array,
            hurt_mask: PackedInt32Array,
            pb_layer: PackedInt32Array,
            pb_mask: PackedInt32Array,
            t_layer: PackedInt32Array,
            t_mask: PackedInt32Array,
            h_layer: PackedInt32Array,
            h_mask: PackedInt32Array,
    ) -> void:
        hitbox_layer = hit_layer
        hitbox_mask = hit_mask
        hurtbox_layer = hurt_layer
        hurtbox_mask = hurt_mask
        pickupbox_layer = pb_layer
        pickupbox_mask = pb_mask
        targeting_layer = t_layer
        targeting_mask = t_mask
        hostile_layer = h_layer
        hostile_mask = h_mask
