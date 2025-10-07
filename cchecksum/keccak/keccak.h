// keccak.h
#ifndef C_CHECKSUM_KECCAK_H
#define C_CHECKSUM_KECCAK_H

#include <stddef.h>
#include <stdint.h>

typedef unsigned char u8;
typedef unsigned long long int u64;
typedef unsigned int ui;

void Keccak(ui r, ui c, const u8 *in, u64 inLen, u8 sfx, u8 *out, u64 outLen);
void Keccak_256(const u8 *in, u64 inLen, u8 *out);

#endif
