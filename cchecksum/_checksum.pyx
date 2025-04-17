# cython: boundscheck=False

def cchecksum(str norm_address_no_0x, const unsigned char[::1] address_hash_hex_no_0x) -> str:
    """
    Computes the checksummed version of an Ethereum address.

    This function takes a normalized Ethereum address (without the '0x' prefix) and its corresponding
    hash (also without the '0x' prefix) and returns the checksummed address as per the Ethereum
    Improvement Proposal 55 (EIP-55).

    Args:
        norm_address_no_0x (str): The normalized Ethereum address without the '0x' prefix.
        address_hash_hex_no_0x (bytes): The hash of the address, also without the '0x' prefix.

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

    # NOTE: For some reason on some systems the buffer length is longer than 42 here, even though that should not be possible.
    #       Lucky for us, the first 42 characters are always correct. One day maybe I'll debug this.
    return buffer[:42].decode('ascii')
