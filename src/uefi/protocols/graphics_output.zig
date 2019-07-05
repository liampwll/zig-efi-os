const uefi = @import("../uefi.zig");
const Guid = uefi.Guid;
const Status = uefi.Status;
const physical_addr = uefi.physical_addr;

pub const guid = Guid.guid(0x9042a9de, 0x23dc, 0x4a38, ([]u8){ 0x96, 0xfb, 0x7a, 0xde, 0xd0, 0x80, 0x51, 0x6a });

pub const PixelBitmask = extern struct {
    red_mask: u32,
    green_mask: u32,
    blue_mask: u32,
    reserved_mask: u32,
};

pub const PixelFormat = extern enum {
    RedGreenBlueReserved8BitPerColor,
    BlueGreenRedReserved8BitPerColor,
    BitMask,
    BltOnly,
};

pub const ModeInformation = extern struct {
    version: u32,
    horizontal_resolution: u32,
    vertical_resolution: u32,
    pixel_format: PixelFormat,
    pixel_information: PixelBitmask,
    pixels_per_scan_line: u32,
};

pub const Mode = extern struct {
    max_mode: u32,
    mode: u32,
    info: *ModeInformation,
    size_of_info: usize,
    frame_buffer_base: physical_addr,
    frame_buffer_size: usize,
};

pub const BltPixel = extern struct {
    blue: u8,
    green: u8,
    red: u8,
    reserved: u8,
};

pub const BltOperation = extern enum {
    VideoFill,
    VideoToBuffer,
    BufferToVideo,
    VideoToVideo,
};

pub const Protocol = extern struct {
    const Self = @This();
    queryMode: extern fn(self: *Self, mode_num: u32, info_len: *usize, info: *[*]ModeInformation) Status,
    setMode: extern fn(self: *Self, mode_num: u32) Status,
    blt: extern fn(self: *Self, blt_buf: ?[*]BltPixel, blt_operation: BltOperation, src_x: usize, src_y: usize, dest_x: usize, dest_y: usize, width: usize, height: usize, delta: usize) Status,
    mode: *Mode,
};
