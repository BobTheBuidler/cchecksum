import time
from binascii import unhexlify

import eth_utils
import pytest

from cchecksum import to_checksum_address


def test_checksum_str():
    lower = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2".lower()
    assert to_checksum_address(lower) == "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2"


def test_checksum_str_no_0x_prefix():
    lower = "C02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2".lower()
    assert to_checksum_address(lower) == "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2"


def test_checksum_bytes():
    bytes = unhexlify("C02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2")
    assert to_checksum_address(bytes) == "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2"


def test_type_error():
    try:
        eth_utils.to_checksum_address(0)
    except TypeError as e:
        with pytest.raises(TypeError, match=str(e)):
            to_checksum_address(0)
    else:
        raise RuntimeError("this should not happen")


def test_none_type_error():
    with pytest.raises(
        TypeError, 
        match="Unsupported type: '<class 'NoneType'>'. Must be one of: bytes or bytearray.",
    ):
        to_checksum_address(None)


# Benchmark
benchmark_addresses = []
range_start = 100000000000000000000000000000000000000000
for i in range(range_start, range_start + 500000):
    address = hex(i)[2:]
    address = "0x" + "0" * (40 - len(address)) + address
    benchmark_addresses.append(address)


def test_benchmark():
    start = time.time()
    checksummed = list(map(to_checksum_address, benchmark_addresses))
    cython_duration = time.time() - start
    print(f"cython took {cython_duration}s")
    start = time.time()
    python = list(map(eth_utils.to_checksum_address, benchmark_addresses))
    python_duration = time.time() - start
    print(f"python took {python_duration}s")
    assert checksummed == python
    assert cython_duration < python_duration
    print(f"took {cython_duration/python_duration}% of the time")
