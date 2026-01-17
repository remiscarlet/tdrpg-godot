class_name NavUtils


static func get_some_random_reachable_point(
        nav_rid: RID,
        from: Vector2,
        tries: int = 12,
        wander_radius: float = 400.0,
) -> Vector2:
    var path := get_some_random_path(nav_rid, from, tries, wander_radius)
    return path[path.size() - 1]


static func get_some_random_path(
        nav_rid: RID,
        from: Vector2,
        tries: int = 12,
        wander_radius: float = 400.0,
        wander_radius_mod_min: float = 0.25, # Discourages tiny paths
) -> PackedVector2Array:
    var _rng := RandomNumberGenerator.new() # Potential footgun?

    var origin := NavigationServer2D.map_get_closest_point(nav_rid, from)

    for i in range(tries):
        # Random point in a disk around origin (uniform-ish).
        var angle := _rng.randf_range(0.0, TAU)
        var radius := sqrt(_rng.randf_range(wander_radius_mod_min, 1.0)) * wander_radius
        var candidate := origin + Vector2(radius, 0.0).rotated(angle)

        # Snap candidate onto the nav surface.
        candidate = NavigationServer2D.map_get_closest_point(nav_rid, candidate)

        # Ask server for a path to prove it’s reachable.
        var path := (
            NavigationServer2D.map_get_path(
                nav_rid,
                origin,
                candidate,
                true,
                Layers.NAV_WALK,
            )
        )

        return path

    # Fallback: don’t move.
    return [origin]
