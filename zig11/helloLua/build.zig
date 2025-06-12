const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    
    const exe = b.addExecutable(.{
        .name = "helloLua",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });

    const cflags = [_][]const u8 {
        "-std=c99",
        "-Wall",
        "-Wextra",
        "-DLUA_COMPAT_5_3",
        switch(target.os_tag orelse (std.zig.system.NativeTargetInfo.detect(target) catch unreachable).target.os.tag) {
            .linux => "-DLUA_USE_LINUX",
            .macos => "-DLUA_USE_MACOSX",
            .windows => "-DLUA_USE_POSIX",
            else => "-DLUA_USE_POSIX",
        },
    };

    var luaSources = std.ArrayList([]const u8).init(b.allocator);
    var luaDir = try std.fs.cwd().openIterableDir("src/lualib", .{});
    var walker = try luaDir.walk(b.allocator);
    defer walker.deinit();
    while(try walker.next()) |file| {
        if(std.mem.eql(u8, std.fs.path.extension(file.basename), ".c")) {
            try luaSources.append(b.pathJoin(&.{"src/lualib/", file.path}));
        }
    }
    exe.addCSourceFiles(luaSources.items, &cflags);
    exe.addIncludePath(std.build.LazyPath.relative("src/lualib"));

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const unit_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });
    const run_unit_tests = b.addRunArtifact(unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_unit_tests.step);
}
