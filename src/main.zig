const std = @import("std");
const expect = std.testing.expect;
const ArrayList = std.ArrayList;

pub fn main() !void {
    //std.debug.print("All your {s} are belong to us.\n", .{"codebase"});
    //const stdout_file = std.io.getStdOut().writer();
    //var bw = std.io.bufferedWriter(stdout_file);
    //const stdout = bw.writer();
    //try stdout.print("Run `zig build test` to run the tests.\n", .{});
    //try bw.flush(); // don't forget to flush!

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        const deinit_status = gpa.deinit();
        if (deinit_status == .leak) expect(false) catch @panic("TEST FAIL");
    }

    var list1 = ArrayList([]const u8).init(allocator);
    defer list1.deinit();
    var list2 = ArrayList([]const u8).init(allocator);
    defer list2.deinit();

    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();
    var buffer: [128]u8 = undefined;

    // Get contents of first list from user
    try stdout.print("-- List A --\n", .{});

    var i: usize = 0;
    while (i == 0 or !std.mem.eql(u8, list1.getLast(), "")) : (i += 1) {
        try stdout.print("#{d}: ", .{i + 1});
        const input = (try read_line(stdin, &buffer)).?;
        try list1.append(input);
    }

    for (list1.items) |e| {
        try stdout.print("{s}\n", .{e});
    }
}

fn read_line(reader: anytype, buffer: []u8) !?[]const u8 {
    const line = (try reader.readUntilDelimiterOrEof(buffer, '\n')) orelse null;
    if (@import("builtin").os.tag == .windows) return std.mem.trimRight(u8, line, "\r");
    return line;
}

test "simple test" {
    //var list = std.ArrayList(i32).init(std.testing.allocator);
    //defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    //try list.append(42);
    //try std.testing.expectEqual(@as(i32, 42), list.pop());
}
