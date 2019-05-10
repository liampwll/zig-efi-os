const std = @import("std");
const min = std.math.min;
const uefi = @import("uefi/uefi.zig");
const graphics_output = uefi.protocols.graphics_output;

pub const Pixel = struct {
        red: u8,
        blue: u8,
        green: u8
};

pub const Frame = struct {
    const Self = @This();

    pub info: graphics_output.ModeInformation,
    pub frame_buffer: [*]u8,

    pub fn getPixel(self: *Self, x: usize, y: usize) Pixel {
        // TODO
        return Pixel{
            .red = 0,
            .blue = 0,
            .green = 0
        };
    }

    pub fn drawPixel(self: *Self, pixel: Pixel, x: usize, y: usize) void {
        const PixelFormat = graphics_output.PixelFormat;

        const start = 4 * (y * self.info.pixels_per_scan_line + x);
        const fb_pixel = self.frame_buffer[start..start + 4];

        switch (self.info.pixel_format) {
            PixelFormat.RedGreenBlueReserved8BitPerColor => {
                fb_pixel[0] = pixel.red;
                fb_pixel[1] = pixel.green;
                fb_pixel[2] = pixel.blue;
            },
            PixelFormat.BlueGreenRedReserved8BitPerColor => {
                fb_pixel[0] = pixel.blue;
                fb_pixel[1] = pixel.green;
                fb_pixel[2] = pixel.red;
            },
            PixelFormat.BitMask => {
                // TODO
            },
            PixelFormat.BltOnly => {
                // TODO
            }
        }
    }
};

pub const TextFrame = struct {
    const Self = @This();

    pub frame: Frame,
    pub foreground: Pixel,
    pub background: Pixel,

    cursor_x: u32,
    cursor_y: u32,
    max_x: u32,
    max_y: u32,

    pub fn init(frame: Frame, foreground: Pixel, background: Pixel) Self {
        var retval = Self{
            .frame = frame,
            .foreground = foreground,
            .background = background,
            .cursor_x = 0,
            .cursor_y = 0,
            .max_x = frame.info.horizontal_resolution / (unifont_width),
            .max_y = frame.info.vertical_resolution / (unifont_height),
        };
        if (retval.max_x != 0) {
            retval.max_x -= 1;
        }
        if (retval.max_y != 0) {
            retval.max_y -= 1;
        }

        return retval;
    }

    pub fn print(self: *Self, comptime format: []const u8, args: ...) error{}!void {
        return std.fmt.format(self, error{}, putChar, format, args);
    }

    fn drawChar(self: *Self, char: u8) void {
        for (unifont[char]) |line, i| {
            for (line) |pixel, j| {
                self.frame.drawPixel(if (pixel) self.foreground else self.background,
                                     self.cursor_x * unifont_width + j,
                                     self.cursor_y * unifont_height + i);
            }
        }
    }

    fn newLine(self: *Self) void {
        self.cursor_x = 0;
        if (self.cursor_y < self.max_y) {
            self.cursor_y += 1;
        } else {
            {
                var i = u32(unifont_height);
                while (i < self.frame.info.vertical_resolution - unifont_height) : (i += 1) {
                    var j = u32(0);
                    while (j < self.frame.info.horizontal_resolution) : (j += 1) {
                        const new = 4 * (i * self.frame.info.pixels_per_scan_line + j);
                        const old = 4 * ((unifont_height + i) * self.frame.info.pixels_per_scan_line + j);
                        var k = u32(0);
                        while (k < 4) : (k += 1) {
                            self.frame.frame_buffer[new + k] = self.frame.frame_buffer[old + k];
                        }
                    }
                }
            }

            {
                var i = u32(self.max_y * unifont_height);
                while (i < self.frame.info.vertical_resolution) : (i += 1) {
                    var j = u32(0);
                    while (j < self.frame.info.horizontal_resolution) : (j += 1) {
                        self.frame.drawPixel(self.background, i, j);
                    }
                }
            }
        }
    }
};

fn putChar(self: *TextFrame, text: []const u8) error{}!void {
    for (text) |char| {
        switch (char) {
            '\r' => {
                self.cursor_x = 0;
            },
            '\n' => {
                self.newLine();
            },
            else => {
                if (self.cursor_x == self.max_x) {
                    self.newLine();
                }
                self.drawChar(char);
                self.cursor_x += 1;
            }
        }
    }
}

const unifont_width = 8;
const unifont_height = 16;
const unifont = init: {
    @setEvalBranchQuota(100000);

    const data = @embedFile("../zap-vga16.psf")[4..];
    var retval: [256][16][8]bool = undefined;

    for (retval) |*char, i| {
        for (char) |*line, j| {
            for (line) |*pixel, k| {
                pixel.* = data[i * 16 + j] & 0b10000000 >> k != 0;
            }
        }
    }

    break :init retval;
};
