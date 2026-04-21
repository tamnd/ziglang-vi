const std = @import("std");
const Io = std.Io;

pub fn main(init: std.process.Init) !void {
    const io = init.io;

    const file = try Io.Dir.cwd().openFile(io, "does_not_exist/foo.txt", .{});
    defer file.close(io);

    var file_writer = file.writer(io, &.{});
    try file_writer.interface.writeAll("all your codebase are belong to us\n");
}

// exe=fail
