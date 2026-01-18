from typing import Union

import pytest
from pytest_codspeed import BenchmarkFixture

from benchmarks.batch import batch
from benchmarks.data import (
    BYTEARRAY_CASES,
    BYTEARRAY_CASE_IDS,
    BYTES_CASES,
    BYTES_CASE_IDS,
    STR_CASES,
    STR_CASE_IDS,
)
from cchecksum import to_checksum_address


@pytest.mark.benchmark(group="to_checksum_address_str")
@pytest.mark.parametrize("value", STR_CASES, ids=STR_CASE_IDS)
def test_to_checksum_address_str(benchmark: BenchmarkFixture, value: str) -> None:
    benchmark(run_10k, to_checksum_address, value)


@pytest.mark.benchmark(group="to_checksum_address_bytes")
@pytest.mark.parametrize("value", BYTES_CASES, ids=BYTES_CASE_IDS)
def test_to_checksum_address_bytes(benchmark: BenchmarkFixture, value: bytes) -> None:
    benchmark(run_10k, to_checksum_address, value)


@pytest.mark.benchmark(group="to_checksum_address_bytearray")
@pytest.mark.parametrize("value", BYTEARRAY_CASES, ids=BYTEARRAY_CASE_IDS)
def test_to_checksum_address_bytearray(
    benchmark: BenchmarkFixture, value: Union[bytes, bytearray]
) -> None:
    benchmark(run_10k, to_checksum_address, value)
