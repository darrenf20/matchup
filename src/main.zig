const std = @import("std");
const expect = std.testing.expect;
const read_line = @import("utility").read_line;

pub fn main() !void {
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

    // Each element in list1 will be matched with an element in list2
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

    // Create an `args` tuple to pass into the `get_list` function
    const args = .{
        .allocator = allocator,
        .stdin = stdin,
        .buffer = &buffer,
    };

    //
    // ** GETTING LISTS **
    //

    try stdout.print("-- List A --\n", .{});

    // Get user input until they enter an empty string
    var i: usize = 0;
    while (i == 0 or !std.mem.eql(u8, list1.getLast(), "")) : (i += 1) {
        try stdout.print("#{d}: ", .{i + 1});
        try get_list(&list1, args);
    }

    // Last list element will be the empty string, so remove it
    _ = list1.pop();

    try stdout.print("-- List B --\n", .{});

    for (0..list1.items.len) |j| {
        try stdout.print("#{d} / {d}: ", .{ j, list1.items.len });
        try get_list(&list2, args);
    }

    //
    // ** RANDOMLY ASSIGN ELEMENTS TO EACH OTHER **
    //

    for (list1.items) |item| try stdout.print("{s}\n", .{item});
    try stdout.print("\n", .{});
    for (list2.items) |item| try stdout.print("{s}\n", .{item});
}

fn get_list(list: *std.ArrayList([]const u8), args: anytype) !void {
    // Read user input into buffer
    const input = (try read_line(args.stdin, args.buffer)).?;

    // Need to copy the text in buffer, then append the copy to the list
    const copy = try std.fmt.allocPrint(args.allocator, "{s}", .{input});
    errdefer args.allocator.free(copy);

    try list.append(copy);
}

test "simple test" {
    //var list = std.ArrayList(i32).init(std.testing.allocator);
    //defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    //try list.append(42);
    //try std.testing.expectEqual(@as(i32, 42), list.pop());
}
