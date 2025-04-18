from eth_typing import AnyAddress, ChecksumAddress, HexAddress

def cchecksum(norm_address_no_0x: str, address_hash_hex_no_0x: bytes) -> ChecksumAddress: ...
def to_normalized_address_no_0x(value: Union[AnyAddress, str, bytes]) -> HexAddress:
    """
    Converts an address to its normalized hexadecimal representation without the '0x' prefix.

    This function ensures that the address is in a consistent lowercase hexadecimal
    format, which is useful for further processing or validation.

    Args:
        value: The address to be normalized.

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
    """
