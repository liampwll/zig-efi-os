const uefi = @import("../uefi.zig");
const Header = @import("header.zig").Header;
const NotYetImplementedFn = uefi.NotYetImplementedFn;

pub const RuntimeServices = extern struct {
    pub const signature = 0x56524553544e5552;
    hdr: Header,
    get_time: NotYetImplementedFn,
    set_time: NotYetImplementedFn,
    get_wakeup_time: NotYetImplementedFn,
    set_wakeup_time: NotYetImplementedFn,
    set_virtual_address_map: NotYetImplementedFn,
    convert_pointer: NotYetImplementedFn,
    get_variable: NotYetImplementedFn,
    get_next_variable_name: NotYetImplementedFn,
    set_variable: NotYetImplementedFn,
    get_next_high_monotonic_count: NotYetImplementedFn,
    reset_system: NotYetImplementedFn,
    update_capsule: NotYetImplementedFn,
    query_capsule_capabilities: NotYetImplementedFn,
    query_variable_info: NotYetImplementedFn,
};
