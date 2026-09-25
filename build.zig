const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const wren = b.addLibrary(.{
        .name = "wren",
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        }),
    });
    wren.root_module.addCSourceFiles(.{
        .files = &.{
            "src/vm/wren_compiler.c",
            "src/vm/wren_core.c",
            "src/vm/wren_debug.c",
            "src/vm/wren_primitive.c",
            "src/vm/wren_utils.c",
            "src/vm/wren_value.c",
            "src/vm/wren_vm.c",
            "src/optional/wren_opt_meta.c",
            "src/optional/wren_opt_random.c",
        },
        .flags = &.{"-std=c99"},
    });
    wren.root_module.addIncludePath(b.path("src/include"));
    wren.root_module.addIncludePath(b.path("src/vm"));
    wren.root_module.addIncludePath(b.path("src/optional"));
    wren.root_module.addCMacro(if (optimize == .Debug) "DEBUG" else "NDEBUG", "1");

    // Wren uses libm on Unix, where math functions are a separate library.
    switch (target.result.os.tag) {
        .linux, .freebsd, .netbsd, .openbsd => wren.root_module.linkSystemLibrary("m", .{}),
        else => {},
    }

    wren.installHeader(b.path("src/include/wren.h"), "wren.h");
    b.installArtifact(wren);

    const smoke = b.addExecutable(.{
        .name = "wren_smoke",
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        }),
    });
    smoke.root_module.addCSourceFiles(.{
        .files = &.{"test/zig_build.c"},
        .flags = &.{"-std=c99"},
    });
    smoke.root_module.linkLibrary(wren);

    const test_step = b.step("test", "Run the C API smoke test");
    test_step.dependOn(&b.addRunArtifact(smoke).step);
}
