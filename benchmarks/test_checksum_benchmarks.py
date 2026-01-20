import pytest
from pytest_codspeed import BenchmarkFixture

from benchmarks.data import CONTAINER_CASES, CONTAINER_CASE_IDS, SINGLE_CASES, SINGLE_CASE_IDS
from cchecksum import to_checksum_address


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
