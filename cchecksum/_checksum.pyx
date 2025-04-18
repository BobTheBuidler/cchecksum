# cython: boundscheck=False
# cython: wraparound=False

import binascii

from eth_utils import hexadecimal


cdef object hexlify = binascii.hexlify
del binascii

cdef object hex_fullmatch = hexadecimal._HEX_REGEXP.fullmatch
del hexadecimal


def cchecksum(str norm_address_no_0x, const unsigned char[::1] address_hash_hex_no_0x) -> str:
    """
    Computes the checksummed version of an Ethereum address.

    This function takes a normalized Ethereum address (without the '0x' prefix) and its corresponding
    hash (also without the '0x' prefix) and returns the checksummed address as per the Ethereum
    Improvement Proposal 55 (EIP-55).

    Args:
        norm_address_no_0x: The normalized Ethereum address without the '0x' prefix.
        address_hash_hex_no_0x: The hash of the address, also without the '0x' prefix.

    Returns:
        The checksummed Ethereum address with the '0x' prefix.

    Examples:
        >>> cchecksum("b47e3cd837ddf8e4c57f05d70ab865de6e193bbb", "abcdef1234567890abcdef1234567890abcdef12")
        '0xB47E3Cd837DdF8E4C57F05D70Ab865De6E193BbB'

        >>> cchecksum("0000000000000000000000000000000000000000", "1234567890abcdef1234567890abcdef12345678")
        '0x0000000000000000000000000000000000000000'

    See Also:
        - :func:`eth_utils.to_checksum_address`: A utility function for converting addresses to their checksummed form.
    """
    
    # Declare memoryviews for fixed-length data
    cdef const unsigned char[::1] norm_address_mv = norm_address_no_0x.encode('ascii')
    
    # Create a buffer for our result
    # 2 for "0x" prefix and 40 for the address itself
    cdef unsigned char[42] buffer = b'0x' + bytearray(40)

    # Handle character casing based on the hash value
    cdef int i
    cdef int address_char
    
    for i in range(40):
        
        if address_hash_hex_no_0x[i] < 56:
            # '0' to '7' have ASCII values 48 to 55
            buffer[i + 2] = norm_address_mv[i]
            
        else:
            address_char = norm_address_mv[i]
            # This checks if `address_char` falls in the ASCII range for lowercase hexadecimal
            # characters ('a' to 'f'), which correspond to ASCII values 97 to 102. If it does,
            # the character is capitalized.
            buffer[i + 2] = address_char - 32 if 97 <= address_char <= 102 else address_char

    # It is faster to decode a buffer with a known size ie buffer[:42]
    return buffer[:42].decode('ascii')


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
    cdef unicode hex_address_no_0x
    cdef char c
    
    if isinstance(value, str):
        hex_address_no_0x = (value[2:] if value.startswith(("0x", "0X")) else value).lower()

        # if `value` has content and is not a hexstring
        if hex_address_no_0x and hex_fullmatch(value) is None:
            raise ValueError("when sending a str, it must be a hex string. " f"Got: {repr(value)}")

    elif isinstance(value, (bytes, bytearray)):
        hex_address_no_0x = hexlify(value).decode("ascii").lower()

    else:
        raise TypeError(
            f"Unsupported type: '{repr(type(value))}'. Must be one of: bool, str, bytes, bytearray or int."
        )

    validate_hex_address(hex_address_no_0x, value)
    return hex_address_no_0x


cdef inline void validate_hex_address(unicode hex_address_no_0x, object original_value):
    if len(hex_address_no_0x) != 40:
        hex_address = f"0x{hex_address_no_0x}"
        raise ValueError(
            f"Unknown format {repr(original_value)}, attempted to normalize to {repr(hex_address)}"
        )
    else:
        for c in hex_address_no_0x:
            if not (48 <= c <= 57 or 97 <= c <= 102):
                hex_address = f"0x{hex_address_no_0x}"
                raise ValueError(
                    f"Unknown format {repr(original_value)}, attempted to normalize to {repr(hex_address)}"
                )
