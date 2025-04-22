"""CChecksum is a ~8x faster drop-in replacement for eth_utils.to_checksum_address,
with the most cpu-intensive part implemented in c.

It keeps the exact same API as the existing implementation, exceptions and all.
"""

if sys.version_info < (3, 11):
    from cchecksum._checksum_old import to_checksum_address
else:
    from cchecksum._checksum_new import to_checksum_address

__all__ = ["to_checksum_address"]
