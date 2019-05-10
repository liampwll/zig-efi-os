const Guid = @import("../uefi.zig").Guid;

pub const ConfigurationTable = extern struct {
    vendor_guid: Guid,
    vendor_table: *c_void
};
