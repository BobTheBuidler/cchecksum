# cython: boundscheck=False
# cython: wraparound=False

import binascii

cdef object hexlify = binascii.hexlify
del binascii


cpdef unicode cchecksum(
    str norm_address_no_0x, 
    const unsigned char[::1] address_hash_hex_no_0x,
):
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
    
    with nogil:
        # Handle character casing based on the hash value
        # `if address_hash_hex_no_0x[x] < 56`
        # '0' to '7' have ASCII values 48 to 55
        
        if address_hash_hex_no_0x[0] < 56:
            buffer[2] = norm_address_mv[0]
        else:
            buffer[2] = get_char(norm_address_mv[0])
        if address_hash_hex_no_0x[1] < 56:
            buffer[3] = norm_address_mv[1]
        else:
            buffer[3] = get_char(norm_address_mv[1])
        if address_hash_hex_no_0x[2] < 56:
            buffer[4] = norm_address_mv[2]
        else:
            buffer[4] = get_char(norm_address_mv[2])
        if address_hash_hex_no_0x[3] < 56:
            buffer[5] = norm_address_mv[3]
        else:
            buffer[5] = get_char(norm_address_mv[3])
        if address_hash_hex_no_0x[4] < 56:
            buffer[6] = norm_address_mv[4]
        else:
            buffer[6] = get_char(norm_address_mv[4])
        if address_hash_hex_no_0x[5] < 56:
            buffer[7] = norm_address_mv[5]
        else:
            buffer[7] = get_char(norm_address_mv[5])
        if address_hash_hex_no_0x[6] < 56:
            buffer[8] = norm_address_mv[6]
        else:
            buffer[8] = get_char(norm_address_mv[6])
        if address_hash_hex_no_0x[7] < 56:
            buffer[9] = norm_address_mv[7]
        else:
            buffer[9] = get_char(norm_address_mv[7])
        if address_hash_hex_no_0x[8] < 56:
            buffer[10] = norm_address_mv[8]
        else:
            buffer[10] = get_char(norm_address_mv[8])
        if address_hash_hex_no_0x[9] < 56:
            buffer[11] = norm_address_mv[9]
        else:
            buffer[11] = get_char(norm_address_mv[9])
        if address_hash_hex_no_0x[10] < 56:
            buffer[12] = norm_address_mv[10]
        else:
            buffer[12] = get_char(norm_address_mv[10])
        if address_hash_hex_no_0x[11] < 56:
            buffer[13] = norm_address_mv[11]
        else:
            buffer[13] = get_char(norm_address_mv[11])
        if address_hash_hex_no_0x[12] < 56:
            buffer[14] = norm_address_mv[12]
        else:
            buffer[14] = get_char(norm_address_mv[12])
        if address_hash_hex_no_0x[13] < 56:
            buffer[15] = norm_address_mv[13]
        else:
            buffer[15] = get_char(norm_address_mv[13])
        if address_hash_hex_no_0x[14] < 56:
            buffer[16] = norm_address_mv[14]
        else:
            buffer[16] = get_char(norm_address_mv[14])
        if address_hash_hex_no_0x[15] < 56:
            buffer[17] = norm_address_mv[15]
        else:
            buffer[17] = get_char(norm_address_mv[15])
        if address_hash_hex_no_0x[16] < 56:
            buffer[18] = norm_address_mv[16]
        else:
            buffer[18] = get_char(norm_address_mv[16])
        if address_hash_hex_no_0x[17] < 56:
            buffer[19] = norm_address_mv[17]
        else:
            buffer[19] = get_char(norm_address_mv[17])
        if address_hash_hex_no_0x[18] < 56:
            buffer[20] = norm_address_mv[18]
        else:
            buffer[20] = get_char(norm_address_mv[18])
        if address_hash_hex_no_0x[19] < 56:
            buffer[21] = norm_address_mv[19]
        else:
            buffer[21] = get_char(norm_address_mv[19])
        if address_hash_hex_no_0x[20] < 56:
            buffer[22] = norm_address_mv[20]
        else:
            buffer[22] = get_char(norm_address_mv[20])
        if address_hash_hex_no_0x[21] < 56:
            buffer[23] = norm_address_mv[21]
        else:
            buffer[23] = get_char(norm_address_mv[21])
        if address_hash_hex_no_0x[22] < 56:
            buffer[24] = norm_address_mv[22]
        else:
            buffer[24] = get_char(norm_address_mv[22])
        if address_hash_hex_no_0x[23] < 56:
            buffer[25] = norm_address_mv[23]
        else:
            buffer[25] = get_char(norm_address_mv[23])
        if address_hash_hex_no_0x[24] < 56:
            buffer[26] = norm_address_mv[24]
        else:
            buffer[26] = get_char(norm_address_mv[24])
        if address_hash_hex_no_0x[25] < 56:
            buffer[27] = norm_address_mv[25]
        else:
            buffer[27] = get_char(norm_address_mv[25])
        if address_hash_hex_no_0x[26] < 56:
            buffer[28] = norm_address_mv[26]
        else:
            buffer[28] = get_char(norm_address_mv[26])
        if address_hash_hex_no_0x[27] < 56:
            buffer[29] = norm_address_mv[27]
        else:
            buffer[29] = get_char(norm_address_mv[27])
        if address_hash_hex_no_0x[28] < 56:
            buffer[30] = norm_address_mv[28]
        else:
            buffer[30] = get_char(norm_address_mv[28])
        if address_hash_hex_no_0x[29] < 56:
            buffer[31] = norm_address_mv[29]
        else:
            buffer[31] = get_char(norm_address_mv[29])
        if address_hash_hex_no_0x[30] < 56:
            buffer[32] = norm_address_mv[30]
        else:
            buffer[32] = get_char(norm_address_mv[30])
        if address_hash_hex_no_0x[31] < 56:
            buffer[33] = norm_address_mv[31]
        else:
            buffer[33] = get_char(norm_address_mv[31])
        if address_hash_hex_no_0x[32] < 56:
            buffer[34] = norm_address_mv[32]
        else:
            buffer[34] = get_char(norm_address_mv[32])
        if address_hash_hex_no_0x[33] < 56:
            buffer[35] = norm_address_mv[33]
        else:
            buffer[35] = get_char(norm_address_mv[33])
        if address_hash_hex_no_0x[34] < 56:
            buffer[36] = norm_address_mv[34]
        else:
            buffer[36] = get_char(norm_address_mv[34])
        if address_hash_hex_no_0x[35] < 56:
            buffer[37] = norm_address_mv[35]
        else:
            buffer[37] = get_char(norm_address_mv[35])
        if address_hash_hex_no_0x[36] < 56:
            buffer[38] = norm_address_mv[36]
        else:
            buffer[38] = get_char(norm_address_mv[36])
        if address_hash_hex_no_0x[37] < 56:
            buffer[39] = norm_address_mv[37]
        else:
            buffer[39] = get_char(norm_address_mv[37])
        if address_hash_hex_no_0x[38] < 56:
            buffer[40] = norm_address_mv[38]
        else:
            buffer[40] = get_char(norm_address_mv[38])
        if address_hash_hex_no_0x[39] < 56:
            buffer[41] = norm_address_mv[39]
        else:
            buffer[41] = get_char(norm_address_mv[39])

    # It is faster to decode a buffer with a known size ie buffer[:42]
    return buffer[:42].decode('ascii')


cdef inline char get_char(char c) noexcept nogil:
    """This checks if `address_char` falls in the ASCII range for lowercase hexadecimal
    characters ('a' to 'f'), which correspond to ASCII values 97 to 102. If it does,
    the character is capitalized.
    """
    if c == 97:     # a
        return 65   # A
    elif c == 98:   # b
        return 66   # B
    elif c == 99:   # c
        return 67   # C
    elif c == 100:  # d
        return 68   # D
    elif c == 101:  # e
        return 69   # E
    elif c == 102:  # f
        return 70   # F
    else:
        return c


cpdef unicode to_normalized_address_no_0x(value: Union[AnyAddress, str, bytes]):
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
    
    if isinstance(value, str):
        hex_address_no_0x = value
        hex_address_no_0x = hex_address_no_0x.lower()
        if hex_address_no_0x.startswith("0x"):
            hex_address_no_0x = hex_address_no_0x[2:]

        # if `hex_address_no_0x` has content, validate all characters are valid hex chars:
        if hex_address_no_0x:
            try:
                validate_hex_chars(hex_address_no_0x, value)
            except ValueError as e:
                raise ValueError("when sending a str, it must be a hex string. " f"Got: {repr(value)}") from e.__cause__

    elif isinstance(value, (bytes, bytearray)):
        hex_address_no_0x = (<bytes>hexlify(value)).decode("ascii")
        hex_address_no_0x = hex_address_no_0x.lower()

    else:
        raise TypeError(
            f"Unsupported type: '{repr(type(value))}'. Must be one of: bool, str, bytes, bytearray or int."
        )

    validate_hex_address(hex_address_no_0x, value)
    return hex_address_no_0x


cdef inline void validate_hex_address(unicode hex_address_no_0x, object original_value):
    if len(hex_address_no_0x) != 40:
        raise ValueError(
            f"Unknown format {repr(original_value)}, attempted to normalize to '0x{hex_address_no_0x}'"
        )
    validate_hex_chars(hex_address_no_0x, original_value)

    
cdef inline void validate_hex_chars(unicode string, object original_value):
    # NOTE: `string` should already be lowercase when passed in
    cdef char c
    for c in string:
        if c == 48:  # 0
            pass
        elif c == 49:  # 1
            pass
        elif c == 50:  # 2
            pass
        elif c == 51:  # 3
            pass
        elif c == 52:  # 4
            pass
        elif c == 53:  # 5
            pass
        elif c == 54:  # 6
            pass
        elif c == 55:  # 7
            pass
        elif c == 56:  # 8
            pass
        elif c == 57:  # 9
            pass
        elif c == 97:  # a
            pass
        elif c == 98:  # b
            pass
        elif c == 99:  # c
            pass
        elif c == 100:  # d
            pass
        elif c == 101:  # e
            pass
        elif c == 102:  # f
            pass
        else:
            raise ValueError(
                f"Unknown format {repr(original_value)}, attempted to normalize to '0x{string}'"
            )
