test "trigger dependency loop" {
    const val: S = .{};
    _ = val;
}

const S = struct { x: u32 = default_val };
const default_val = other_val;
const other_val = @typeInfo(S).@"struct".fields.len;

// test_error=dependency loop with length 3
