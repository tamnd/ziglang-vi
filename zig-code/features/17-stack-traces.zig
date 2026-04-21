const std = @import("std");

var address_buffer: [8]usize = undefined;

var trace1: std.debug.StackTrace = .{
    .return_addresses = address_buffer[0..4],
    .skipped = .none,
};

var trace2: std.debug.StackTrace = .{
    .return_addresses = address_buffer[4..],
    .skipped = .none,
};

pub fn main() void {
    foo();
    bar();

    std.debug.print("first one:\n", .{});
    std.debug.dumpStackTrace(&trace1);
    std.debug.print("\n\nsecond one:\n", .{});
    std.debug.dumpStackTrace(&trace2);
}

fn foo() void {
    trace1 = std.debug.captureCurrentStackTrace(.{}, address_buffer[0..4]);
}

fn bar() void {
    trace2 = std.debug.captureCurrentStackTrace(.{}, address_buffer[4..]);
}

// exe=succeed
