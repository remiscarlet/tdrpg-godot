# Godot / GDScript Style Notes (TDRPG)

These are project-specific preferences to keep the codebase coherent and Godot-friendly.

## Scene + resource edits
- Keep .tscn/.tres diffs minimal. Avoid “pretty printing” or wholesale rewrites.
- Be cautious with renames/moves: many references are path-based.

## Naming and structure
- Node names matter. Avoid casual node renames (they can break NodePath usage and editor wiring).
- Prefer clear “runtime vs view” separation:
  - runtime logic: state, decisions, simulation
  - view/debug: drawing, UI overlays, visualization

## Typed GDScript
- Prefer typed variables/params/returns for core runtime paths.
- Use types to document intent, not to win a type-theory contest.

## Properties vs methods (practical guideline)
- Direct reads are fine.
- Prefer methods for state transitions that matter (e.g., setting a new directive) so call sites are searchable and invariants can be enforced.
- Avoid boilerplate getters/setters for everything.

## Signals and events
- Use signals for cross-system notifications when ownership is unclear.
- Avoid signal spaghetti; keep event flow obvious.

## StringName usage
- Do not use raw `&"..."` literals in code. Define a `const` for every StringName instead.
- Prefer shared constants under `game/utils/constants/` (e.g., `DebugFlags`, `AttachmentModules`, `LocomotionIntents`, `StringNames.EMPTY`).
- If a constant will be used/read outside of the file it's contained it, it MUST live under `game/utils/constants/`.
- Module-specific identifiers may use a local `const` at the top of the file.
- Use `StringNames.EMPTY` (or another shared sentinel) instead of `&""` defaults.
- Enforce locally with `make lint-stringnames`.

## Command line usage
Use `--path` or `--upwards` so Godot can locate `project.godot` reliably.
