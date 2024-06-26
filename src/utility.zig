const trimRight = @import("std").mem.trimRight;

pub fn read_line_or_null(reader: anytype, buffer: []u8) !?[]const u8 {
    const line = try reader.readUntilDelimiterOrEof(buffer, '\n');
    if (@import("builtin").os.tag == .windows) return trimRight(u8, line, "\r");
    return line;
}
