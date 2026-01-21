# 0001: Game Tests Plan

- Status: Active
- Linked ADR(s): None
- Scope: Add tests for all non-trivial scripts under `game/` (excluding `scenes/`).
- Last updated: 2026-01-21

## Summary
Plan and phase the work to add unit and integration tests for every non-trivial `game/` script, with
unit tests first and engine-bound integration tests later. Constants/enums-only files are treated
as trivial and do not require tests. Debug overlay render tests are excluded; core debug state and
service logic remain in scope.

## Implementation phases (required)
1. Phase 0 — Inventory + harness alignment
   - Goal: Confirm scope, mapping, and test harness patterns.
   - Key tasks:
     - Snapshot current untested list and mark trivial exclusions (constants/enums, no-func files).
     - Create a shared test helper module under `tests/helpers/` for engine-bound tests (scene tree
       setup, `await get_tree().physics_frame`, deterministic RNG usage, and common stubs).
     - Identify modules that require lightweight seams (dependency injection or wrapper methods);
       consult before introducing refactors needed to unblock tests.
   - Exit criteria:
     - Test mapping list for all `game/` scripts with test suite paths and scope (unit/integration).
     - Helper utilities documented for consistent setup/teardown patterns.

2. Phase 1 — Pure data + utility unit tests
   - Goal: Cover deterministic, data-oriented logic first.
   - Key targets:
     - `game/utils/*` (non-const helpers), `game/events/*`, `game/state/*`,
       `game/definitions/*` resource helpers, `game/ai/director/*` data maps (Heat/Belief).
     - Squad data structures: `game/ai/squads/squad_runtime.gd`, `squad_directive.gd`,
       `squad_link.gd`, `squad_spawn_*` data resources.
   - Exit criteria:
     - Unit suites for all non-trivial data/resource scripts listed above.
     - No engine dependencies required in these tests.

3. Phase 2 — Component + controller unit tests
   - Goal: Validate component state transitions and controller logic with minimal scene wiring.
   - Key targets:
     - Components (health, inventory component, lootable, sensors, melee, pickup, etc.).
     - Controllers (aim/fire, player input, ai hauler).
     - Attachments rig helpers (`attachments_rig.gd`, `module_host.gd`, module base + wiring modules)
       via lightweight node trees and mocks for dependencies.
     - Debug core: `game/debug/debug_state.gd`, `game/debug/debug_service.gd`.
   - Exit criteria:
     - Unit suites exercising state changes, signal emission, and binding behavior.
     - GdUnit-based scene tree fixtures used for engine-bound behavior where required.

4. Phase 3 — System-level integration tests
   - Goal: Prove cross-component/system interactions with minimal environment setup.
   - Key targets:
     - `game/systems/*` (loot, combatant, turret, ranged attack, spawn, hauler tasks, level system).
     - Use minimal scene trees and stubbed definitions/contexts to verify lifecycle behaviors.
   - Exit criteria:
     - Integration suites in `tests/integration/` for complex multi-node flows.
     - Deterministic results (seeded RNG, fixed time steps).

5. Phase 4 — AI + locomotion integration tests
   - Goal: Cover navigation- and physics-bound behaviors.
   - Key targets:
     - `game/locomotion/*` (intent driver, flocking, goal providers).
     - `game/ai/squads/squad_system.gd`, `game/ai/supervisor/*`, `game/ai/states/*`.
   - Exit criteria:
     - Integration tests using GdUnit engine helpers (physics frames, NavigationServer2D setup).
     - Clear separation between deterministic unit logic and engine-side integration checks.

6. Phase 5 — Cleanup + regression guard
   - Goal: Final sweep and ensure untested inventory is minimized.
   - Key tasks:
     - Add missing suites for any remaining non-trivial files.
     - Review `untested_files.md` output and reconcile with exclusions.
   - Exit criteria:
     - No remaining non-trivial `game/` files without tests.
     - Full `make test` passes.

### Shared test helpers (required)
Add a common helper module under `tests/helpers/test_utils.gd` used by engine-bound suites.

Minimum helper API (initial):
- `await_physics_frames(count: int = 1)` -> await `get_tree().physics_frame` N times.
- `make_scene_root()` -> returns a Node (and optionally sets it as current scene).
- `add_child_and_await_ready(parent: Node, child: Node)` -> add + await `child.ready`.
- `seed_rng(seed: int)` -> returns a deterministic `RandomNumberGenerator`.
- `with_autoload_stub(name: String, stub: Node, fn: Callable)` -> temporarily add/remove stub.
- `make_nav_map_2d()` -> creates a NavigationServer2D map + returns RID; pairs with cleanup.

Keep helpers small, deterministic, and pure. If new helpers imply refactors in game code, stop and consult.

## Milestones
- M1: Test mapping + helpers ready (end of Phase 0).
- M2: Pure data + utility unit coverage complete (end of Phase 1).
- M3: Components/controllers + debug core covered (end of Phase 2).
- M4: Systems + AI/locomotion integration coverage complete (end of Phase 4).
- M5: `game/` test coverage complete and `make test` passes (end of Phase 5).

## Risks and mitigations
- Engine-bound flakiness (navigation/physics timing) — mitigate with deterministic seeds,
  `await get_tree().physics_frame`, and minimal scene fixtures.
- Hidden dependencies on autoloads (`Debug`, `DefinitionDB`) — use explicit stubs in tests or
  temporary overrides within the test scene tree.
- High coupling in systems/modules — consult before refactors are introduced to create test seams.

## Validation / Acceptance
- Every non-trivial `game/` script has a corresponding test suite:
  - Unit suites in `tests/unit/` for deterministic logic.
  - Integration suites in `tests/integration/` for multi-node/engine interactions.
- Constants/enums-only files are excluded as trivial; debug overlays excluded for render tests only.
- `make test` succeeds; failures are traced to specific suites with actionable output.
- `docs/agent/context/testing/untested_files.md` (or its generator output) shows zero remaining
  `game/` files outside the agreed exclusions.

## Open questions
- Should any systems be refactored for test seams now, or only when a test is blocked?

## Notes
- Engine-bound tests should use GdUnit4 features for scene tree lifecycle and physics ticks.
- Scene scripts under `scenes/` are out of scope for this spec.
