from typing import Any, Callable

import pytest
from pytest_codspeed import BenchmarkFixture

from benchmarks.data import (
    BYTEARRAY_CASES,
    BYTEARRAY_CASE_IDS,
    BYTEARRAY_CONTAINER_CASES,
    BYTEARRAY_CONTAINER_CASE_IDS,
    BYTES_CASES,
    BYTES_CASE_IDS,
    BYTES_CONTAINER_CASES,
    BYTES_CONTAINER_CASE_IDS,
    STR_CASES,
    STR_CASE_IDS,
    STR_CONTAINER_CASES,
    STR_CONTAINER_CASE_IDS,
    SINGLE_CASES, SINGLE_CASE_IDS, CONTAINER_CASES, CONTAINER_CASE_IDS
)
from cchecksum import to_checksum_address


def _run_container(func: Callable[[Any], Any], values: list[Any]) -> None:
    for value in values:
        func(value)


@pytest.mark.benchmark(group="to_checksum_address_str")
@pytest.mark.parametrize("value", SINGLE_CASES, ids=SINGLE_CASE_IDS)
def test_to_checksum_address(benchmark: BenchmarkFixture, value: str) -> None:
    @benchmark
    def run_10k():
        for _ in range(10_000):
            to_checksum_address(value)


@pytest.mark.benchmark(group="to_checksum_address_bytes_container")
@pytest.mark.parametrize("values", CONTAINER_CASES, ids=CONTAINER_CASE_IDS)
def test_to_checksum_address_multi(
    benchmark: BenchmarkFixture, values: list[bytes]
) -> None:
    @benchmark
    def run_container():
        for value in values:
            to_checksum_address(value)
