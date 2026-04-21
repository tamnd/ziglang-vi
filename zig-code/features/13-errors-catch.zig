const std = @import("std");
const Io = std.Io;

pub fn main(init: std.process.Init) void {
    const io = init.io;

    const file: Io.File = Io.Dir.cwd().openFile(io, "does_not_exist/foo.txt", .{}) catch |err| label: {
        std.debug.print("unable to open file: {}\n", .{err});
        break :label .stderr();
    };

    var file_writer = file.writer(io, &.{});
    file_writer.interface.writeAll("all your codebase are belong to us\n") catch return;
}

// exe=succeed
