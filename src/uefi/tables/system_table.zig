const uefi = @import("../uefi.zig");
const Header = @import("header.zig").Header;
const ucs2 = uefi.ucs2;
const protocols = uefi.protocols;
const RuntimeServices = uefi.RuntimeServices;
const BootServices = uefi.BootServices;
const ConfigurationTable = uefi.ConfigurationTable;
const Handle = uefi.Handle;

pub const SystemTable = extern struct {
    hdr: Header,
    firmware_vendor: [*]ucs2,
    firmware_revision: u32,
    console_in_handle: Handle,
    con_in: *protocols.simple_text_input.Protocol,
    console_out_handle: Handle,
    con_out: *protocols.simple_text_output.Protocol,
    standard_error_handle: Handle,
    std_err: *protocols.simple_text_output.Protocol,
    runtime_services: *RuntimeServices,
    boot_services: *BootServices,
    number_of_table_entries: usize,
    configuration_table: [*]ConfigurationTable,
};
