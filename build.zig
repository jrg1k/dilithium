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

    const dilithium_mod = b.createModule(.{
        .root_source_file = b.path("root.zig"),
        .target = target,
        .optimize = optimize,
        .omit_frame_pointer = true,
        .single_threaded = true,
        .strip = true,
    });

    dilithium_mod.addCSourceFiles(.{
        .root = b.path("ref"),
        .files = &.{"fips202.c"},
        .flags = &cflags,
    });

    const modes = .{ "2", "3", "5" };

    inline for (modes) |m| {
        dilithium_mod.addCSourceFiles(.{
            .root = b.path("ref"),
            .files = &cfiles,
            .flags = &(cflags ++ .{"-DDILITHIUM_MODE=" ++ m}),
        });
    }

    const dylib = b.addLibrary(.{
        .linkage = .dynamic,
        .name = "dilithium",
        .root_module = dilithium_mod,
    });

    b.installArtifact(dylib);
}
