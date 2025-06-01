"""CChecksum is a ~8x faster drop-in replacement for eth_utils.to_checksum_address,
with the most cpu-intensive part implemented in c.

It keeps the exact same API as the existing implementation, exceptions and all.
"""

from cchecksum._checksum import to_checksum_address
from cchecksum.monkey_patch import monkey_patch_eth_utils, monkey_patch_web3py


__all__ = ["to_checksum_address", "monkey_patch_eth_utils", "monkey_patch_web3py"]
