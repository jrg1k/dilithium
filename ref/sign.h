#ifndef SIGN_H
#define SIGN_H

#include <stddef.h>
#include <stdint.h>
#include "fips202.h"
#include "params.h"
#include "polyvec.h"
#include "poly.h"

#define crypto_sign_keypair DILITHIUM_NAMESPACE(keypair)
int crypto_sign_keypair(uint8_t *pk, uint8_t *sk);

#define crypto_sign_keypair_internal DILITHIUM_NAMESPACE(keypair_internal)
int crypto_sign_keypair_internal(uint8_t *pk, uint8_t *sk, const uint8_t seed[SEEDBYTES]);

#define crypto_sign_signature_internal DILITHIUM_NAMESPACE(signature_internal)
int crypto_sign_signature_internal(uint8_t *sig,
                                   size_t *siglen,
                                   const uint8_t *m,
                                   size_t mlen,
                                   const uint8_t *pre,
                                   size_t prelen,
                                   const uint8_t rnd[RNDBYTES],
                                   const uint8_t *sk);

typedef struct {
  uint8_t key[SEEDBYTES];
  uint8_t rho[SEEDBYTES];
  polyvecl mat[K];
  polyvecl s1;
  polyveck s2, t1, t0;
} KeyPair;

#define crypto_sign_keypair_raw DILITHIUM_NAMESPACE(keypair_raw)
KeyPair crypto_sign_keypair_raw(const uint8_t seed[SEEDBYTES]);

typedef struct {
  uint8_t seedbuf[2*SEEDBYTES + TRBYTES + CRHBYTES];
  polyvecl mat[K], s1, y, z;
  polyveck t0, s2, w1, w0;
} SignatureState;


#define crypto_sign_signature_init DILITHIUM_NAMESPACE(signature_init)
SignatureState crypto_sign_signature_init(
        const uint8_t mu[CRHBYTES],
        const uint8_t rnd[RNDBYTES],
        const uint8_t sk[CRYPTO_SECRETKEYBYTES]);

#define crypto_sign_signature_gen_commit DILITHIUM_NAMESPACE(signature_gen_commit)
void crypto_sign_signature_gen_commit(
        uint8_t challenge[CRYPTO_CHALLENGE_BYTES],
        uint16_t nonce,
        SignatureState *state);

#define crypto_sign_signature_confirm_response DILITHIUM_NAMESPACE(signature_confirm_response)
int crypto_sign_signature_confirm_response(
        uint8_t response[CRYPTO_RESPONSE_BYTES],
        const uint8_t commit_hash[CTILDEBYTES],
        SignatureState *state);

#define crypto_sign_signature DILITHIUM_NAMESPACE(signature)
int crypto_sign_signature(uint8_t *sig, size_t *siglen,
                          const uint8_t *m, size_t mlen,
                          const uint8_t *ctx, size_t ctxlen,
                          const uint8_t *sk);

#define crypto_sign DILITHIUM_NAMESPACETOP
int crypto_sign(uint8_t *sm, size_t *smlen,
                const uint8_t *m, size_t mlen,
                const uint8_t *ctx, size_t ctxlen,
                const uint8_t *sk);

#define crypto_sign_verify_internal DILITHIUM_NAMESPACE(verify_internal)
int crypto_sign_verify_internal(const uint8_t *sig,
                                size_t siglen,
                                const uint8_t *m,
                                size_t mlen,
                                const uint8_t *pre,
                                size_t prelen,
                                const uint8_t *pk);

#define crypto_sign_verify DILITHIUM_NAMESPACE(verify)
int crypto_sign_verify(const uint8_t *sig, size_t siglen,
                       const uint8_t *m, size_t mlen,
                       const uint8_t *ctx, size_t ctxlen,
                       const uint8_t *pk);

#define crypto_sign_open DILITHIUM_NAMESPACE(open)
int crypto_sign_open(uint8_t *m, size_t *mlen,
                     const uint8_t *sm, size_t smlen,
                     const uint8_t *ctx, size_t ctxlen,
                     const uint8_t *pk);

#endif
