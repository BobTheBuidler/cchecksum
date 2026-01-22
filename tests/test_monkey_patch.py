import eth_utils
import eth_utils.address
import pytest

# pywin32 does not install properly on free-threaded python builds on Windows,
# so we skip tests invoking web3.py for Python3.13+ on Windows.
pytest.importorskip("web3")

import web3._utils as web3_utils
import web3.main as web3_main
import web3.middleware as web3_middleware

import cchecksum


def test_monkey_patch_eth_utils():
    cchecksum.monkey_patch_eth_utils()
    assert eth_utils.to_checksum_address is cchecksum.to_checksum_address
    assert eth_utils.address.to_checksum_address is cchecksum.to_checksum_address


def test_monkey_patch_web3py():
    cchecksum.monkey_patch_web3py()

    assert web3_main.to_checksum_address is cchecksum.to_checksum_address
    assert web3_utils.ens.to_checksum_address is cchecksum.to_checksum_address
    assert web3_utils.method_formatters.to_checksum_address is cchecksum.to_checksum_address
    assert web3_utils.normalizers.to_checksum_address is cchecksum.to_checksum_address
    assert web3_middleware.signing.to_checksum_address is cchecksum.to_checksum_address
