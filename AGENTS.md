# AGENTS.md — TDRPG (Godot / GDScript)

Codex: read this first. This repo is a Godot (GDScript) game project named TDRPG:
a tower-defense + roguelike + logistics-automation hybrid set on a generation ship.

This file is “operational context”: how to work in this repo without breaking the project,
and how to keep changes aligned with design + engineering intent.

If anything here conflicts with in-repo docs, treat:
1) docs/agent/context/TDRPG_CONTEXT.md as the canonical design context
2) existing code as canonical for conventions unless explicitly updated

## Agent documentation layout
The `docs/agent/` tree is the agent/human shared knowledge base. It has two entrypoints:

- `docs/agent/context/` — **reference context**
  - Project design vocabulary, invariants, style guidance, architecture notes.
  - These files explain “what” and “why”.

- `docs/agent/skills/` — **workflows / runbooks**
  - Step-by-step procedures with required inputs/outputs (e.g., TDD loop, doc updates).
  - These files explain “how” to perform recurring work in a consistent way.

**Rule:** Keep operational “how to work here without breaking things” guidance in `AGENTS.md` files,
and keep deep reference material and repeatable workflows under `docs/agent/context/` and
`docs/agent/skills/`. 

## Using Skills
Whenever the user requests a change or discussion relating to the codebase, check the `docs/agent/skills/index.md` file for any relevant skills.
If there is a relevant skill, you must use it.
If you are unusure if you should use a skill or not, prompt the user for confirmation.

## Instruction priority & scope
Instructions are scoped and prioritized as follows:

1) **Nearest directory instructions win:** If a directory contains `AGENTS.md` or `AGENTS.override.md`,
   treat those as authoritative for that directory subtree.
2) This top-level `AGENTS.md` applies repo-wide where not overridden.
3) `docs/agent/context/*` is canonical for design vocabulary, intent, and architectural rationale.
4) Existing code is canonical for local conventions and patterns unless explicitly changed.

When instructions conflict, prefer the most specific (closest) instructions for the files you are editing.

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

More detail: docs/agent/context/TDRPG_CONTEXT.md

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

Project style guide: docs/agent/context/GODOT_GDSCRIPT_STYLE.md

## Commit & Pull Request Guidelines
- Commit messages are short, imperative, and sentence case (e.g., "Implement squad spawner policy").
- PRs should include a concise summary, test steps (or "Not tested"), and screenshots/GIFs for visual or gameplay changes.

## Safe defaults for edits
- Prefer additive changes with clear seams (new files, new small classes) over invasive rewrites.
- When touching gameplay logic, add debug hooks or small test scenes where possible.
- Keep “runtime logic” separate from “debug draw / UI” where feasible.

## Workflows (skills) — when to use them
Recurring workflows live under `docs/agent/skills/`. When a task matches a workflow, follow it.

Recommended defaults:
- Architecture/design:
    - Discussion: follow `docs/agent/skills/design_discussion.md`
    - Recording decisions: follow `docs/agent/skills/record_design_decision.md`
- Implementing changes: follow `docs/agent/skills/implement_spec.md`
- Documentation updates (finalizer): follow `docs/agent/skills/doc_update.md`

**Doc updates are first-class:** If a ch
