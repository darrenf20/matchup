const trimRight = @import("std").mem.trimRight;

pub fn read_line(reader: anytype, buffer: []u8) !?[]const u8 {
    const line = (try reader.readUntilDelimiterOrEof(buffer, '\n')) orelse null;
    if (@import("builtin").os.tag == .windows) return trimRight(u8, line, "\r");
    return line;
}
