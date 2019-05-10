const std = @import("std");
const uefi = @import("../uefi.zig");
const Guid = uefi.Guid;
const ucs2 = uefi.ucs2;
const Status = uefi.Status;

pub const guid = uefi.Guid{ 0x387477c2, 0x69c7, 0x11d2, ([]u8){ 0x8e, 0x39, 0x00, 0xa0, 0xc9, 0x69, 0x72, 0x3b } };

pub const Mode = extern struct {
    max_mode: i32,
    mode: i32,
    attribute: i32,
    cursor_column: i32,
    cursor_row: i32,
    cursor_visible: bool,
};

pub const Protocol = extern struct {
    const Self = @This();

    pub fn print(self: *Self, comptime format: []const u8, args: ...) error{}!void {
        return std.fmt.format(self, error{}, output, format, args);
    }

    pub fn dumb_print(self: *Self, str: []const u8) void {
        _ = output(self, str) catch unreachable;
    }

    reset: extern fn (self: *Self, extended_verification: bool) Status,
    output_string: extern fn (self: *Self, string: [*]ucs2) Status,
    test_string: extern fn (self: *Self, string: [*]ucs2) Status,
    query_mode: extern fn (self: *Self, mode_num: usize, cols: *usize, rows: *usize) Status,
    set_mode: extern fn (self: *Self, mode_num: usize) Status,
    set_attribute: extern fn (self: *Self, attribute: usize) Status,
    clear_screen: extern fn (self: *Self) Status,
    set_cursor_position: extern fn (self: *Self, col: usize, row: usize) Status,
    enable_cursor: extern fn (self: *Self, visible: bool) Status,
    mode: *Mode,
};

// TODO: Why can't this be inside the struct?
fn output(p: *Protocol, bytes: []const u8) error{}!void {
    // TODO: convert to ucs-2 properly
    for (bytes) |x| {
        _ = p.output_string(p, &([]ucs2){x, 0});
    }
}
