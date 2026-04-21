const std = @import("std");
const Io = std.Io;

pub fn main(init: std.process.Init) !void {
    const gpa = init.gpa;
    const io = init.io;

    const args = try init.minimal.args.toSlice(init.arena.allocator());

    const host_name: Io.net.HostName = try .init(args[1]);

    var http_client: std.http.Client = .{ .allocator = gpa, .io = io };
    defer http_client.deinit();

    var request = try http_client.request(.HEAD, .{
        .scheme = "http",
        .host = .{ .percent_encoded = host_name.bytes },
        .port = 80,
        .path = .{ .percent_encoded = "/" },
    }, .{});
    defer request.deinit();

    try request.sendBodiless();

    var redirect_buffer: [1024]u8 = undefined;
    const response = try request.receiveHead(&redirect_buffer);
    std.log.info("received {d} {s}", .{ response.head.status, response.head.reason });
}

// exe=succeed example.com
