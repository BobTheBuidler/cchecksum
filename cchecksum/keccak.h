#ifndef CCHECKSUM_KECCAK_H
#define CCHECKSUM_KECCAK_H

#include <stddef.h>

void keccak_256(const unsigned char* data, size_t len, unsigned char* out);

#endif
