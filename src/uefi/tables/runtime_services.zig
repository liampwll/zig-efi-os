const uefi = @import("../uefi.zig");
const Header = @import("header.zig").Header;
const NotYetImplementedFn = uefi.NotYetImplementedFn;

pub const RuntimeServices = extern struct {
    pub const signature = 0x56524553544e5552;
    hdr: Header,
    getTime: NotYetImplementedFn,
    setTime: NotYetImplementedFn,
    getWakeupTime: NotYetImplementedFn,
    setWakeupTime: NotYetImplementedFn,
    setVirtualAddressMap: NotYetImplementedFn,
    convertPointer: NotYetImplementedFn,
    getVariable: NotYetImplementedFn,
    getNextVariableName: NotYetImplementedFn,
    setVariable: NotYetImplementedFn,
    getNextHighMonotonicCount: NotYetImplementedFn,
    resetSystem: NotYetImplementedFn,
    updateCapsule: NotYetImplementedFn,
    queryCapsuleCapabilities: NotYetImplementedFn,
    queryVariableInfo: NotYetImplementedFn,
};
