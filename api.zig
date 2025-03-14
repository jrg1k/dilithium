const std = @import("std");

pub const Dilithium2 = Dilithium(.{
    .mode = 2,
    .pk_bytes = 1312,
    .sk_bytes = 2560,
    .sig_bytes = 2420,
});

pub const Dilithium3 = Dilithium(.{
    .mode = 3,
    .pk_bytes = 1952,
    .sk_bytes = 4032,
    .sig_bytes = 3309,
});

pub const Dilithium5 = Dilithium(.{
    .mode = 5,
    .pk_bytes = 2592,
    .sk_bytes = 4896,
    .sig_bytes = 4627,
});

const Params = struct {
    mode: usize,
    pk_bytes: usize,
    sk_bytes: usize,
    sig_bytes: usize,
};

pub fn Dilithium(comptime params: Params) type {
    const prefix = std.fmt.comptimePrint("pqcrystals_dilithium{}_ref_", .{params.mode});
    return struct {
        fn importNs(T: type, name: []const u8) *const T {
            return @extern(*const T, .{ .name = prefix ++ name });
        }

        pub const PK_BYTES = params.pk_bytes;
        pub const SK_BYTES = params.sk_bytes;
        pub const SIG_BYTES = params.sig_bytes;
        pub const SEEDBYTES = 32;
        pub const RNDBYTES = 32;

        pub const keypair_internal = importNs(fn (
            pk: *const [PK_BYTES]u8,
            sk: *const [SK_BYTES]u8,
            seed: *const [SEEDBYTES]u8,
        ) callconv(.c) c_int, "keypair_internal");

        pub const signature_internal = importNs(fn (
            sig: *[SIG_BYTES]u8,
            siglen: *usize,
            m: [*]const u8,
            mlen: usize,
            pre: ?[*]const u8,
            prelen: usize,
            rnd: *const [RNDBYTES]u8,
            sk: *const [SK_BYTES]u8,
        ) callconv(.c) c_int, "signature_internal");

        pub const verify_internal = importNs(fn (
            sig: *const [SIG_BYTES]u8,
            siglen: usize,
            m: [*]const u8,
            mlen: usize,
            pre: ?[*]const u8,
            prelen: usize,
            pk: *const [PK_BYTES]u8,
        ) callconv(.c) c_int, "verify_internal");
    };
}
