# cython: boundscheck=False
# cython: wraparound=False

from cpython.bytes cimport PyBytes_GET_SIZE
from cpython.unicode cimport PyUnicode_AsEncodedString

from eth_hash.auto import keccak
from eth_typing import AnyAddress, ChecksumAddress


# force _hasher_first_run and _preimage_first_run to execute so we can cache the new hasher
keccak(b"")

cdef object hash_address = keccak.hasher
cdef const char* hexdigits = b"0123456789abcdef"


# this was ripped out of eth_utils and optimized a little bit


cpdef unicode to_checksum_address(value: Union[AnyAddress, str, bytes]):
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
    cdef bytes hex_address_bytes, hashed_bytes
    cdef const unsigned char* hex_address_bytestr
    cdef unsigned char c

    cdef unsigned char[:] hash_buffer = bytearray(80)  # contiguous and writeable
    
    # Create a buffer for our result
    # 2 for "0x" prefix and 40 for the address itself
    cdef char[42] result_buffer = b'0x' + bytearray(40)
    
    if isinstance(value, str):
        hex_address_bytes = lowercase_ascii_and_validate(PyUnicode_AsEncodedString(value, b"ascii", NULL))            
        hex_address_bytestr = hex_address_bytes

    elif isinstance(value, (bytes, bytearray)):
        hex_address_bytes = hexlify(value).lower()        
        hex_address_bytestr = hex_address_bytes
        num_bytes = PyBytes_GET_SIZE(hex_address_bytes)

        with nogil:
            for i in range(num_bytes):
                c = hex_address_bytestr[i]
                
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
                        f"Unknown format {repr(value)}, attempted to normalize to '0x{hex_address_bytes.decode()}'"
                    )
        
    else:
        raise TypeError(
            f"Unsupported type: '{repr(type(value))}'. Must be one of: bool, str, bytes, bytearray or int."
        )

    if PyBytes_GET_SIZE(hex_address_bytes) != 40:
        raise ValueError(
            f"Unknown format {repr(value)}, attempted to normalize to '0x{hex_address_bytes.decode()}'"
        )
    
    hashed_bytes = hash_address(hex_address_bytes)
    cdef const unsigned char* hashed_bytestr = hashed_bytes
    
    with nogil:
        hexlify_c_string_to_buffer_unsafe(hashed_bytestr, hash_buffer, 40)
        populate_result_buffer(result_buffer, hex_address_bytestr, hash_buffer)
        
    # It is faster to decode a buffer with a known size ie buffer[:42]
    return result_buffer[:42].decode('ascii')


cpdef bytes hexlify(const unsigned char[:] src_buffer):
    return bytes(hexlify_unsafe(src_buffer, len(src_buffer)))


cdef const unsigned char[:] hexlify_unsafe(const char[:] src_buffer, Py_ssize_t num_bytes) noexcept:
    """Make sure your `num_bytes` is correct or ting go boom"""
    cdef unsigned char[:] result_buffer = bytearray(num_bytes * 2)  # contiguous and writeable
    with nogil:
        hexlify_memview_to_buffer_unsafe(src_buffer, result_buffer, num_bytes)
    return result_buffer


cdef inline int hexlify_memview_to_buffer(
    const char[:] src_buffer, 
    unsigned char[:] result_buffer, 
    Py_ssize_t num_bytes,
) nogil:
    cdef Py_ssize_t i
    cdef char c
    for i in range(num_bytes):
        c = src_buffer[i]
        result_buffer[2*i] = hexdigits[c >> 4]
        result_buffer[2*i+1] = hexdigits[c & 0x0F]


cdef inline int hexlify_c_string_to_buffer(
    const char* src_buffer, 
    unsigned char[:] result_buffer, 
    Py_ssize_t num_bytes,
) nogil:
    cdef Py_ssize_t i
    cdef char c
    for i in range(num_bytes):
        c = src_buffer[i]
        result_buffer[2*i] = hexdigits[c >> 4]
        result_buffer[2*i+1] = hexdigits[c & 0x0F]


cdef inline void hexlify_memview_to_buffer_unsafe(
    const char[:] src_buffer, 
    unsigned char[:] result_buffer, 
    Py_ssize_t num_bytes,
) noexcept nogil:
    cdef Py_ssize_t i
    cdef char c
    for i in range(num_bytes):
        c = src_buffer[i]
        result_buffer[2*i] = hexdigits[c >> 4]
        result_buffer[2*i+1] = hexdigits[c & 0x0F]


cdef inline void hexlify_c_string_to_buffer_unsafe(
    const char* src_buffer, 
    unsigned char[:] result_buffer, 
    Py_ssize_t num_bytes,
) noexcept nogil:
    cdef Py_ssize_t i
    cdef char c
    for i in range(num_bytes):
        c = src_buffer[i]
        result_buffer[2*i] = hexdigits[c >> 4]
        result_buffer[2*i+1] = hexdigits[c & 0x0F]


cdef void populate_result_buffer(
    char[42] buffer,
    const unsigned char* norm_address_no_0x, 
    const unsigned char[:] address_hash_hex_no_0x,
) noexcept nogil:
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

    See Also:
        - :func:`eth_utils.to_checksum_address`: A utility function for converting addresses to their checksummed form.
    """
    # Handle character casing based on the hash value
    # `if address_hash_hex_no_0x[x] < 56`
    # '0' to '7' have ASCII values 48 to 55
    if address_hash_hex_no_0x[0] < 56:
        buffer[2] = norm_address_no_0x[0]
    else:
        buffer[2] = get_char(norm_address_no_0x[0])
    if address_hash_hex_no_0x[1] < 56:
        buffer[3] = norm_address_no_0x[1]
    else:
        buffer[3] = get_char(norm_address_no_0x[1])
    if address_hash_hex_no_0x[2] < 56:
        buffer[4] = norm_address_no_0x[2]
    else:
        buffer[4] = get_char(norm_address_no_0x[2])
    if address_hash_hex_no_0x[3] < 56:
        buffer[5] = norm_address_no_0x[3]
    else:
        buffer[5] = get_char(norm_address_no_0x[3])
    if address_hash_hex_no_0x[4] < 56:
        buffer[6] = norm_address_no_0x[4]
    else:
        buffer[6] = get_char(norm_address_no_0x[4])
    if address_hash_hex_no_0x[5] < 56:
        buffer[7] = norm_address_no_0x[5]
    else:
        buffer[7] = get_char(norm_address_no_0x[5])
    if address_hash_hex_no_0x[6] < 56:
        buffer[8] = norm_address_no_0x[6]
    else:
        buffer[8] = get_char(norm_address_no_0x[6])
    if address_hash_hex_no_0x[7] < 56:
        buffer[9] = norm_address_no_0x[7]
    else:
        buffer[9] = get_char(norm_address_no_0x[7])
    if address_hash_hex_no_0x[8] < 56:
        buffer[10] = norm_address_no_0x[8]
    else:
        buffer[10] = get_char(norm_address_no_0x[8])
    if address_hash_hex_no_0x[9] < 56:
        buffer[11] = norm_address_no_0x[9]
    else:
        buffer[11] = get_char(norm_address_no_0x[9])
    if address_hash_hex_no_0x[10] < 56:
        buffer[12] = norm_address_no_0x[10]
    else:
        buffer[12] = get_char(norm_address_no_0x[10])
    if address_hash_hex_no_0x[11] < 56:
        buffer[13] = norm_address_no_0x[11]
    else:
        buffer[13] = get_char(norm_address_no_0x[11])
    if address_hash_hex_no_0x[12] < 56:
        buffer[14] = norm_address_no_0x[12]
    else:
        buffer[14] = get_char(norm_address_no_0x[12])
    if address_hash_hex_no_0x[13] < 56:
        buffer[15] = norm_address_no_0x[13]
    else:
        buffer[15] = get_char(norm_address_no_0x[13])
    if address_hash_hex_no_0x[14] < 56:
        buffer[16] = norm_address_no_0x[14]
    else:
        buffer[16] = get_char(norm_address_no_0x[14])
    if address_hash_hex_no_0x[15] < 56:
        buffer[17] = norm_address_no_0x[15]
    else:
        buffer[17] = get_char(norm_address_no_0x[15])
    if address_hash_hex_no_0x[16] < 56:
        buffer[18] = norm_address_no_0x[16]
    else:
        buffer[18] = get_char(norm_address_no_0x[16])
    if address_hash_hex_no_0x[17] < 56:
        buffer[19] = norm_address_no_0x[17]
    else:
        buffer[19] = get_char(norm_address_no_0x[17])
    if address_hash_hex_no_0x[18] < 56:
        buffer[20] = norm_address_no_0x[18]
    else:
        buffer[20] = get_char(norm_address_no_0x[18])
    if address_hash_hex_no_0x[19] < 56:
        buffer[21] = norm_address_no_0x[19]
    else:
        buffer[21] = get_char(norm_address_no_0x[19])
    if address_hash_hex_no_0x[20] < 56:
        buffer[22] = norm_address_no_0x[20]
    else:
        buffer[22] = get_char(norm_address_no_0x[20])
    if address_hash_hex_no_0x[21] < 56:
        buffer[23] = norm_address_no_0x[21]
    else:
        buffer[23] = get_char(norm_address_no_0x[21])
    if address_hash_hex_no_0x[22] < 56:
        buffer[24] = norm_address_no_0x[22]
    else:
        buffer[24] = get_char(norm_address_no_0x[22])
    if address_hash_hex_no_0x[23] < 56:
        buffer[25] = norm_address_no_0x[23]
    else:
        buffer[25] = get_char(norm_address_no_0x[23])
    if address_hash_hex_no_0x[24] < 56:
        buffer[26] = norm_address_no_0x[24]
    else:
        buffer[26] = get_char(norm_address_no_0x[24])
    if address_hash_hex_no_0x[25] < 56:
        buffer[27] = norm_address_no_0x[25]
    else:
        buffer[27] = get_char(norm_address_no_0x[25])
    if address_hash_hex_no_0x[26] < 56:
        buffer[28] = norm_address_no_0x[26]
    else:
        buffer[28] = get_char(norm_address_no_0x[26])
    if address_hash_hex_no_0x[27] < 56:
        buffer[29] = norm_address_no_0x[27]
    else:
        buffer[29] = get_char(norm_address_no_0x[27])
    if address_hash_hex_no_0x[28] < 56:
        buffer[30] = norm_address_no_0x[28]
    else:
        buffer[30] = get_char(norm_address_no_0x[28])
    if address_hash_hex_no_0x[29] < 56:
        buffer[31] = norm_address_no_0x[29]
    else:
        buffer[31] = get_char(norm_address_no_0x[29])
    if address_hash_hex_no_0x[30] < 56:
        buffer[32] = norm_address_no_0x[30]
    else:
        buffer[32] = get_char(norm_address_no_0x[30])
    if address_hash_hex_no_0x[31] < 56:
        buffer[33] = norm_address_no_0x[31]
    else:
        buffer[33] = get_char(norm_address_no_0x[31])
    if address_hash_hex_no_0x[32] < 56:
        buffer[34] = norm_address_no_0x[32]
    else:
        buffer[34] = get_char(norm_address_no_0x[32])
    if address_hash_hex_no_0x[33] < 56:
        buffer[35] = norm_address_no_0x[33]
    else:
        buffer[35] = get_char(norm_address_no_0x[33])
    if address_hash_hex_no_0x[34] < 56:
        buffer[36] = norm_address_no_0x[34]
    else:
        buffer[36] = get_char(norm_address_no_0x[34])
    if address_hash_hex_no_0x[35] < 56:
        buffer[37] = norm_address_no_0x[35]
    else:
        buffer[37] = get_char(norm_address_no_0x[35])
    if address_hash_hex_no_0x[36] < 56:
        buffer[38] = norm_address_no_0x[36]
    else:
        buffer[38] = get_char(norm_address_no_0x[36])
    if address_hash_hex_no_0x[37] < 56:
        buffer[39] = norm_address_no_0x[37]
    else:
        buffer[39] = get_char(norm_address_no_0x[37])
    if address_hash_hex_no_0x[38] < 56:
        buffer[40] = norm_address_no_0x[38]
    else:
        buffer[40] = get_char(norm_address_no_0x[38])
    if address_hash_hex_no_0x[39] < 56:
        buffer[41] = norm_address_no_0x[39]
    else:
        buffer[41] = get_char(norm_address_no_0x[39])


cdef inline unsigned char get_char(unsigned char c) noexcept nogil:
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


cdef unsigned char* lowercase_ascii_and_validate(bytes src):
    cdef Py_ssize_t src_len, range_start, i
    cdef unsigned char* c_string
    cdef unsigned char c
    
    src_len = PyBytes_GET_SIZE(src)
    c_string = src

    with nogil:
        # if c_string[0] == b"0" and c_string[1] in (b"X", b"x")
        if c_string[0] == 48 and c_string[1] in (88, 120):
            range_start = 2
        else:
            range_start = 0
    
        for i in range(range_start, src_len):
            c = c_string[i]

            if 65 <= c <= 90:
                c += 32

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
                with gil:
                    raise ValueError("when sending a str, it must be a hex string. " f"Got: {repr(src.decode('ascii'))}")
    
    return c_string[range_start:]


del AnyAddress, ChecksumAddress
del keccak
