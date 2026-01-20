from typing import Any, Callable, Union

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
)
from cchecksum import to_checksum_address


def _run_10k(func: Callable[..., Any], *args: Any, **kwargs: Any) -> None:
    for _ in range(10_000):
        func(*args, **kwargs)


def _run_container(func: Callable[[Any], Any], values: list[Any]) -> None:
    for value in values:
        func(value)


@pytest.mark.benchmark(group="to_checksum_address_str")
@pytest.mark.parametrize("value", STR_CASES, ids=STR_CASE_IDS)
def test_to_checksum_address_str(benchmark: BenchmarkFixture, value: str) -> None:
    benchmark(_run_10k, to_checksum_address, value)


@pytest.mark.benchmark(group="to_checksum_address_bytes")
@pytest.mark.parametrize("value", BYTES_CASES, ids=BYTES_CASE_IDS)
def test_to_checksum_address_bytes(benchmark: BenchmarkFixture, value: bytes) -> None:
    benchmark(_run_10k, to_checksum_address, value)


@pytest.mark.benchmark(group="to_checksum_address_bytearray")
@pytest.mark.parametrize("value", BYTEARRAY_CASES, ids=BYTEARRAY_CASE_IDS)
def test_to_checksum_address_bytearray(
    benchmark: BenchmarkFixture, value: Union[bytes, bytearray]
) -> None:
    benchmark(_run_10k, to_checksum_address, value)


@pytest.mark.benchmark(group="to_checksum_address_str_container")
@pytest.mark.parametrize("values", STR_CONTAINER_CASES, ids=STR_CONTAINER_CASE_IDS)
def test_to_checksum_address_str_container(
    benchmark: BenchmarkFixture, values: list[str]
) -> None:
    benchmark(_run_container, to_checksum_address, values)


@pytest.mark.benchmark(group="to_checksum_address_bytes_container")
@pytest.mark.parametrize(
    "values", BYTES_CONTAINER_CASES, ids=BYTES_CONTAINER_CASE_IDS
)
def test_to_checksum_address_bytes_container(
    benchmark: BenchmarkFixture, values: list[bytes]
) -> None:
    benchmark(_run_container, to_checksum_address, values)


@pytest.mark.benchmark(group="to_checksum_address_bytearray_container")
@pytest.mark.parametrize(
    "values", BYTEARRAY_CONTAINER_CASES, ids=BYTEARRAY_CONTAINER_CASE_IDS
)
def test_to_checksum_address_bytearray_container(
    benchmark: BenchmarkFixture, values: list[bytearray]
) -> None:
    benchmark(_run_container, to_checksum_address, values)
