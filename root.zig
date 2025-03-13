const std = @import("std");

export fn randombytes(out: [*]u8, outlen: usize) void {
    std.crypto.random.bytes(out[0..outlen]);
}

export fn xmemcpy(noalias dst: [*]u8, noalias src: [*]const u8, n: usize) [*]u8 {
    @memcpy(dst[0..n], src[0..n]);
    return dst;
}
