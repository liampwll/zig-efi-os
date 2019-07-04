const Entry = union(enum) {
    const DataS = struct {
        const Self = @This();

        const Granularity = enum(u1) {
            Byte = 0,
            Page = 1,
        };

        const Direction = enum(u1) {
            Up = 0,
            Down = 1,
        };

        base: u32,
        limit: u20,
        accessed: bool,
        writable: bool,
        direction: Self.Direction,
        dpl: u4,
        present: bool,
        available_to_system_programmers: bool,
        big: bool,
        granularity: Self.Granularity,

        fn pack(self: Self) u64 {
            return u64(self.limit & 0xFFFF) << 0
                | u64(self.base & 0xFFFFFF) << 16
                | u64(@boolToInt(self.accessed)) << 40
                | u64(@boolToInt(self.writable)) << 41
                | u64(@enumToInt(self.direction)) << 42
                | 0b10 << 43
                | u64(self.dpl) << 45
                | u64(@boolToInt(self.present)) << 47
                | u64(self.limit >> 16 & 0xF) << 48
                | u64(@boolToInt(self.available_to_system_programmers)) << 52
                | 0b0 << 53
                | u64(@boolToInt(self.big)) << 54
                | u64(@enumToInt(self.granularity)) << 55
                | u64(self.base >> 24 & 0xFF) << 56;
        }
    };

    const CodeS = struct {
        const Self = @This();

        const Granularity = enum(u1) {
            Byte = 0,
            Page = 1,
        };

        const Mode = enum(u2) {
            Real = 0b00,
            Protected = 0b10,
            Long = 0b01,
        };

        base: u32,
        limit: u20,
        accessed: bool,
        readable: bool,
        conforming: bool,
        dpl: u4,
        present: bool,
        available_to_system_programmers: bool,
        mode: Self.Mode,
        granularity: Self.Granularity,

        fn pack(self: Self) u64 {
            return u64(self.limit & 0xFFFF) << 0
                | u64(self.base & 0xFFFFFF) << 16
                | u64(@boolToInt(self.accessed)) << 40
                | u64(@boolToInt(self.readable)) << 41
                | u64(@boolToInt(self.conforming)) << 42
                | 0b11 << 43
                | u64(self.dpl) << 45
                | u64(@boolToInt(self.present)) << 47
                | u64(self.limit >> 16 & 0xF) << 48
                | u64(@boolToInt(self.available_to_system_programmers)) << 52
                | u64(@enumToInt(self.mode)) << 53
                | u64(@enumToInt(self.granularity)) << 55
                | u64(self.base >> 24 & 0xFF) << 56;
        }
    };

    const SystemS = struct {
        const Self = @This();

        const Type = enum(u4) {
            Ldt = 0b0010,
            TssAvailable = 0b1001,
            TssBusy = 0b1011,
            CallGate = 0b1100,
            InterruptGate = 0b1110,
            TrapGate = 0b1111,
        };

        const Granularity = enum(u1) {
            Byte = 0,
            Page = 1,
        };

        base: u32,
        limit: u20,
        @"type": Self.Type,
        dpl: u4,
        present: bool,
        granularity: Granularity,

        fn pack(self: Self) u64 {
            return u64(self.limit & 0xFFFF) << 0
                | u64(self.base & 0xFFFFFF) << 16
                | u64(@enumToInt(self.type)) << 40
                | 0b0 << 44
                | u64(self.dpl) << 45
                | u64(@boolToInt(self.present)) << 47
                | u64(self.limit >> 16 & 0xF) << 48
                | 0b000 << 52
                | u64(@enumToInt(self.granularity)) << 55
                | u64(self.base >> 24 & 0xFF) << 56;
        }
    };

    Data: Entry.DataS,
    Code: Entry.CodeS,
    System: Entry.SystemS,

    pub fn pack(self: Entry) u64 {
        return switch (self) {
            Entry.Code => |x| x.pack(),
            Entry.Data => |x| x.pack(),
            Entry.System => |x| x.pack(),
        };
    }
};

var our_gdt = []u64{
    0,
    (Entry{ .Code = Entry.CodeS{
        .base = 0,
        .limit = 0,
        .accessed = false,
        .readable = true,
        .conforming = false,
        .dpl = 0,
        .present = true,
        .available_to_system_programmers = false,
        .mode = Entry.CodeS.Mode.Long,
        .granularity = Entry.CodeS.Granularity.Byte,
    }}).pack(),
    (Entry{ .Data = Entry.DataS{
        .base = 0,
        .limit = 0,
        .accessed = false,
        .writable = true,
        .direction = Entry.DataS.Direction.Up,
        .dpl = 0,
        .present = true,
        .available_to_system_programmers = false,
        .big = false,
        .granularity = Entry.DataS.Granularity.Byte,
    }}).pack(),
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
