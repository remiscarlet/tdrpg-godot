### Title
0001: Nav-aware belief map with stamped evidence

### Status
Proposed

### Context
The AI Director currently maintains a simple grid-based belief map that diffuses and decays uniformly. It is fed by player sightings/attacks and lacks awareness of navigation walkability, obstacle blocking, or negative evidence. As a result, belief can “bleed” through walls, cannot be suppressed by cleared areas, and provides limited guidance for search directives. Debug overlays exist but do not differentiate sources or shapes of evidence.

We are tackling this incrementally. The first milestone is a “single-room” belief map that still respects non-propagatable cells (pillars, inner walls) via a mask, without yet depending on full navmesh data. The design must allow multiple belief map instances in the future (one per room) once rooms become explicit game entities.

### Problem
We need the belief map to produce plausible search guidance for squads: belief should stay on reachable/propagatable space, respond to different evidence shapes (sighting, cone-of-loss, noise), allow suppression from negative scans, and remain performant within the Director’s 1 Hz tick. The current uniform diffusion grid does not capture these behaviors, leading to unrealistic enemy searches and limited debugging signal. Short term, this must work inside a single room while honoring interior obstacles; longer term it must scale to one belief map per room.

### Drivers / Constraints
- Belief must be confined to propagatable cells; avoid leaking through walls, pillars, or voids.
- Support multiple evidence shapes (point stamp, cone/arc, area, line) with configurable strength/decay.
- Negative evidence (clear/scan) should locally suppress belief.
- Maintain compatibility with existing Director tick loop and debug overlay.
- Keep per-tick work roughly O(active_cells) and avoid large allocations.
- Navmesh-aware behavior is desirable but not required for the single-room milestone; design should accept a future nav-derived mask without API churn.
- Multiple belief map instances (one per room) should be enabled by construction-time dependencies; no singletons.

### Options Considered
1) **Status quo + tuning**  
   - Pros: zero code churn; predictable behavior.  
   - Cons: leaks through walls; no suppression; weak search guidance.  
   - Risks: AI search remains implausible; future features still blocked.

2) **Masked grid with stamped evidence (Single-room first, nav-optional) — Recommended direction**  
   - Pros: Confines belief to propagatable cells via a `CellMask`; supports stamp shapes (point, circle/area, cone/arc, line) and suppression; keeps dictionary grid structure; enables multiple `BeliefMap` instances by construction; minimal integration churn for Director and overlays.  
   - Cons: Requires mask precomputation and neighbor lookup respecting blocked cells; modest refactor of BeliefMap API and Director observation handling.  
   - Risks: If mask generation is wrong, belief may disappear; must guard against perf spikes when stamping large areas. Nav integration deferred, so cross-room path fidelity waits for a later milestone.

3) **Navgraph/particle-based propagation**  
   - Pros: Highest fidelity (anisotropic propagation along graph, obstacle-aware cones).  
   - Cons: Larger rewrite; more complex data structures and serialization; higher perf/maintenance cost.  
   - Risks: Over-engineering relative to current need; harder to debug/visualize quickly.

### Decision
Pursue Option 2 in staged form: implement a masked-grid BeliefMap that runs in a single room using a `CellMask` for propagatable cells (pillars/walls blocked), with stamp and suppression APIs. Keep the design ready to accept nav-derived masks and multiple BeliefMap instances (one per room) in later milestones. Status remains Proposed pending implementation validation.

### Consequences
### Consequences
- Positive:
  - Belief remains on propagatable cells; no bleed through pillars or inner walls.
  - Evidence can be expressed as intuitive stamps (point, circle, cone/arc, line sweep) with per-stamp intensity/decay.
  - Negative evidence clears or attenuates belief where scouts/searches confirm absence.
  - Existing overlays remain usable; intensities stay normalized; per-room overlays become possible.
- Negative:
  - Additional mask dependency; initialization must wait for mask data (nav-derived or simple occupancy).
  - Slightly higher per-tick cost for mask-aware neighbor resolution and pruning.
  - Cross-room guidance fidelity deferred until nav integration and room routing exist.
- Follow-ups / migration steps:
  - Implement `CellMask` builder for single-room occupancy (blocked cells for pillars/walls) with cached 4/8-neighbor lists; add navmesh/tilemap adapters later.
  - Extend BeliefMap API: constructor injection of `CellMask`/config; `stamp_point/area/cone/line`, `suppress_area`, `query_hotspots(top_n)`, `decay_and_prune`.
  - Director integration: route events to the correct BeliefMap instance (single room now; room lookup later); map event kinds to stamp types (sighting -> point+cone, loss-of-LOS -> cone, noise -> area, scan -> suppression).
  - Add unit and integration tests; update debug overlay to optionally color by source type and handle multiple map instances when introduced.

### Notes
- Keep diffusion anisotropic by using nav-connected neighbors only; default to Manhattan if navmask unavailable (fails safe).
- Prune cells below epsilon after decay to cap active set size.
- Normalize stamp intensity relative to cell count to avoid total-mass inflation when stamping large areas.
