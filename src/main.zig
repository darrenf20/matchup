const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList([]const u8);
const expect = std.testing.expect;
const read_line_or_null = @import("utility").read_line_or_null;

// Global state
const stdout = std.io.getStdOut().writer();
const stderr = std.io.getStdErr().writer();
var buffer: [128]u8 = undefined;

pub fn main() !void {
    //try bw.flush(); // don't forget to flush!

    //
    // ** Setup **
    //

    // Prepare the memory allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        const deinit_status = gpa.deinit();
        if (deinit_status == .leak) expect(false) catch @panic("MEMORY LEAKED");
    }

    // Each element in list1 will be matched with an element in list2
    var list1 = List.init(allocator);
    var list2 = List.init(allocator);
    defer {
        for (list1.items) |item| allocator.free(item);
        for (list2.items) |item| allocator.free(item);
        list1.deinit();
        list2.deinit();
    }

    //
    // ** Get lists from user
    //

    // Either process a file if one is given, or prompt the user to give list items
    const argv: [][:0]u8 = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, argv);

    if (argv.len > 1) {
        try get_lists_from_file(allocator, argv[1], &list1, &list2);
    } else {
        try get_lists_from_user(allocator, &list1, &list2);
    }

    //
    // ** Randomly assign elements to each other **
    //

    var prng = std.rand.DefaultPrng.init(prng: {
        var seed: u64 = undefined;
        try std.posix.getrandom(std.mem.asBytes(&seed));
        break :prng seed;
    });
    const rand = prng.random();

    for (0..list1.items.len) |i| {
        const k = rand.intRangeLessThan(usize, i, list1.items.len);
        std.mem.swap([]const u8, &list2.items[i], &list2.items[k]);
    }

    for (list1.items, list2.items) |a, b| {
        try stdout.print("{s} --> {s}\n", .{ a, b });
    }
}

fn get_lists_from_file(allocator: Allocator, path: []const u8, list1: *List, list2: *List) !void {
    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();
    const reader = file.reader();

    var i: usize = 0;
    while (try get_line(allocator, list1, reader) and !std.mem.eql(u8, list1.getLast(), "")) {
        i += 1;
    }
    _ = list1.pop();

    var j: usize = 0;
    while (try get_line(allocator, list2, reader) and !std.mem.eql(u8, list2.getLast(), "")) {
        j += 1;
    }
    if (std.mem.eql(u8, list2.getLast(), "")) _ = list2.pop();

    if (i != j) {
        try stderr.print("Error: list sizes do not match\n", .{});
        std.process.exit(1);
    }
}

fn get_lists_from_user(allocator: Allocator, list1: *List, list2: *List) !void {
    const stdin = std.io.getStdIn().reader();

    try stdout.print("-- List A --\n", .{});

    // Get user input until they enter an empty string
    var i: usize = 0;
    while (i == 0 or !std.mem.eql(u8, list1.getLast(), "")) : (i += 1) {
        try stdout.print("#{d}: ", .{i + 1});
        _ = try get_line(allocator, list1, stdin);
    }
    _ = list1.pop(); // remove empty string from list

    try stdout.print("-- List B --\n", .{});

    for (0..list1.items.len) |j| {
        try stdout.print("#{d} / {d}: ", .{ j, list1.items.len });
        _ = try get_line(allocator, list2, stdin);
    }
}

fn get_line(allocator: Allocator, list: *List, reader: anytype) !bool {
    // Read user input into buffer
    const input = try read_line_or_null(reader, &buffer);

    return if (input) |line| blk: {
        // Need to copy the text in buffer, then append the copy to the list
        const copy = try std.fmt.allocPrint(allocator, "{s}", .{line});
        errdefer allocator.free(copy);

        try list.append(copy);

        break :blk true;
    } else false;
}

test "simple test" {
    //var list = std.ArrayList(i32).init(std.testing.allocator);
    //defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    //try list.append(42);
    //try std.testing.expectEqual(@as(i32, 42), list.pop());
}
