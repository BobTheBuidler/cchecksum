#include "keccak.h"

#include <stdint.h>
#include <string.h>

#define KECCAKF_ROUNDS 24

static const uint64_t keccakf_rndc[KECCAKF_ROUNDS] = {
    0x0000000000000001ULL, 0x0000000000008082ULL,
    0x800000000000808aULL, 0x8000000080008000ULL,
    0x000000000000808bULL, 0x0000000080000001ULL,
    0x8000000080008081ULL, 0x8000000000008009ULL,
    0x000000000000008aULL, 0x0000000000000088ULL,
    0x0000000080008009ULL, 0x000000008000000aULL,
    0x000000008000808bULL, 0x800000000000008bULL,
    0x8000000000008089ULL, 0x8000000000008003ULL,
    0x8000000000008002ULL, 0x8000000000000080ULL,
    0x000000000000800aULL, 0x800000008000000aULL,
    0x8000000080008081ULL, 0x8000000000008080ULL,
    0x0000000080000001ULL, 0x8000000080008008ULL
};

static const int keccakf_rotc[KECCAKF_ROUNDS] = {
    1, 3, 6, 10, 15, 21, 28, 36, 45, 55, 2, 14,
    27, 41, 56, 8, 25, 43, 62, 18, 39, 61, 20, 44
};

static const int keccakf_piln[KECCAKF_ROUNDS] = {
    10, 7, 11, 17, 18, 3, 5, 16, 8, 21, 24, 4,
    15, 23, 19, 13, 12, 2, 20, 14, 22, 9, 6, 1
};

static inline uint64_t rotl64(uint64_t x, int s) {
    return (x << s) | (x >> (64 - s));
}

static inline uint64_t load64(const unsigned char* x) {
    return ((uint64_t)x[0]) | ((uint64_t)x[1] << 8) | ((uint64_t)x[2] << 16) |
           ((uint64_t)x[3] << 24) | ((uint64_t)x[4] << 32) |
           ((uint64_t)x[5] << 40) | ((uint64_t)x[6] << 48) |
           ((uint64_t)x[7] << 56);
}

static inline void store64(unsigned char* x, uint64_t u) {
    x[0] = (unsigned char)(u & 0xFF);
    x[1] = (unsigned char)((u >> 8) & 0xFF);
    x[2] = (unsigned char)((u >> 16) & 0xFF);
    x[3] = (unsigned char)((u >> 24) & 0xFF);
    x[4] = (unsigned char)((u >> 32) & 0xFF);
    x[5] = (unsigned char)((u >> 40) & 0xFF);
    x[6] = (unsigned char)((u >> 48) & 0xFF);
    x[7] = (unsigned char)((u >> 56) & 0xFF);
}

static void keccakf(uint64_t st[25]) {
    int i;
    int j;
    int round;
    uint64_t t;
    uint64_t bc[5];

    for (round = 0; round < KECCAKF_ROUNDS; round++) {
        for (i = 0; i < 5; i++) {
            bc[i] = st[i] ^ st[i + 5] ^ st[i + 10] ^ st[i + 15] ^ st[i + 20];
        }

        for (i = 0; i < 5; i++) {
            t = bc[(i + 4) % 5] ^ rotl64(bc[(i + 1) % 5], 1);
            for (j = 0; j < 25; j += 5) {
                st[j + i] ^= t;
            }
        }

        t = st[1];
        for (i = 0; i < KECCAKF_ROUNDS; i++) {
            j = keccakf_piln[i];
            bc[0] = st[j];
            st[j] = rotl64(t, keccakf_rotc[i]);
            t = bc[0];
        }

        for (j = 0; j < 25; j += 5) {
            for (i = 0; i < 5; i++) {
                bc[i] = st[j + i];
            }
            for (i = 0; i < 5; i++) {
                st[j + i] ^= (~bc[(i + 1) % 5]) & bc[(i + 2) % 5];
            }
        }

        st[0] ^= keccakf_rndc[round];
    }
}

void keccak_256(const unsigned char* data, size_t len, unsigned char* out) {
    uint64_t st[25];
    unsigned char temp[136];
    size_t i;
    const size_t rate = 136;

    memset(st, 0, sizeof(st));

    while (len >= rate) {
        for (i = 0; i < rate / 8; i++) {
            st[i] ^= load64(data + (i * 8));
        }
        keccakf(st);
        data += rate;
        len -= rate;
    }

    memset(temp, 0, rate);
    if (len) {
        memcpy(temp, data, len);
    }
    temp[len] = 0x01;  /* Keccak padding */
    temp[rate - 1] |= 0x80;

    for (i = 0; i < rate / 8; i++) {
        st[i] ^= load64(temp + (i * 8));
    }
    keccakf(st);

    for (i = 0; i < 4; i++) {
        store64(out + (i * 8), st[i]);
    }
}
