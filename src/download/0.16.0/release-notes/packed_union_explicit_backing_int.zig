// Declaring a packed union type normally
const Split16 = packed union(u16) {
    raw: MaybeSigned16,
    split: packed struct { low: u8, high: u8 },
};

// Constructing a packed union type using `@Union`
const MaybeSigned16 = @Union(
    .@"packed",
    u16, // backing integer type
    &.{ "unsigned", "signed" },
    &.{ u16, i16 },
    &@splat(.{}),
);

test "use packed union type with explicit backing integer" {
    const u: Split16 = .{ .raw = .{ .unsigned = 0xFFFE } };
    try testing.expectEqual(-2, u.raw.signed);
    try testing.expectEqual(0xFE, u.split.low);
    try testing.expectEqual(0xFF, u.split.high);
}

const testing = @import("std").testing;

// test
