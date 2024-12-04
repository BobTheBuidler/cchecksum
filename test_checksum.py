import time

from eth_utils import to_checksum_address as to_checksum_address_py

from cchecksum import to_checksum_address


def test_checksum():
    lower = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2".upper()
    assert to_checksum_address(lower) == "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2"


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
