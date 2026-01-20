extends GdUnitTestSuite
## Purpose: Confirms the test runner discovers at least one suite.


# Testee: res://tests/unit/sample_test.gd
# Scope: unit
# Tags: sample
# No-op placeholder test to validate GdUnit4 wiring.
## Confirms the test suite discovers and runs by asserting a trivial true condition.
func test_placeholder_passes() -> void:
    assert_bool(true).is_true()
