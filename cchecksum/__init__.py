"""CChecksum is a ~5x faster drop-in replacement for eth_utils.to_checksum_address, 
with the most cpu-intensive part implemented in c.

It keeps the exact same API as the existing implementation, exceptions and all.
"""

from cchecksum.checksum import to_checksum_address

__all__ = ["to_checksum_address"]
