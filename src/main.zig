const std = @import("std");
const generator = @import("core/generator.zig");

pub fn main() anyerror!void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    var args = std.process.argsWithAllocator(allocator) catch |err| return err;
    defer args.deinit();

    _ = args.next(); // skip application name
    // Note memory will be freed on exit since using arena

    const file_name = if (args.next()) |arg| arg else return error.MandatoryFilenameArgumentNotGiven;

    try generator.generate(allocator, file_name, "./");
}
