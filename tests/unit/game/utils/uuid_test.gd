extends GdUnitTestSuite
## Purpose: Validates UUID v4 formatting and uniqueness generation.

# Testee: res://game/utils/uuid.gd
# Scope: unit
# Tags: uuid
const Uuid = preload("res://game/utils/uuid.gd")


## Checks generated UUID v4 strings have correct length, separators, and version/variant bits.
func test_v4_format_and_bits() -> void:
    var id := Uuid.v4()
    assert_int(id.length()).is_equal(36)
    assert_str(id[8]).is_equal("-")
    assert_str(id[13]).is_equal("-")
    assert_str(id[18]).is_equal("-")
    assert_str(id[23]).is_equal("-")
    assert_str(id[14]).is_equal("4") # version nibble

    var variant_char := id[19]
    assert_array(["8", "9", "a", "b", "A", "B"]).contains(variant_char)


## Ensures repeated UUID v4 calls produce unique identifiers.
func test_v4_generates_unique_ids() -> void:
    var seen := { }
    for i in 10:
        var id := Uuid.v4()
        assert_bool(seen.has(id)).is_false()
        seen[id] = true
