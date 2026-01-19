# AGENTS.md — TDRPG (Godot / GDScript)

Codex: read this first. This repo is a Godot (GDScript) game project named TDRPG:
a tower-defense + roguelike + logistics-automation hybrid set on a generation ship.

This file is “operational context”: how to work in this repo without breaking the project,
and how to keep changes aligned with design + engineering intent.

If anything here conflicts with in-repo docs, treat:
1) docs/ai/TDRPG_CONTEXT.md as the canonical design context
2) existing code as canonical for conventions unless explicitly updated

## Prime directive
Prefer small, correct, reviewable diffs. Avoid churn.

- Do not mass-reformat files unless requested.
- Avoid renames/moves of scenes/resources unless necessary.
- Preserve Godot scene/resource metadata (UIDs, ext_resource ids, paths) unless you are explicitly migrating them.

## Project pillars (design constraints)
- Hybrid hero + towers. Towers can be destructible; defenses must be maintainable, not “set and forget.”
- Multiple vulnerable bases/hubs across the ship; there is no perfectly safe home.
- Logistics and intel matter: networks can be partitioned; the player’s awareness is constrained by sensing/vision.
- “Failure teaches”: when a run goes bad, it should reveal system truth, not feel arbitrary.

More detail: docs/ai/TDRPG_CONTEXT.md

## Project Structure & Module Organization
- `game/` holds core GDScript code (systems, AI, components, utils).
- `scenes/` contains Godot scenes and scene-specific scripts (`.tscn`, `.gd`).
- `assets/` stores art, definitions, and imported resources (`.tres`, `.png`, `.aseprite`).
- `tools/` includes helper scripts and the `gdscript-formatter` binary.
- `project.godot` is the Godot project entry point.

## Build, Test, and Development Commands
- `make setup` downloads or prompts for the `gdscript-formatter` binary in `tools/`.
- `make lint` runs GDScript linting with `gdscript-formatter` (max line length 120).
- `make format` formats all `.gd` files with spaces and code reordering.
- `make lint-fix` formats then lints.

To run the game locally, open `project.godot` in the Godot editor and run the main scene.

## Coding Style & Naming Conventions
- Format GDScript using `make format` (spaces, reordered code, 120-char lines).
- Lint with `make lint`; the function-name rule is disabled, so follow existing style.
- Use `snake_case` for filenames and keep directory layout consistent with `game/` and `scenes/`.

## Commit & Pull Request Guidelines
- Commit messages are short, imperative, and sentence case (e.g., "Implement squad spawner policy").
- PRs should include a concise summary, test steps (or "Not tested"), and screenshots/GIFs for visual or gameplay changes.

## Safe defaults for edits
- Prefer additive changes with clear seams (new files, new small classes) over invasive rewrites.
- When touching gameplay logic, add debug hooks or small test scenes where possible.
- Keep “runtime logic” separate from “debug draw / UI” where feasible.

## Local workflow (commands)
Godot supports running from the command line; use `--path` or `--upwards` so commands resolve the project root.

Fill these in with your real commands:
- Run editor: `godot -e --path .`
- Run game: `godot --path .`
- Export headless (CI-style): `godot --headless --path . --export-release "<preset>" "<output>"`
- If you use Godot unit tests: `godot --path . --test --help` (then choose a test target)

## Where to look for deeper context
- docs/ai/TDRPG_CONTEXT.md            design + vocabulary + invariants
- docs/ai/GODOT_GDSCRIPT_STYLE.md     practical GDScript/Godot conventions for this project
- game/ai/squads/AGENTS.override.md   extra rules for squad subsystem changes
