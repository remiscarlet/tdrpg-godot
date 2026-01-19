# GdUnit4 setup (headless)

GdUnit4 v6.0.3 is vendored in `addons/gdUnit4` and enabled in `project.godot`.

## Running tests (headless)
- `godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd --scan-tests tests --report-dir res://tests/.reports`
  - `--scan-tests` points at the root test folder defined in `.gdunit.cfg`.
  - Reports land under `tests/.reports` (JUnit/XML/HTML depending on settings).

## Writing tests
- Use `extends GdUnitTestSuite`.
- Place new suites under `tests/` (e.g., `tests/unit/` for pure script coverage).
- Start a test with a passing placeholder to verify discovery before adding assertions.
