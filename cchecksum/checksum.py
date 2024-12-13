import binascii
from typing import Union

from eth_typing import AnyAddress, ChecksumAddress, HexAddress
from eth_utils import hexstr_if_str, keccak, to_hex
from eth_utils.address import _HEX_ADDRESS_REGEXP

from cchecksum._checksum import cchecksum


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
    norm_address_no_0x = to_normalized_address(value)[2:]
    address_hash = keccak(text=norm_address_no_0x)
    address_hash_hex_no_0x = binascii.hexlify(address_hash).decode("ascii")
    return cchecksum(norm_address_no_0x, address_hash_hex_no_0x)


def to_normalized_address(value: Union[AnyAddress, str, bytes]) -> HexAddress:
    """
    Converts an address to its normalized hexadecimal representation.

    This function ensures that the address is in a consistent lowercase hexadecimal
    format, which is useful for further processing or validation. It uses
    :func:`eth_utils.hexstr_if_str` and :func:`eth_utils.to_hex` to convert the input
    to a hexadecimal string.

    Args:
        value: The address to be normalized. It can be in any format supported by
            :func:`eth_utils.to_hex`.

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
    try:
        hex_address = hexstr_if_str(to_hex, value).lower()
    except AttributeError:
        raise TypeError(f"Value must be any string, instead got type {type(value)}")

    if not is_address(hex_address):
        raise ValueError(
            f"Unknown format {repr(value)}, attempted to normalize to {repr(hex_address)}"
        )

    return hex_address  # type: ignore [return-value]


def is_address(value: str) -> bool:
    """
    Check if the given string is a valid address in any known format.

    This function uses a regular expression to determine if the input string
    matches the expected pattern for a hexadecimal address.

    Args:
        value: The string to be checked.

    Returns:
        True if the string is a valid address, False otherwise.

    Examples:
        >>> is_address("0xb47e3cd837ddf8e4c57f05d70ab865de6e193bbb")
        True

        >>> is_address("not-an-address")
        False

    See Also:
        - :func:`eth_utils.is_address` for the standard implementation.
    """
    return _HEX_ADDRESS_REGEXP.fullmatch(value) is not None
