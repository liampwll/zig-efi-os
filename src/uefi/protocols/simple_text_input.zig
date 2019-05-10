const uefi = @import("../uefi.zig");
const Guid = uefi.Guid;
const ucs2 = uefi.ucs2;
const Status = uefi.Status;
const Event = uefi.Event;

pub const guid = uefi.Guid{ 0x387477c1, 0x69c7, 0x11d2, ([]u8){ 0x8e, 0x39, 0x00, 0xa0, 0xc9, 0x69, 0x72, 0x3b } };

pub const InputKey = extern struct {
    scan_code: u16,
    unicode_char: ucs2,
};

pub const Protocol = extern struct {
    const Self = @This();
    reset: extern fn (self: *Self, extendend_verification: bool) Status,
    read_key_stroke: extern fn (self: *Self, key: *InputKey) Status,
    wait_for_key: Event,
};
