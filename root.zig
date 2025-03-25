const std = @import("std");

pub const dilithium2 = @cImport({
    @cDefine("DILITHIUM_MODE", "2");
    @cInclude("sign.h");
});

pub const dilithium3 = @cImport({
    @cDefine("DILITHIUM_MODE", "3");
    @cInclude("sign.h");
});

pub const dilithium5 = @cImport({
    @cDefine("DILITHIUM_MODE", "5");
    @cInclude("sign.h");
});

export fn randombytes(out: [*]u8, outlen: usize) void {
    std.crypto.random.bytes(out[0..outlen]);
}

export fn xmemcpy(noalias dst: [*]u8, noalias src: [*]const u8, n: usize) [*]u8 {
    @memcpy(dst[0..n], src[0..n]);
    return dst;
}
