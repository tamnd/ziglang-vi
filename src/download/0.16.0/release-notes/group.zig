const std = @import("std");
const Io = std.Io;

test "sleep sort" {
    const io = std.testing.io;

    // Initialize an array with 10 random numbers.

    const rng_impl: std.Random.IoSource = .{ .io = io };
    const rng = rng_impl.interface();

    var array: [10]i32 = undefined;
    for (&array) |*elem| elem.* = rng.uintLessThan(u16, 1000);

    var sorted: [10]i32 = undefined;
    var index: std.atomic.Value(usize) = .init(0);

    // Spawn a task for each element that sleeps a number of milliseconds equal
    // to the element value, then adds the element.

    var group: Io.Group = .init;
    defer group.cancel(io);

    for (&array) |elem| group.async(io, sleepAppend, .{ io, &sorted, &index, elem });

    try group.await(io);

    // Ensure the result is sorted.

    for (sorted[0 .. sorted.len - 1], sorted[1..]) |a, b| {
        try std.testing.expect(a <= b);
    }
}

fn sleepAppend(io: Io, result: []i32, i_ptr: *std.atomic.Value(usize), elem: i32) !void {
    try io.sleep(.fromMilliseconds(elem), .awake);
    result[i_ptr.fetchAdd(1, .monotonic)] = elem;
}

// test
