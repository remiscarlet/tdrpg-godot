# TESTING

Quick reference for how we test the project and how LLM agents should treat testing context/skills as first-class.

## Tooling
- Primary: GdUnit4 (vendored under `addons/gdUnit4`, enabled in `project.godot`).
- Test root: `tests/` (see `.gdunit.cfg`); sample suite lives at `tests/unit/sample_test.gd`.
- Detailed GdUnit notes: `docs/agent/context/testing/gdunit4.md`.

## Running Tests (headless)
- From repo root: `make test`
  - Full command is found in `Makefile`
  - `--ignoreHeadlessMode` is required because GdUnit 6 blocks headless runs by default; safe for our current headless-only suite.
  - `-a tests` queues the whole `tests/` directory; respects `.gdunit.cfg`.
  - Reports land in `tests/.reports` (HTML + XML). Keep this command in sync with the vendored GdUnit version.

## Where to Put Tests
- Unit and small integration suites under `tests/` (mirror source structure when possible).
- Use `extends GdUnitTestSuite`; start with a passing placeholder to confirm discovery before deep assertions.
- Prefer fastest scope runs (single file → folder → full suite) when iterating.

## Agentic Workflow Notes
- Treat context and skills as part of the test surface area:
  - Consult relevant skills before/while touching tests (e.g., `docs/agent/skills/tdd_loop.md` for TDD, `doc_update.md` when updating commands/instructions).
  - Honor nearest `AGENTS.md` guidance; testing-related sharp edges belong in this file or under `docs/agent/context/testing/`.
- If you change how tests are run (commands, paths, tooling version), update this file and the GdUnit subdoc; run `doc_update` skill as a finalizer.
- Record test evidence in PR summaries/notes (commands run, pass/fail) to keep agent context fresh.
