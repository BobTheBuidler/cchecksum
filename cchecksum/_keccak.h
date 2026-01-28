#ifndef CCHECKSUM_KECCAK_H
#define CCHECKSUM_KECCAK_H

extern const unsigned char CKSUM_HEX_LOWER_MAP[256];
extern const unsigned char CKSUM_HEX_UPPER_MAP[256];

void keccak_256_40(const unsigned char* data, unsigned char* out);

#endif
