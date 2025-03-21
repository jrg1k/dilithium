const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const cflags = .{
        "-Wall",
        "-Werror",
        "-Wextra",
        "-Wmissing-prototypes",
        "-Wno-unused-result",
        "-Wpedantic",
        "-Wpointer-arith",
        "-Wredundant-decls",
        "-Wshadow",
        "-Wvla",
    };

    const cfiles = .{
        "ntt.c",
        "packing.c",
        "poly.c",
        "polyvec.c",
        "reduce.c",
        "rounding.c",
        "sign.c",
        "symmetric-shake.c",
    };

    const lib_mod = b.createModule(.{
        .root_source_file = b.path("root.zig"),
        .target = target,
        .optimize = optimize,
        .omit_frame_pointer = true,
        .single_threaded = true,
    });

    _ = b.addModule("dilithium", .{
        .root_source_file = b.path("api.zig"),
        .target = target,
        .optimize = optimize,
    });

    lib_mod.addCSourceFiles(.{
        .root = b.path("ref"),
        .files = &.{"fips202.c"},
        .flags = &cflags,
    });

    const modes = .{ "2", "3", "5" };

    inline for (modes) |m| {
        lib_mod.addCSourceFiles(.{
            .root = b.path("ref"),
            .files = &cfiles,
            .flags = &(cflags ++ .{"-DDILITHIUM_MODE=" ++ m}),
        });
    }

    const staticlib = b.addLibrary(.{
        .linkage = .static,
        .name = "dilithium_static",
        .root_module = lib_mod,
    });

    const dylib = b.addLibrary(.{
        .linkage = .dynamic,
        .name = "dilithium",
        .root_module = lib_mod,
    });

    b.installArtifact(dylib);
    b.installArtifact(staticlib);

    const lib_check = b.addLibrary(.{ .name = "check", .root_module = lib_mod });
    const check = b.step("check", "Build check");
    check.dependOn(&lib_check.step);
}
