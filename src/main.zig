const std = @import("std");
const generator = @import("svd2zig-core/zig-generator.zig");

pub fn main() anyerror!void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    var args = std.process.argsWithAllocator(allocator) catch |err| return err;
    defer args.deinit();

    _ = args.next(); // skip application name
    // Note memory will be freed on exit since using arena

    const file_name = if (args.next()) |arg| arg else return error.MandatoryFilenameArgumentNotGiven;
    const newfile_name = if (args.next()) |arg| arg else return error.OutputFilenameArgumentNotGiven;

    var r = try std.fs.cwd().openFile(file_name, .{ .mode = .read_only });
    defer r.close();
    var w = try std.fs.cwd().createFile(newfile_name, .{});
    defer w.close();

    try generator.generate(allocator, &r.reader(), &w.writer());
}
