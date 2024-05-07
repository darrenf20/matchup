const std = @import("std");
const expect = std.testing.expect;
const read_line = @import("utility").read_line;

pub fn main() !void {
    //std.debug.print("All your {s} are belong to us.\n", .{"codebase"});
    //const stdout_file = std.io.getStdOut().writer();
    //var bw = std.io.bufferedWriter(stdout_file);
    //const stdout = bw.writer();
    //try stdout.print("Run `zig build test` to run the tests.\n", .{});
    //try bw.flush(); // don't forget to flush!

    //
    // ** SETUP **
    //

    // Prepare the memory allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        const deinit_status = gpa.deinit();
        if (deinit_status == .leak) expect(false) catch @panic("TEST FAIL");
    }

    // Each element in list1 will be matched with an element in list2 (bijection)
    var list1 = std.ArrayList([]const u8).init(allocator);
    var list2 = std.ArrayList([]const u8).init(allocator);
    defer {
        for (list1.items) |item| allocator.free(item);
        for (list2.items) |item| allocator.free(item);
        list1.deinit();
        list2.deinit();
    }

    // Reading from stdin, writing to stdout
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();
    var buffer: [128]u8 = undefined;

    //
    // ** APP **
    //

    try stdout.print("-- List A --\n", .{});

    var i: usize = 0;

    while (i == 0 or !std.mem.eql(u8, list1.getLast(), "")) : (i += 1) {
        try stdout.print("#{d}: ", .{i + 1});

        // Read user input into buffer
        const input = (try read_line(stdin, &buffer)).?;

        // Need to copy the text in buffer, then append the copy to the list
        const copy = try std.fmt.allocPrint(allocator, "{s}", .{input});
        errdefer allocator.free(copy);

        try list1.append(copy);
    }

    for (list1.items) |e| {
        try stdout.print("{s}\n", .{e});
    }
}

test "simple test" {
    //var list = std.ArrayList(i32).init(std.testing.allocator);
    //defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    //try list.append(42);
    //try std.testing.expectEqual(@as(i32, 42), list.pop());
}
