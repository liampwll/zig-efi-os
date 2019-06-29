const std = @import("std");
const builtin = @import("builtin");
const AtomicOrder = builtin.AtomicOrder;
const state = @import("state.zig");

const Flags = struct {
     const accessed = u64(1 << 40);
     const code_readable = u64(1 << 41);
     const data_writable = u64(1 << 41);
     const code_conforming = u64(1 << 42);
     const data_grows_down = u64(1 << 42);
     const is_code = u64(1 << 43 | 1 << 44);
     const is_data = u64(1 << 44);
     const dpl1 = u64(1 << 45);
     const dpl2 = u64(1 << 46);
     const dpl3 = u64(1 << 45 | 1 << 46);
     const present = u64(1 << 47);
     const available_to_system_programmers = u64(1 << 52);
     const long_mode = u64(1 << 53);
     const code_default = u64(1 << 54);
     const data_big = u64(1 << 54);
     const page_granularity = u64(1 << 55);
};

var our_gdt = []u64{
    0,
    Flags.is_code
        | Flags.code_readable
        | Flags.long_mode
        | Flags.present,
   Flags.is_data
        | Flags.data_writable
        | Flags.present,
};

const Gdtr = extern struct {
    padding1: u32,
    padding2: u16,
    limit: u16,
    // base: [*]align(@alignOf(u64)) Entry,
    base: [*]u64,
};

var our_gdtr = Gdtr{
    .padding1 = 0,
    .padding2 = 0,
    .limit = @sizeOf(@typeOf(our_gdt)) - 1,
    .base = &our_gdt
};

pub fn storeGdt() []u64 {
    var gdtr: Gdtr = Gdtr{
        .padding1 = 0,
        .padding2 = 0,
        .limit = 0,
        .base = &our_gdt
    };
    storeGdtInternal(&gdtr);
    return gdtr.base[0..((gdtr.limit + 1) / @sizeOf(u64))];
}

pub fn loadGdt() void {
    loadGdtInternal(&our_gdtr, 1 * 8, 2 * 8);
}


const storeGdtInternal = gdt_storeGdtInternal;
const loadGdtInternal = gdt_loadGdtInternal;

extern fn gdt_storeGdtInternal(r: *Gdtr) void;
extern fn gdt_loadGdtInternal(r: *Gdtr, cs: u16, ds: u16) void;
