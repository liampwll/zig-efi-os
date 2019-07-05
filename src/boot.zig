const std = @import("std");
const builtin = @import("builtin");
const uefi = @import("uefi/uefi.zig");
const state = @import("state.zig");
const graphics = @import("graphics.zig");
const gdt = @import("gdt.zig");

export fn EfiMain(img: uefi.Handle, sys: *uefi.SystemTable) uefi.Status {
    state.uefi_image = img;
    state.system_table = sys;

    preExitBootServices() catch |err| {
        _ = state.stdout.print("{}\n", err) catch void;

        // TODO
        // if (@errorReturnTrace()) |trace| {
        //     std.debug.dumpStackTrace(trace.*);
        // }

        while (true) {
            asm volatile ("hlt" :::);
        }
    };

    var map_key: usize = undefined;
    var desc_size: usize = undefined;
    var desc_version: u32 = undefined;
    var memory_map_size = usize(1);
    var memory_map: [*]uefi.MemoryDescriptor = undefined;
    _ = sys.boot_services.allocatePool(uefi.MemoryType.LoaderData,
                                       @sizeOf(@typeOf(memory_map)) * memory_map_size,
                                       @ptrCast(**c_void, &memory_map));
    while (sys.boot_services.getMemoryMap(&memory_map_size,
                                          memory_map,
                                          &map_key,
                                          &desc_size,
                                          &desc_version) != 0) {
        _ = sys.boot_services.freePool(memory_map);
        memory_map_size += 10;
        _ = sys.boot_services.allocatePool(uefi.MemoryType.LoaderData,
                                           @sizeOf(@typeOf(memory_map)) * memory_map_size,
                                           @ptrCast(**c_void, &memory_map));
    }

    _ = sys.boot_services.exitBootServices(img, map_key);

    postExitBootServices() catch |err| {
        _ = state.stdout.print("{}\n", err) catch void;

        // TODO
        // if (@errorReturnTrace()) |trace| {
        //     std.debug.dumpStackTrace(trace.*);
        // }

        while (true) {
            asm volatile ("hlt" :::);
        }
    };

    return @enumToInt(uefi.StatusValues.Success);
}

pub fn panic(msg: []const u8, error_return_trace: ?*builtin.StackTrace) noreturn {
    @setCold(true);

    if (!state.exited_boot_services) {
        _ = state.stdout.print("{}\n", msg) catch unreachable;
    }
    while (true) {}
}

fn preExitBootServices() error{}!void {
    _ = state.system_table.boot_services.setWatchdogTimer(0, 0, 0, null);

    var gop: *uefi.protocols.graphics_output.Protocol = undefined;
    _ = state.system_table.boot_services.locateProtocol(&uefi.protocols.graphics_output.guid, null, @ptrCast(*?*c_void, &gop));

    const frame = graphics.Frame{
        .info = gop.mode.info.*,
        .frame_buffer = @intToPtr([*]u8, gop.mode.frame_buffer_base),
    };
    var fg = graphics.Pixel{
        .blue = 255,
        .green = 255,
        .red = 255,
    };
    const bg = graphics.Pixel{
        .blue = 0,
        .green = 0,
        .red = 0,
    };
    state.stdout = graphics.TextFrame.init(frame, fg, bg);
}

fn postExitBootServices() error{}!void {
    _ = state.stdout.print("old gdt len: {}\n", gdt.storeGdt().len) catch unreachable;
    gdt.loadGdt(gdt.our_gdt[0..], 1, 2);
    _ = state.stdout.print("new gdt len: {}\n", gdt.storeGdt().len) catch unreachable;

    while (true) {
        asm volatile ("hlt" :::);
    }
}
