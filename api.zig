const std = @import("std");

pub const N = 256;
pub const Q = 8380417;

pub const Dilithium2 = Dilithium(.{
    .mode = 2,
    .k = 4,
    .l = 4,
    .gamma1 = 1 << 17,
    .gamma2 = (Q - 1) / 88,
    .omega = 80,
    .pk_bytes = 1312,
    .sk_bytes = 2560,
    .sig_bytes = 2420,
    .c_hash_bytes = 32,
});

pub const Dilithium3 = Dilithium(.{
    .mode = 3,
    .k = 6,
    .l = 5,
    .gamma1 = 1 << 19,
    .gamma2 = (Q - 1) / 32,
    .omega = 55,
    .pk_bytes = 1952,
    .sk_bytes = 4032,
    .sig_bytes = 3309,
    .c_hash_bytes = 48,
});

pub const Dilithium5 = Dilithium(.{
    .mode = 5,
    .k = 8,
    .l = 7,
    .gamma1 = 1 << 19,
    .gamma2 = (Q - 1) / 32,
    .omega = 75,
    .pk_bytes = 2592,
    .sk_bytes = 4896,
    .sig_bytes = 4627,
    .c_hash_bytes = 64,
});

const Params = struct {
    mode: usize,
    k: u32,
    l: u32,
    gamma1: u32,
    gamma2: u32,
    omega: u32,
    pk_bytes: usize,
    sk_bytes: usize,
    sig_bytes: usize,
    c_hash_bytes: usize,
};

fn bitlen(n: usize) usize {
    return std.math.log2_int(usize, n) + 1;
}

pub fn Dilithium(comptime p: Params) type {
    const prefix = std.fmt.comptimePrint("pqcrystals_dilithium{}_ref_", .{p.mode});
    return struct {
        fn importNs(T: type, name: []const u8) *const T {
            return @extern(*const T, .{ .name = prefix ++ name });
        }

        const poly = extern struct {
            coeffs: [N]i32,
        };

        const polyvecl = extern struct {
            vec: [p.l]poly,
        };

        const polyveck = extern struct {
            vec: [p.k]poly,
        };

        pub const SignatureState = extern struct {
            seedbuf: [192]u8,
            mat: [4]polyvecl,
            s1: polyvecl,
            y: polyvecl,
            z: polyvecl,
            t0: polyveck,
            s2: polyveck,
            w1: polyveck,
            w0: polyveck,
        };

        pub const PK_BYTES = p.pk_bytes;
        pub const SK_BYTES = p.sk_bytes;
        pub const SIG_BYTES = p.sig_bytes;
        pub const SEEDBYTES = 32;
        pub const RNDBYTES = 32;
        pub const CRHBYTES = 64;
        pub const COMMIT_HASH_BYTES = p.c_hash_bytes;
        pub const CHALLENGE_BYTES =
            (N / 8) * p.k * bitlen((Q - 1) / (2 * p.gamma2) - 1);
        pub const RESPONSE_BYTES =
            (N / 8) * p.l * (1 + bitlen(p.gamma1 - 1)) + p.omega + p.k;

        pub const keypair_internal = importNs(fn (
            pk: *[PK_BYTES]u8,
            sk: *[SK_BYTES]u8,
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

        pub const signature_init = importNs(fn (
            mu: *const [CRHBYTES]u8,
            rnd: *const [RNDBYTES]u8,
            sk: *const [SK_BYTES]u8,
        ) callconv(.c) SignatureState, "signature_init");

        pub const gen_commit = importNs(fn (
            challenge: *[CHALLENGE_BYTES]u8,
            nonce: u16,
            state: *SignatureState,
        ) callconv(.c) void, "signature_gen_commit");

        pub const confirm_response = importNs(fn (
            response: *[RESPONSE_BYTES]u8,
            commit_hash: *const [COMMIT_HASH_BYTES]u8,
            state: *SignatureState,
        ) callconv(.c) c_int, "signature_confirm_response");
    };
}
