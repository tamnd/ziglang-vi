const std = @import("std");
const Io = std.Io;

test "trivial cancel demo" {
    const io = std.testing.io;

    var file_task = io.async(Io.Dir.openFile, .{ .cwd(), io, "hello.txt", .{} });
    defer if (file_task.cancel(io)) |file| file.close(io) else |_| {};
}

// test
