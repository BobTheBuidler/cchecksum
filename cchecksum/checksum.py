from binascii import hexlify
from typing import AnyStr, Optional, Union

from eth_hash.auto import keccak
from eth_typing import AnyAddress, ChecksumAddress, HexAddress, HexStr
from eth_utils.address import _HEX_ADDRESS_REGEXP
from eth_utils.hexadecimal import _HEX_REGEXP
from eth_utils.toolz import compose

from cchecksum._checksum import cchecksum


# force _hasher_first_run and _preimage_first_run to execute so we can cache the new hasher
keccak(b"")

hash_address = compose(hexlify, bytes, keccak.hasher, str.encode)

hex_address_fullmatch = _HEX_ADDRESS_REGEXP.fullmatch
hex_fullmatch = _HEX_REGEXP.fullmatch


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


def to_normalized_address_no_0x(value: Union[AnyAddress, str, bytes]) -> HexAddress:
    """
    Converts an address to its normalized hexadecimal representation without the '0x' prefix.

    This function ensures that the address is in a consistent lowercase hexadecimal
    format, which is useful for further processing or validation. It uses
    :func:`eth_utils.hexstr_if_str` and :func:`to_hex` to convert the input
    to a hexadecimal string.

    Args:
        value: The address to be normalized. It can be in any format supported by
            :func:`to_hex`.

    Raises:
        ValueError: If the input address is not in a recognized format.
        TypeError: If the input is not a string, bytes, or any address type.

    Examples:
        >>> to_normalized_address("0xB47E3CD837DDF8E4C57F05D70AB865DE6E193BBB")
        '0xb47e3cd837ddf8e4c57f05d70ab865de6e193bbb'

        >>> to_normalized_address(b'\xb4~<\xd87\xdd\xf8\xe4\xc5\x7f\x05\xd7\n\xb8e\xden\x19;\xbb')
        '0xb47e3cd837ddf8e4c57f05d70ab865de6e193bbb'

    See Also:
        - :func:`eth_utils.to_normalized_address` for the standard implementation.
        - :func:`is_address` for checking if a string is a valid address.
    """
    if isinstance(value, str):
        hex_address_no_0x = value[2:] if value.startswith(("0x", "0X")) else value

        # if `value` has content and is not a hexstring
        if hex_address_no_0x and hex_fullmatch(value) is None:
            raise ValueError("when sending a str, it must be a hex string. " f"Got: {repr(value)}")

    elif isinstance(value, bytes, bytearray)):
        hex_address_no_0x = hexlify(value).decode("ascii")

    else:
        raise TypeError(
            f"Unsupported type: '{repr(type(value))}'. Must be one of: bool, str, bytes, bytearray or int."
        )

    # if `hex_address_no_0x` is not a valid address
    if hex_address_fullmatch(hex_address_no_0x) is None:
        hex_address = f"0x{hex_address_no_0x}".lower()
        raise ValueError(
            f"Unknown format {repr(value)}, attempted to normalize to {repr(hex_address)}"
        )

    return hex_address_no_0x.lower()  # type: ignore [return-value]


del AnyStr, Optional, Union
del AnyAddress, ChecksumAddress, HexAddress, HexStr
del _HEX_ADDRESS_REGEXP, _HEX_REGEXP, compose, keccak
