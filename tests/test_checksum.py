import time
from binascii import unhexlify
from concurrent.futures import ThreadPoolExecutor
from functools import lru_cache

import eth_utils
import pytest

from cchecksum import to_checksum_address, to_checksum_address_many

benchmark_addresses = []
range_start = 100000000000000000000000000000000000000000


@lru_cache(maxsize=None)
def __get_prefix(addrlen: int) -> str:
    return f"0x{'0' * (40 - len(address))}"


for i in range(range_start, range_start + 500000):
    address = hex(i)[2:]
    address = f"{__get_prefix(len(address))}{address}"
    benchmark_addresses.append(address)


def test_checksum_str_lower() -> None:
    lower = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2".lower()
    assert to_checksum_address(lower) == "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2"


def test_checksum_str_upper() -> None:
    lower = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2".upper()
    assert to_checksum_address(lower) == "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2"


def test_checksum_str_mixed() -> None:
    lower = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2"
    assert to_checksum_address(lower) == "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2"


def test_checksum_str_no_0x_prefix_lower() -> None:
    lower = "C02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2".lower()
    assert to_checksum_address(lower) == "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2"


def test_checksum_str_no_0x_prefix_upper() -> None:
    lower = "C02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2".upper()
    assert to_checksum_address(lower) == "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2"


def test_checksum_str_no_0x_prefix_mixed() -> None:
    lower = "C02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2"
    assert to_checksum_address(lower) == "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2"


def test_checksum_bytes() -> None:
    bytes = unhexlify("C02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2")
    assert to_checksum_address(bytes) == "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2"


def test_checksum_many_strs() -> None:
    addresses = [
        "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
        "0xb47e3cd837ddf8e4c57f05d70ab865de6e193bbb",
    ]
    assert to_checksum_address_many(addresses) == [
        to_checksum_address(address) for address in addresses
    ]


def test_checksum_many_bytes() -> None:
    addresses = [
        unhexlify("C02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2"),
        unhexlify("b47e3cd837ddf8e4c57f05d70ab865de6e193bbb"),
    ]
    assert to_checksum_address_many(addresses) == [
        to_checksum_address(address) for address in addresses
    ]


def test_checksum_many_memoryview() -> None:
    addresses = [
        unhexlify("C02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2"),
        unhexlify("b47e3cd837ddf8e4c57f05d70ab865de6e193bbb"),
    ]
    packed = b"".join(addresses)
    assert to_checksum_address_many(memoryview(packed)) == [
        to_checksum_address(address) for address in addresses
    ]


def test_checksum_many_type_error() -> None:
    input = object()
    try:
        to_checksum_address(input)
    except TypeError as e:
        with pytest.raises(TypeError, match=str(e)):
            to_checksum_address_many([input])
    else:
        raise RuntimeError("this should not happen")


def test_checksum_many_value_error() -> None:
    input = "i am a bad string"
    try:
        to_checksum_address(input)
    except ValueError as e:
        with pytest.raises(ValueError, match=str(e)):
            to_checksum_address_many([input])
    else:
        raise RuntimeError("this should not happen")


def test_type_error() -> None:
    input = object()
    try:
        eth_utils.to_checksum_address(input)
    except TypeError as e:
        with pytest.raises(TypeError, match=str(e)):
            to_checksum_address(input)
    else:
        raise RuntimeError("this should not happen")


def test_int_type_error() -> None:
    # this gives a ValueError in eth_utils but that's weird
    with pytest.raises(
        TypeError,
        match="Unsupported type: '<class 'int'>'. Must be one of: bool, str, bytes, bytearray or int.",
    ):
        to_checksum_address(0)


def test_none_type_error() -> None:
    # this gives a ValueError in eth_utils but that's due to an implementation detail of hexstr_to_str
    with pytest.raises(
        TypeError,
        match="Unsupported type: '<class 'NoneType'>'. Must be one of: bool, str, bytes, bytearray or int.",
    ):
        to_checksum_address(None)


def test_value_error() -> None:
    input = "i am a bad string"
    try:
        eth_utils.to_checksum_address(input)
    except ValueError as e:
        with pytest.raises(ValueError, match=str(e)):
            to_checksum_address(input)
    else:
        raise RuntimeError("this should not happen")


def test_benchmark() -> None:
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


def test_threadsafety() -> None:
    test_addresses = benchmark_addresses[:1000]
    executor = ThreadPoolExecutor(100)
    fast_way = executor.map(to_checksum_address, test_addresses)
    slow_way = executor.map(eth_utils.to_checksum_address, test_addresses)
    assert list(fast_way) == list(slow_way)


def test_threadsafety_many() -> None:
    test_addresses = benchmark_addresses[:1000]
    batches = [test_addresses[i : i + 50] for i in range(0, len(test_addresses), 50)]
    executor = ThreadPoolExecutor(50)
    fast_way = executor.map(to_checksum_address_many, batches)
    slow_way = executor.map(
        lambda batch: list(map(eth_utils.to_checksum_address, batch)), batches
    )
    assert list(fast_way) == list(slow_way)
