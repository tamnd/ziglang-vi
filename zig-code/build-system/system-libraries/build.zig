const std = @import("std");

pub fn build(b: *std.Build) void {
    const exe = b.addExecutable(.{
        .name = "zip",
        .root_module = b.createModule(.{
            .root_source_file = b.path("zip.zig"),
            .target = b.graph.host,
            .link_libc = true,
        }),
    });

    exe.root_module.linkSystemLibrary("z", .{});

    b.installArtifact(exe);
}

// build=succeed
// additional_option=--summary
// additional_option=all
