#ifndef CCHECKSUM_KECCAK_H
#define CCHECKSUM_KECCAK_H

#include <stddef.h>

extern const unsigned char CKSUM_HEX_LOWER_MAP[256];
extern const unsigned char CKSUM_HEX_UPPER_MAP[256];

void keccak_256(const unsigned char* data, size_t len, unsigned char* out);

#endif
