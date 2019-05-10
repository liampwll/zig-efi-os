const uefi = @import("uefi/uefi.zig");
const graphics = @import("graphics.zig");

pub var uefi_image: uefi.Handle = undefined;
pub var system_table: *uefi.SystemTable = undefined;
pub var exited_boot_services = false;
pub var stdout: graphics.TextFrame = undefined;
