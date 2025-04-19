from binascii import hexlify
from typing import Union

from eth_hash.auto import keccak
from eth_typing import AnyAddress, ChecksumAddress
from eth_utils.toolz import compose

from cchecksum._checksum import cchecksum, to_normalized_address_no_0x


# force _hasher_first_run and _preimage_first_run to execute so we can cache the new hasher
keccak(b"")

hash_address = compose(hexlify, bytes, keccak.hasher)


# this was ripped out of eth_utils and optimized a little bit


def to_checksum_address(value: Union[AnyAddress, str, bytes]) -> ChecksumAddress:
    """
    Convert an address to its EIP-55 checksum format.

    This function takes an address in any supported format and returns it in the
    checksummed format as defined by EIP-55. It uses a custom Cython implementation
    for the checksum conversion to optimize performance.

    Args:
        value: The address to be converted. It can be in any format supported by
            :func:`eth_utils.to_normalized_address`.

    Raises:
        ValueError: If the input address is not in a recognized format.
        TypeError: If the input is not a string, bytes, or any address type.

    Examples:
        >>> to_checksum_address("0xb47e3cd837ddf8e4c57f05d70ab865de6e193bbb")
        '0xb47e3cd837dDF8e4c57F05d70Ab865de6e193BBB'

        >>> to_checksum_address(b'\xb4~<\xd87\xdd\xf8\xe4\xc5\x7f\x05\xd7\n\xb8e\xden\x19;\xbb')
        '0xb47e3cd837dDF8e4c57F05d70Ab865de6e193BBB'

    See Also:
        - :func:`eth_utils.to_checksum_address` for the standard implementation.
        - :func:`to_normalized_address` for converting to a normalized address before checksumming.
    """
    norm_address_no_0x = to_normalized_address_no_0x(value)
    return cchecksum(norm_address_no_0x, hash_address(norm_address_no_0x))


del Union
del AnyAddress, ChecksumAddress
del compose, keccak
