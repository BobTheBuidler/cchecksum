from binascii import unhexlify

BASE_ADDRESSES = [
    "0x52908400098527886e0f7030069857d2e4169ee7",
    "0xde709f2102306220921060314715629080e2fb77",
    "0x27b1fdb04752bbc536007a920d24acb045561c26",
    "0x5aeda56215b167893e80b4fe645ba6d5bab767de",
    "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2",
]

MIXED_ADDRESSES = [
    "0x52908400098527886E0F7030069857D2E4169EE7",
    "0x8617E340B3D01FA5F11F306F4090FD50E238070D",
    "0x5aAeb6053F3E94C9b9A09f33669435E7Ef1BeAed",
    "0xfb6916095ca1df60bb79ce92ce3ea74c37c5d359",
    "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
]

STR_CASES = []
STR_CASE_IDS = []
for index, address in enumerate(BASE_ADDRESSES):
    STR_CASES.append(address)
    STR_CASE_IDS.append(f"lower-0x-{index}")

    STR_CASES.append(address.upper())
    STR_CASE_IDS.append(f"upper-0x-{index}")

    STR_CASES.append(address[2:])
    STR_CASE_IDS.append(f"lower-no-0x-{index}")

    STR_CASES.append(address[2:].upper())
    STR_CASE_IDS.append(f"upper-no-0x-{index}")

for index, address in enumerate(MIXED_ADDRESSES):
    STR_CASES.append(address)
    STR_CASE_IDS.append(f"mixed-{index}")

BYTES_CASES = [unhexlify(address[2:]) for address in BASE_ADDRESSES]
BYTES_CASE_IDS = [f"bytes-{index}" for index in range(len(BASE_ADDRESSES))]

BYTEARRAY_CASES = [bytearray(address) for address in BYTES_CASES]
BYTEARRAY_CASE_IDS = [f"bytearray-{index}" for index in range(len(BYTES_CASES))]

CONTAINER_SIZE = 1000


def _build_container(cases: list, size: int) -> list:
    return [cases[index % len(cases)] for index in range(size)]


STR_CONTAINER_CASES = [_build_container(STR_CASES, CONTAINER_SIZE)]
STR_CONTAINER_CASE_IDS = [f"str-container-{CONTAINER_SIZE}"]

BYTES_CONTAINER_CASES = [_build_container(BYTES_CASES, CONTAINER_SIZE)]
BYTES_CONTAINER_CASE_IDS = [f"bytes-container-{CONTAINER_SIZE}"]

BYTEARRAY_CONTAINER_CASES = [_build_container(BYTEARRAY_CASES, CONTAINER_SIZE)]
BYTEARRAY_CONTAINER_CASE_IDS = [f"bytearray-container-{CONTAINER_SIZE}"]
