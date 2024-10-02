const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const exe = b.addExecutable(.{
        .name = "svd2zig",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    const @"svd2zig-core" = b.dependency("svd2zig-core", .{
        .target = target,
        .optimize = optimize,
    });
    _ = exe.root_module.addImport("svd2zig", @"svd2zig-core".module("svd2zig-generator"));

    b.installArtifact(exe);
    b.default_step.dependOn(&exe.step);
}
