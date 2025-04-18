import time
from binascii import unhexlify

from eth_utils import to_checksum_address as to_checksum_address_py

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


# Benchmark
benchmark_addresses = []
range_start = 100000000000000000000000000000000000000000
for i in range(range_start, range_start + 500000):
    address = hex(i)[2:]
    address = "0x" + "0" * (40 - len(address)) + address
    benchmark_addresses.append(address)


def test_benchmark():
    start = time.time()
    checksummed = [to_checksum_address(address) for address in benchmark_addresses]
    cython_duration = time.time() - start
    print(f"cython took {cython_duration}s")
    start = time.time()
    python = [to_checksum_address_py(address) for address in benchmark_addresses]
    python_duration = time.time() - start
    print(f"python took {python_duration}s")
    assert checksummed == python
    assert cython_duration < python_duration
    print(f"took {cython_duration/python_duration}% of the time")
