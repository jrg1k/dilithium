#![cfg_attr(not(test), no_std)]

use core::slice;

use rand::RngCore;

#[unsafe(no_mangle)]
extern "C" fn xmemcpy(
    dst: *mut core::ffi::c_char,
    src: *const core::ffi::c_char,
    n: usize,
) -> *mut core::ffi::c_char {
    unsafe { core::ptr::copy_nonoverlapping(src, dst, n) };

    dst
}

#[unsafe(no_mangle)]
pub fn randombytes(out: *mut u8, outlen: usize) {
    rand::rng().fill_bytes(unsafe { slice::from_raw_parts_mut(out, outlen) });
}

#[allow(non_upper_case_globals)]
#[allow(non_camel_case_types)]
#[allow(non_snake_case)]
pub mod dilithium2_sys {
    include!(concat!(env!("OUT_DIR"), "/dilithium2_bindings.rs"));
}

#[allow(non_upper_case_globals)]
#[allow(non_camel_case_types)]
#[allow(non_snake_case)]
pub mod dilithium3_sys {
    include!(concat!(env!("OUT_DIR"), "/dilithium3_bindings.rs"));
}

#[allow(non_upper_case_globals)]
#[allow(non_camel_case_types)]
#[allow(non_snake_case)]
pub mod dilithium5_sys {
    include!(concat!(env!("OUT_DIR"), "/dilithium5_bindings.rs"));
}

#[cfg(test)]
mod tests {
    use std::ptr::null;

    use rand::TryRngCore;

    use crate::dilithium2_sys::{self};

    #[test]
    fn basic() {
        let mut rng = rand::rng();
        let mut pk = [0u8; dilithium2_sys::CRYPTO_PUBLICKEYBYTES as usize];
        let mut sk = [0u8; dilithium2_sys::CRYPTO_SECRETKEYBYTES as usize];
        let mut seed = [0u8; dilithium2_sys::SEEDBYTES as usize];
        _ = rng.try_fill_bytes(&mut seed);

        unsafe {
            #[cfg_attr(miri, ignore)]
            dilithium2_sys::pqcrystals_dilithium2_ref_keypair_internal(
                pk.as_mut_ptr(),
                sk.as_mut_ptr(),
                seed.as_ptr(),
            )
        };

        let msg = "hello there";
        let mut sig = [0u8; dilithium2_sys::CRYPTO_BYTES as usize];
        let mut siglen: usize = 0;
        let mut rnd = [0u8; dilithium2_sys::RNDBYTES as usize];
        _ = rng.try_fill_bytes(&mut rnd);

        unsafe {
            dilithium2_sys::pqcrystals_dilithium2_ref_signature_internal(
                sig.as_mut_ptr(),
                &raw mut siglen,
                msg.as_ptr(),
                msg.len(),
                null(),
                0,
                rnd.as_ptr(),
                sk.as_ptr(),
            )
        };

        let res = unsafe {
            dilithium2_sys::pqcrystals_dilithium2_ref_verify_internal(
                sig.as_ptr(),
                siglen,
                msg.as_ptr(),
                msg.len(),
                null(),
                0,
                pk.as_ptr(),
            )
        };

        assert_eq!(res, 0);
    }
}
