const std = @import("std");
const expectEqual = std.testing.expectEqual;

test "round to int" {
    try example(12, 12.34);
    try example(13, 12.50);
}

fn example(expected: u8, value: f32) !void {
    const actual: u8 = @round(value);
    try expectEqual(expected, actual);
}

// test
