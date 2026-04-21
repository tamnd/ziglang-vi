//! External dependencies:
//! * 7z
//! * tar
//! * xz
//! * gzip
//! * minisign
//! * git
//! * cmake
//! * ninja

const std = @import("std");
const Io = std.Io;
const Allocator = std.mem.Allocator;
const mem = std.mem;
const fatal = std.debug.panic;
const log = std.log;

const Target = struct {
    triple: []const u8,
    cpu: []const u8,
    key: []const u8,
    is_windows: bool = false,

    fn ext(t: Target) []const u8 {
        return if (t.is_windows) ".zip" else ".tar.xz";
    }
};
const targets = [_]Target{
    .{
        .triple = "x86_64-linux-musl",
        .cpu = "baseline",
        .key = "x86_64-linux",
    },
    .{
        .triple = "s390x-linux-musl",
        .cpu = "baseline",
        .key = "s390x-linux",
    },
    .{
        .triple = "aarch64-macos-none",
        .cpu = "baseline",
        .key = "aarch64-macos",
    },
    .{
        .triple = "x86-windows-gnu",
        .cpu = "baseline",
        .key = "x86-windows",
        .is_windows = true,
    },
    .{
        .triple = "x86_64-macos-none",
        .cpu = "baseline",
        .key = "x86_64-macos",
    },
    .{
        .triple = "aarch64-linux-musl",
        .cpu = "baseline",
        .key = "aarch64-linux",
    },
    .{
        .triple = "riscv64-linux-musl",
        .cpu = "baseline",
        .key = "riscv64-linux",
    },
    .{
        .triple = "powerpc64le-linux-musl",
        .cpu = "baseline",
        .key = "powerpc64le-linux",
    },
    .{
        .triple = "x86-linux-musl",
        .cpu = "baseline",
        .key = "x86-linux",
    },
    .{
        .triple = "x86_64-windows-gnu",
        .cpu = "baseline",
        .key = "x86_64-windows",
        .is_windows = true,
    },
    .{
        .triple = "aarch64-windows-gnu",
        .cpu = "baseline",
        .key = "aarch64-windows",
        .is_windows = true,
    },
    .{
        .triple = "arm-linux-musleabi",
        .cpu = "baseline",
        .key = "arm-linux",
    },
    .{
        .triple = "loongarch64-linux-musl",
        .cpu = "baseline",
        .key = "loongarch64-linux",
    },
    .{
        .triple = "aarch64-freebsd-none",
        .cpu = "baseline",
        .key = "aarch64-freebsd",
    },
    .{
        .triple = "arm-freebsd-eabihf",
        .cpu = "baseline",
        .key = "arm-freebsd",
    },
    .{
        .triple = "powerpc64le-freebsd-none",
        .cpu = "baseline",
        .key = "powerpc64le-freebsd",
    },
    .{
        .triple = "riscv64-freebsd-none",
        .cpu = "baseline",
        .key = "riscv64-freebsd",
    },
    .{
        .triple = "x86_64-freebsd-none",
        .cpu = "baseline",
        .key = "x86_64-freebsd",
    },
    .{
        .triple = "aarch64-netbsd-none",
        .cpu = "baseline",
        .key = "aarch64-netbsd",
    },
    .{
        .triple = "arm-netbsd-eabihf",
        .cpu = "baseline",
        .key = "arm-netbsd",
    },
    .{
        .triple = "x86-netbsd-none",
        .cpu = "baseline",
        .key = "x86-netbsd",
    },
    .{
        .triple = "x86_64-netbsd-none",
        .cpu = "baseline",
        .key = "x86_64-netbsd",
    },
    .{
        .triple = "aarch64-openbsd-none",
        .cpu = "baseline",
        .key = "aarch64-openbsd",
    },
    .{
        .triple = "arm-openbsd-eabi",
        .cpu = "baseline",
        .key = "arm-openbsd",
    },
    .{
        .triple = "riscv64-openbsd-none",
        .cpu = "baseline",
        .key = "riscv64-openbsd",
    },
    .{
        .triple = "x86_64-openbsd-none",
        .cpu = "baseline",
        .key = "x86_64-openbsd",
    },
};

var arena_instance = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const arena = arena_instance.allocator();

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const environ_map = init.environ_map;
    const args = try init.minimal.args.toSlice(init.arena.allocator());

    const work_path = args[1]; // example: "/home/ci/work";
    const www_prefix = args[2]; // example: "/var/www/html";
    const index_json_template_filename = args[3]; // example: "index.json";
    const now = Io.Timestamp.now(io, .real);

    const work_dir = try Io.Dir.cwd().openDir(io, work_path, .{});
    const zig_dir = try work_dir.openDir(io, "zig", .{ .iterate = true });
    const bootstrap_dir = try work_dir.openDir(io, "zig-bootstrap", .{ .iterate = true });
    const www_dir = try Io.Dir.cwd().createDirPathOpen(io, www_prefix, .{});
    const builds_dir = try www_dir.createDirPathOpen(io, "builds", .{
        .open_options = .{ .iterate = true },
    });
    const std_docs_dir = try www_dir.createDirPathOpen(io, "documentation/master/std", .{});

    // GitHub passes missing environment variables as empty string.
    const ZIG_RELEASE_TAG = environ_map.get("ZIG_RELEASE_TAG").?;
    const ZIG_BOOTSTRAP_BRANCH = environ_map.get("ZIG_BOOTSTRAP_BRANCH").?;

    const zig_release_tag = if (ZIG_RELEASE_TAG.len != 0) ZIG_RELEASE_TAG else null;
    const branch = if (ZIG_BOOTSTRAP_BRANCH.len != 0) ZIG_BOOTSTRAP_BRANCH else "master";

    try environ_map.put("XZ_OPT", "-9");
    try environ_map.put("CMAKE_GENERATOR", "Ninja");

    // Override the cache directories because they won't actually help other CI runs
    // which will be testing alternate versions of zig, and ultimately would just
    // fill up space on the hard drive for no reason.
    try bootstrap_dir.createDirPath(io, "out/zig-global-cache");
    try bootstrap_dir.createDirPath(io, "out/zig-local-cache");
    try environ_map.put("ZIG_GLOBAL_CACHE_DIR", try bootstrap_dir.realPathFileAlloc(io, "out/zig-global-cache", arena));
    try environ_map.put("ZIG_LOCAL_CACHE_DIR", try bootstrap_dir.realPathFileAlloc(io, "out/zig-local-cache", arena));

    if (zig_dir.access(io, ".git/shallow", .{})) |_| {
        run(io, environ_map, zig_dir, &.{ "git", "fetch", "--tags", "--unshallow" });
    } else |err| switch (err) {
        error.FileNotFound => {
            run(io, environ_map, zig_dir, &.{ "git", "fetch", "--tags" });
        },
        else => |e| fatal("failed to check .git/shallow: {t}", .{e}),
    }

    const zig_ver, const is_release = if (zig_release_tag) |tag| v: {
        // Manually triggered workflow.
        run(io, environ_map, zig_dir, &.{ "git", "checkout", tag });
        log.info("Building version from commit: {s}", .{tag});
        break :v .{ tag, true };
    } else v: {
        const json_text = try fetch(
            io,
            "https://codeberg.org/api/v1/repos/ziglang/zig/actions/runs?page=1&limit=1&event=push&status=success&ref=refs%2Fheads%2Fmaster",
            .{},
            &.{
                .{ .name = "accept", .value = "application/json;charset=utf-8" },
            },
        );
        const last_success = pluckLastSuccessFromJson(json_text);
        run(io, environ_map, zig_dir, &.{ "git", "checkout", last_success });
        const zig_ver = try zigVer(io, environ_map, zig_dir);
        log.info("Last commit with green CI: {s}", .{last_success});
        log.info("Zig version: {s}", .{zig_ver});

        const last_tarball = pluckLastTarballFromJsonFile(io, work_dir, "index.json");
        log.info("Last deployed version: {s}", .{last_tarball});

        if (std.mem.eql(u8, zig_ver, last_tarball)) {
            log.info("Versions are equal, nothing to do here.", .{});
            return;
        }
        break :v .{ zig_ver, false };
    };
    log.info("zig version: {s}", .{zig_ver});

    try work_dir.deleteTree(io, "tarballs");
    var tarballs_dir = try work_dir.createDirPathOpen(io, "tarballs", .{});
    defer tarballs_dir.close(io);
    const zig_ver_sub_path = print("zig-{s}", .{zig_ver});
    var tarballs_zig_dir = try tarballs_dir.createDirPathOpen(io, zig_ver_sub_path, .{});
    defer tarballs_zig_dir.close(io);
    try copyTree(io, zig_dir, tarballs_zig_dir, &.{
        ".forgejo",
        ".gitignore",
        ".gitattributes",
        ".git",
        ".mailmap",
        "ci",
        "build",
        "build-release",
        "build-debug",
        "zig-cache",
    });
    try updateLine(
        io,
        tarballs_zig_dir,
        "bootstrap.c",
        "        const char *zig_version = \"",
        print("        const char *zig_version = \"{s}\";\n", .{zig_ver}),
    );

    var template_map: std.StringHashMapUnmanaged([]const u8) = .empty;
    try template_map.put(arena, "master-version", zig_ver);
    try template_map.put(arena, "master-date", timestamp(now));

    const src_tarball_name = print("zig-{s}.tar.xz", .{zig_ver});
    run(io, environ_map, tarballs_dir, &.{
        "tar",
        "cfJ",
        src_tarball_name,
        print("zig-{s}/", .{zig_ver}),
        "--sort=name",
    });
    signAndMove(io, environ_map, tarballs_dir, src_tarball_name, builds_dir);
    try addTemplateEntry(io, &template_map, "src", builds_dir, src_tarball_name);

    run(io, environ_map, bootstrap_dir, &.{ "git", "clean", "-fd" });
    run(io, environ_map, bootstrap_dir, &.{ "git", "reset", "--hard", "HEAD" });
    run(io, environ_map, bootstrap_dir, &.{ "git", "fetch" });
    run(io, environ_map, bootstrap_dir, &.{ "git", "checkout", print("origin/{s}", .{branch}) });

    {
        try bootstrap_dir.deleteTree(io, "zig");
        try Io.Dir.rename(tarballs_dir, zig_ver_sub_path, bootstrap_dir, "zig", io);
    }
    try updateLine(io, bootstrap_dir, "build", "ZIG_VERSION=", print("ZIG_VERSION=\"{s}\"\n", .{
        zig_ver,
    }));
    try updateLine(io, bootstrap_dir, "build.bat", "set ZIG_VERSION=", print("set ZIG_VERSION=\"{s}\"\r\n", .{
        zig_ver,
    }));
    try updateLine(io, bootstrap_dir, "README.md", " * zig ", print(" * zig {s}\n", .{
        zig_ver,
    }));

    try bootstrap_dir.deleteTree(io, "out");

    {
        var tarballs_bootstrap_dir = try tarballs_dir.createDirPathOpen(io, print("zig-bootstrap-{s}", .{zig_ver}), .{});
        defer tarballs_bootstrap_dir.close(io);
        try copyTree(io, bootstrap_dir, tarballs_bootstrap_dir, &.{
            ".forgejo",
            ".git",
            ".gitattributes",
            ".gitignore",
        });
    }

    const bootstrap_src_tarball_name = print("zig-bootstrap-{s}.tar.xz", .{zig_ver});
    run(io, environ_map, tarballs_dir, &.{
        "tar",
        "cfJ",
        bootstrap_src_tarball_name,
        print("zig-bootstrap-{s}/", .{zig_ver}),
        "--sort=name",
    });
    signAndMove(io, environ_map, tarballs_dir, bootstrap_src_tarball_name, builds_dir);
    try addTemplateEntry(io, &template_map, "bootstrap", builds_dir, bootstrap_src_tarball_name);

    for (targets) |target| {
        // NOTE: Debian's cmake (3.18.4) is too old for zig-bootstrap.
        run(io, environ_map, bootstrap_dir, &.{ "./build", target.triple, target.cpu });
    }

    // Delete builds older than 30 days so the server does not run out of disk space.
    try deleteOld(io, builds_dir, now);

    for (targets) |target| {
        const bootstrap_basename = print("out/zig-{s}-{s}", .{ target.triple, target.cpu });
        const user_basename = print("zig-{s}-{s}", .{ target.key, zig_ver });
        Io.Dir.rename(bootstrap_dir, bootstrap_basename, tarballs_dir, user_basename, io) catch |err|
            fatal("failed to rename {s} to {s}: {t}", .{ bootstrap_basename, user_basename, err });

        const tarball_filename = if (target.is_windows) t: {
            const tarball_filename = print("{s}.zip", .{user_basename});
            run(io, environ_map, tarballs_dir, &.{
                "7z", "a", tarball_filename, print("{s}/", .{user_basename}),
            });
            break :t tarball_filename;
        } else t: {
            const tarball_filename = print("{s}.tar.xz", .{user_basename});
            run(io, environ_map, tarballs_dir, &.{
                "tar", "cfJ", tarball_filename, print("{s}/", .{user_basename}), "--sort=name",
            });
            break :t tarball_filename;
        };
        signAndMove(io, environ_map, tarballs_dir, tarball_filename, builds_dir);
        try addTemplateEntry(io, &template_map, target.key, builds_dir, tarball_filename);
    }

    const index_json_basename = print("zig-{s}-index.json", .{zig_ver});
    try render(io, &template_map, index_json_template_filename, tarballs_dir, index_json_basename, .plain);
    signAndMove(io, environ_map, tarballs_dir, index_json_basename, builds_dir);

    // Instead of updating via git, update directly to prevent the ziglang.org git
    // repo from growing too big.

    if (!is_release) {
        try builds_dir.copyFile(index_json_basename, work_dir, "index.json", io, .{});
    }

    const langref_path = print("zig-{s}-{s}/doc/langref.html", .{ targets[0].key, zig_ver });
    try tarballs_dir.copyFile(langref_path, www_dir, "documentation/master/index.html", io, .{});

    // Standard library autodocs are intentionally excluded from tarballs of
    // Zig but we want to host them on the website.
    const zig_exe = try bootstrap_dir.realPathFileAlloc(io, "out/host/bin/zig", arena);
    run(io, environ_map, bootstrap_dir, &.{ zig_exe, "build-obj", "-fno-emit-bin", "-femit-docs=std", "zig/lib/std/std.zig" });

    gzipCopy(io, environ_map, bootstrap_dir, "std/index.html", std_docs_dir);
    gzipCopy(io, environ_map, bootstrap_dir, "std/main.js", std_docs_dir);
    gzipCopy(io, environ_map, bootstrap_dir, "std/main.wasm", std_docs_dir);
    gzipCopy(io, environ_map, bootstrap_dir, "std/sources.tar", std_docs_dir);
}

fn zigVer(io: Io, environ_map: *const std.process.Environ.Map, dir: Io.Dir) ![]const u8 {
    // Make the `zig version` number consistent.
    // This will affect the "git describe" command below.
    run(io, environ_map, dir, &.{ "git", "config", "core.abbrev", "9" });

    const build_zig_contents = try dir.readFileAlloc(io, "build.zig", arena, .limited(100 * 1024));
    const zig_version = v: {
        var line_it = mem.tokenizeAny(u8, build_zig_contents, "\r\n");
        while (line_it.next()) |line| {
            if (mem.startsWith(u8, line, "const zig_version: std.SemanticVersion = ")) {
                var it = mem.tokenizeAny(u8, line, " =.{,");
                var ver: std.SemanticVersion = .{ .major = 0, .minor = 0, .patch = 0 };
                while (it.next()) |token| {
                    if (mem.eql(u8, token, "major")) {
                        ver.major = try std.fmt.parseInt(u32, it.next().?, 0);
                    } else if (mem.eql(u8, token, "minor")) {
                        ver.minor = try std.fmt.parseInt(u32, it.next().?, 0);
                    } else if (mem.eql(u8, token, "patch")) {
                        ver.patch = try std.fmt.parseInt(u32, it.next().?, 0);
                    }
                }
                break :v ver;
            }
        }
        fatal("unable to find zig version in build.zig", .{});
    };

    const result = try std.process.run(arena, io, .{
        .cwd = .{ .dir = dir },
        .argv = &.{ "git", "describe", "--match", "*.*.*", "--tags" },
        .environ_map = environ_map,
    });

    switch (result.term) {
        .exited => |code| {
            if (code != 0) {
                std.debug.print("{s}", .{result.stderr});
                std.process.exit(code);
            }
        },
        .signal, .stopped, .unknown => fatal("{s}", .{result.stderr}),
    }

    const git_describe = mem.trim(u8, result.stdout, " \n\r");

    const version_string = print("{d}.{d}.{d}", .{
        zig_version.major, zig_version.minor, zig_version.patch,
    });

    switch (mem.count(u8, git_describe, "-")) {
        0 => {
            // Tagged release version (e.g. 0.10.0).
            if (!mem.eql(u8, git_describe, version_string)) {
                fatal("Zig version '{s}' does not match Git tag '{s}'", .{
                    version_string, git_describe,
                });
            }
            return version_string;
        },
        2 => {
            // Untagged development build (e.g. 0.10.0-dev.2025+ecf0050a9).
            var it = mem.splitScalar(u8, git_describe, '-');
            const tagged_ancestor = it.first();
            const commit_height = it.next().?;
            const commit_id = it.next().?;

            const ancestor_ver = try std.SemanticVersion.parse(tagged_ancestor);
            if (zig_version.order(ancestor_ver) != .gt) {
                fatal("Zig version '{f}' must be greater than tagged ancestor '{f}'", .{
                    zig_version, ancestor_ver,
                });
            }

            // Check that the commit hash is prefixed with a 'g' (a Git convention).
            if (commit_id.len < 1 or commit_id[0] != 'g') {
                fatal("Unexpected `git describe` output: {s}", .{git_describe});
            }

            // The version is reformatted in accordance with the https://semver.org specification.
            return print("{s}-dev.{s}+{s}", .{
                version_string, commit_height, commit_id[1..],
            });
        },
        else => {
            fatal("Unexpected `git describe` output: {s}", .{git_describe});
        },
    }
}

fn runWorkaround(
    io: Io,
    environ_map: *const std.process.Environ.Map,
    dir: Io.Dir,
    argv: []const []const u8,
    workaround: bool,
) void {
    log.info("running {s}...", .{argv[0]});
    var child = std.process.spawn(io, .{
        .argv = argv,
        .stdin = if (workaround) .pipe else .close,
        .cwd = .{ .dir = dir },
        .environ_map = environ_map,
    }) catch |err| fatal("spawning command failed with {t}:\n{s}", .{ err, allocPrintCmd(argv) });
    if (workaround) {
        // minisign requires this otherwise it pointlessly prompts for a password
        child.stdin.?.writeStreamingAll(io, "\n") catch |err| fatal("failed to write newline: {t}", .{err});
        child.stdin.?.close(io);
        child.stdin = null;
    }
    const term = child.wait(io) catch |err|
        fatal("following command failed with {t}:\n{s}", .{ err, allocPrintCmd(argv) });
    switch (term) {
        .exited => |code| {
            if (code == 0) return;
            fatal("following command exited with failure code {d}:\n{s}", .{ code, allocPrintCmd(argv) });
        },
        else => {
            fatal("following command terminated abnormally via {t}:\n{s}", .{ term, allocPrintCmd(argv) });
        },
    }
}

fn run(io: Io, environ_map: *const std.process.Environ.Map, dir: Io.Dir, argv: []const []const u8) void {
    return runWorkaround(io, environ_map, dir, argv, false);
}

fn allocPrintCmd(argv: []const []const u8) []u8 {
    var buf: std.ArrayListUnmanaged(u8) = .empty;
    for (argv) |arg| {
        buf.appendSlice(arena, arg) catch @panic("OOM");
        buf.append(arena, ' ') catch @panic("OOM");
    }
    buf.items.len -= 1;
    return buf.toOwnedSlice(arena) catch @panic("OOM");
}

fn fetch(
    io: Io,
    url: []const u8,
    headers: std.http.Client.Request.Headers,
    extra_headers: []const std.http.Header,
) ![]u8 {
    var response: std.Io.Writer.Allocating = .init(arena);
    var client: std.http.Client = .{ .allocator = arena, .io = io };
    const result = try client.fetch(.{
        .location = .{ .url = url },
        .response_writer = &response.writer,
        .headers = headers,
        .extra_headers = extra_headers,
    });
    if (result.status != .ok) fatal("fetch from {s} result: {t}", .{ url, result.status });
    return response.written();
}

fn pluckLastSuccessFromJson(json_text: []const u8) []const u8 {
    // ".workflow_runs[0].commit_sha"
    const Response = struct {
        workflow_runs: []const WorkflowRun,
        const WorkflowRun = struct {
            commit_sha: []const u8,
        };
    };
    const parsed = std.json.parseFromSliceLeaky(Response, arena, json_text, .{
        .ignore_unknown_fields = true,
        .parse_numbers = false,
    }) catch |err| {
        fatal("{t} when parsing this json text:\n{s}", .{ err, json_text });
    };
    if (parsed.workflow_runs.len < 1) fatal("no workflow runs returned", .{});
    return parsed.workflow_runs[0].commit_sha;
}

test pluckLastSuccessFromJson {
    try std.testing.expectEqualStrings("f925e1379aa53228610df9b7ffc3d87dbcce0dbb", pluckLastSuccessFromJson(example_response));
}

fn pluckLastTarballFromJsonFile(io: Io, dir: Io.Dir, file_path: []const u8) []const u8 {
    // .master.version
    const json_text = dir.readFileAlloc(io, file_path, arena, .limited(100 * 1024 * 1024)) catch |err| {
        fatal("failed to open {s}: {t}", .{ file_path, err });
    };
    const Releases = struct {
        master: struct {
            version: []const u8,
        },
    };
    const parsed = std.json.parseFromSliceLeaky(Releases, arena, json_text, .{
        .ignore_unknown_fields = true,
        .parse_numbers = false,
    }) catch |err| fatal("{t} when parsing this json text:\n{s}", .{ err, json_text });
    return parsed.master.version;
}

fn print(comptime fmt: []const u8, args: anytype) []u8 {
    return std.fmt.allocPrint(arena, fmt, args) catch @panic("OOM");
}

fn copyTree(io: Io, src_dir: Io.Dir, dest_dir: Io.Dir, exclude: []const []const u8) !void {
    var it = try src_dir.walk(arena);
    next_entry: while (try it.next(io)) |entry| {
        for (exclude) |p| {
            if (mem.startsWith(u8, entry.path, p) and
                (entry.path.len == p.len or entry.path[p.len] == '/'))
            {
                continue :next_entry;
            }
        }
        switch (entry.kind) {
            .directory => {
                try dest_dir.createDirPath(io, entry.path);
            },
            .file => {
                src_dir.copyFile(entry.path, dest_dir, entry.path, io, .{}) catch |err|
                    fatal("failed to copy {s}: {t}", .{ entry.path, err });
            },
            else => continue,
        }
    }
}

fn updateLine(io: Io, dir: Io.Dir, file_path: []const u8, prefix: []const u8, replacement: []const u8) !void {
    const contents = dir.readFileAlloc(io, file_path, arena, .limited(10 * 1024 * 1024)) catch |err| {
        fatal("failed to read {s}: {t}", .{ file_path, err });
    };
    var output: std.ArrayListUnmanaged(u8) = .empty;
    defer output.deinit(arena);
    var it = mem.splitScalar(u8, contents, '\n');
    while (it.next()) |line| {
        if (mem.startsWith(u8, line, prefix)) {
            try output.appendSlice(arena, replacement);
            try output.appendSlice(arena, it.rest());
            break;
        } else {
            try output.appendSlice(arena, line);
            try output.append(arena, '\n');
        }
    } else fatal("did not find match of '{s}' in {s}", .{ prefix, file_path });

    try dir.writeFile(io, .{
        .sub_path = file_path,
        .data = output.items,
    });
}

fn signAndMove(
    io: Io,
    environ_map: *const std.process.Environ.Map,
    src_dir: Io.Dir,
    basename: []const u8,
    dest_dir: Io.Dir,
) void {
    Io.Dir.rename(src_dir, basename, dest_dir, basename, io) catch |err| {
        fatal("failed to move {s}: {t}", .{ basename, err });
    };
    runWorkaround(io, environ_map, dest_dir, &.{ "minisign", "-Sm", basename }, true);
}

fn deleteOld(io: Io, builds_dir: Io.Dir, now: Io.Timestamp) !void {
    var it = try builds_dir.walk(arena);
    while (try it.next(io)) |entry| {
        switch (entry.kind) {
            .file => {
                const stat = try builds_dir.statFile(io, entry.path, .{ .follow_symlinks = false });
                const age = stat.ctime.durationTo(now);
                const days = @divTrunc(age.toSeconds(), std.time.s_per_day);
                if (days > 30) {
                    log.info("deleting {d}-day-old tarball {s}", .{ days, entry.path });
                    try builds_dir.deleteFile(io, entry.path);
                } else {
                    log.info("not deleting {d}-day-old tarball {s}", .{ days, entry.path });
                }
            },
            else => continue,
        }
    }
}

fn addTemplateEntry(
    io: Io,
    map: *std.StringHashMapUnmanaged([]const u8),
    name: []const u8,
    dir: Io.Dir,
    tarball_basename: []const u8,
) !void {
    const file = try dir.openFile(io, tarball_basename, .{});
    defer file.close(io);
    const size = (try file.stat(io)).size;
    const digest = try sha256sum(io, file, size);
    try map.put(arena, print("{s}-tarball", .{name}), tarball_basename);
    try map.put(arena, print("{s}-shasum", .{name}), print("{x}", .{&digest}));
    try map.put(arena, print("{s}-bytesize", .{name}), print("{d}", .{size}));
}

fn sha256sum(io: Io, file: Io.File, size: u64) ![32]u8 {
    var hasher: std.crypto.hash.sha2.Sha256 = .init(.{});
    var buffer: [4000]u8 = undefined;
    var remaining = size;
    while (remaining > 0) {
        const buf = buffer[0..@min(remaining, buffer.len)];
        const n = try file.readStreaming(io, &.{buf});
        hasher.update(buf);
        remaining -= n;
    }
    return hasher.finalResult();
}

fn timestamp(now: Io.Timestamp) []const u8 {
    const epoch_seconds: std.time.epoch.EpochSeconds = .{ .secs = @intCast(now.toSeconds()) };
    const epoch_day = epoch_seconds.getEpochDay();
    const year_day = epoch_day.calculateYearDay();
    const month_day = year_day.calculateMonthDay();
    return print("{d}-{d:0>2}-{d:0>2}", .{
        year_day.year, @intFromEnum(month_day.month), month_day.day_index + 1,
    });
}

test timestamp {
    try std.testing.expectEqualStrings("2025-05-24", timestamp(.fromNanoseconds(1748110477 * std.time.ns_per_s)));
}

fn render(
    io: Io,
    vars: *const std.StringHashMapUnmanaged([]const u8),
    in_file: []const u8,
    out_dir: Io.Dir,
    out_file: []const u8,
    fmt: enum {
        html,
        plain,
    },
) !void {
    const in_contents = try Io.Dir.cwd().readFileAlloc(io, in_file, arena, .limited(1 * 1024 * 1024));

    var buffer: std.Io.Writer.Allocating = .init(arena);
    defer buffer.deinit();

    const State = enum {
        Start,
        OpenBrace,
        VarName,
        EndBrace,
    };
    const writer = &buffer.writer;
    var state = State.Start;
    var var_name_start: usize = undefined;
    var line: usize = 1;
    for (in_contents, 0..) |byte, index| {
        switch (state) {
            State.Start => switch (byte) {
                '{' => {
                    state = State.OpenBrace;
                },
                else => try writer.writeByte(byte),
            },
            State.OpenBrace => switch (byte) {
                '{' => {
                    state = State.VarName;
                    var_name_start = index + 1;
                },
                else => {
                    try writer.writeByte('{');
                    try writer.writeByte(byte);
                    state = State.Start;
                },
            },
            State.VarName => switch (byte) {
                '}' => {
                    const var_name = in_contents[var_name_start..index];
                    if (vars.get(var_name)) |value| {
                        const trimmed = mem.trim(u8, value, " \r\n");
                        if (fmt == .html and mem.endsWith(u8, var_name, "bytesize")) {
                            const size = try std.fmt.parseInt(u64, trimmed, 10);
                            try writer.print("{Bi:.1}", .{size});
                        } else {
                            try writer.writeAll(trimmed);
                        }
                    } else {
                        std.debug.print("line {d}: missing variable: {s}\n", .{ line, var_name });
                        try writer.writeAll("(missing)");
                    }
                    state = State.EndBrace;
                },
                else => {},
            },
            State.EndBrace => switch (byte) {
                '}' => {
                    state = State.Start;
                },
                else => {
                    fatal("line {d}: invalid byte: '0x{x}'", .{ line, byte });
                },
            },
        }
        if (byte == '\n') {
            line += 1;
        }
    }
    try out_dir.writeFile(io, .{ .sub_path = out_file, .data = buffer.written() });
}

fn gzipCopy(
    io: Io,
    environ_map: *std.process.Environ.Map,
    bootstrap_dir: Io.Dir,
    src: []const u8,
    dest_dir: Io.Dir,
) void {
    // TODO std lib is missing a way to pass an open file descriptor to a child process
    const argv = [_][]const u8{ "gzip", "-c", "-9", src };
    const result = std.process.run(arena, io, .{
        .cwd = .{ .dir = bootstrap_dir },
        .argv = &argv,
        .environ_map = environ_map,
        .stderr_limit = .limited(50 * 1024 * 1024),
        .stdout_limit = .limited(50 * 1024 * 1024),
    }) catch |err| {
        fatal("failed to run the following command with {t}:\n{s}", .{ err, allocPrintCmd(&argv) });
    };
    switch (result.term) {
        .exited => |code| {
            if (code != 0) {
                std.debug.print("{s}", .{result.stderr});
                fatal("following command exited with code {d}:\n{s}", .{ code, allocPrintCmd(&argv) });
            }
        },
        else => {
            std.debug.print("{s}", .{result.stderr});
            fatal("following command terminated abnormally:\n{s}", .{allocPrintCmd(&argv)});
        },
    }
    const new_name = print("{s}.gz", .{Io.Dir.path.basename(src)});
    dest_dir.writeFile(io, .{
        .sub_path = new_name,
        .data = result.stdout,
    }) catch |err| fatal("failed to write {s}: {t}", .{ new_name, err });
}

const example_response =
    \\{
    \\  "total_count": 1305,
    \\  "workflow_runs": [
    \\    {
    \\      "id": 15156676549,
    \\      "commit_sha": "f925e1379aa53228610df9b7ffc3d87dbcce0dbb"
    \\    }
    \\  ]
    \\}
;

const example_release_json =
    \\{
    \\  "master": {
    \\    "version": "0.14.0",
    \\    "date": "2025-03-05"
    \\  }
    \\}
;
