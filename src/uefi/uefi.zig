pub const NotYetImplementedFn = extern fn() void;

pub const Guid = extern struct {
    pub fn guid(data1: u32, data2: u16, data3: u16, data4: [8]u8) Guid {
        return Guid {
            .data1 = data1,
            .data2 = data2,
            .data3 = data3,
            .data4 = data4
        };
    }

    data1: u32,
    data2: u16,
    data3: u16,
    data4: [8]u8,
};

pub const physical_addr = u64;

pub const virtual_addr = u64;

pub const Event = *@OpaqueType();

pub const ucs2 = u16;

pub const Handle = *@OpaqueType();

pub const SystemTable = @import("tables/system_table.zig").SystemTable;
pub const BootServices = @import("tables/boot_services.zig").BootServices;
pub const RuntimeServices = @import("tables/runtime_services.zig").RuntimeServices;
pub const ConfigurationTable = @import("tables/configuration_table.zig").ConfigurationTable;

pub const protocols = @import("protocols.zig");

fn set_high_bit(comptime err_code: usize) usize {
    return err_code | (1 << @sizeOf(usize));
}

pub const MemoryType = extern enum {
    ReservedMemoryType,
    LoaderCode,
    LoaderData,
    BootServicesCode,
    BootServicesData,
    RuntimeServicesCode,
    RuntimeServicesData,
    ConventionalMemory,
    UnusableMemory,
    ACPIReclaimMemory,
    ACPIMemoryNVS,
    MemoryMappedIO,
    MemoryMappedIOPortSpace,
    PalCode,
    PersistentMemory,
    MaxMemoryType,
};

pub const MemoryAttribute = extern enum(u64) {
    Uc = 0x0000000000000001,
    Wc = 0x0000000000000002,
    Wt = 0x0000000000000004,
    Wb = 0x0000000000000008,
    Uce = 0x0000000000000010,
    Wp = 0x0000000000001000,
    Rp = 0x0000000000002000,
    Xp = 0x0000000000004000,
    Nv = 0x0000000000008000,
    MoreReliable = 0x0000000000010000,
    Ro = 0x0000000000020000,
    Runtime = 0x8000000000000000,
};

pub const MemoryDescriptor = extern struct {
    type: MemoryType,
    physical_start: physical_addr,
    virtual_start: virtual_addr,
    number_of_pages: u64,
    attribute: MemoryAttribute,
};

pub const Status = usize;
pub const StatusValues = enum(Status) {
    Success = 0,
    LoadError = set_high_bit(1),
    InvalidParameter = set_high_bit(2),
    Unsupported = set_high_bit(3),
    BadBufferSize = set_high_bit(4),
    BufferTooSmall = set_high_bit(5),
    NotReady = set_high_bit(6),
    DeviceError = set_high_bit(7),
    WriteProtected = set_high_bit(8),
    OutOfResources = set_high_bit(9),
    VolumeCorrupted = set_high_bit(10),
    VolumeFull = set_high_bit(11),
    NoMedia = set_high_bit(12),
    MediaChanged = set_high_bit(13),
    NotFound = set_high_bit(14),
    AccessDenied = set_high_bit(15),
    NoResponse = set_high_bit(16),
    NoMapping = set_high_bit(17),
    Timeout = set_high_bit(18),
    NotStarted = set_high_bit(19),
    AlreadyStarted = set_high_bit(20),
    Aborted = set_high_bit(21),
    IcmpError = set_high_bit(22),
    TftpError = set_high_bit(23),
    ProtocolError = set_high_bit(24),
    IncompatibleVersion = set_high_bit(25),
    SecurityViolation = set_high_bit(26),
    CrcError = set_high_bit(27),
    EndOfMedia = set_high_bit(28),
    EndOfFile = set_high_bit(31),
    InvalidLanguage = set_high_bit(32),
    CompromisedData = set_high_bit(33),
    IpAddressConflict = set_high_bit(34),
    HttpError = set_high_bit(35),
};
