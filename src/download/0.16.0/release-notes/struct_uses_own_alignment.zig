const S = struct {
    foo: [*]align(@alignOf(@This())) u8,
};

test "trigger dependency loop" {
    const val: S = .{ .foo = &.{} };
    _ = val;
}

// test_error=depends on itself for alignment query here
