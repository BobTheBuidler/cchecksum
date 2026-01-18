# Benchmarks for cchecksum

This directory contains a focused CodSpeed benchmark suite for `cchecksum`.

## Benchmark Files

- `test_checksum_benchmarks.py`: Measures `to_checksum_address` throughput across string, bytes, and bytearray inputs.

## Running Benchmarks

Install dependencies:

```
pip install . -r requirements-codspeed.txt
```

Run CodSpeed locally:

```
pytest --codspeed benchmarks/
```
