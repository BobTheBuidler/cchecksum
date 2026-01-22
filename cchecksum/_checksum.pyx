# cython: boundscheck=False
# cython: wraparound=False

from cpython.bytes cimport PyBytes_GET_SIZE
from cpython.sequence cimport PySequence_Fast, PySequence_Fast_GET_ITEM, PySequence_Fast_GET_SIZE
from cpython.unicode cimport PyUnicode_AsEncodedString, PyUnicode_DecodeASCII
from cython.parallel cimport prange
from libc.stddef cimport size_t
from libc.string cimport memcpy

from eth_typing import AnyAddress, ChecksumAddress


cdef const unsigned char* hexdigits = b"0123456789abcdef"


# this was ripped out of eth_utils and optimized a little bit

cdef extern from "keccak.h":
    void keccak_256(const unsigned char* data, size_t len, unsigned char* out) nogil


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
    cdef bytes hex_address_bytes
    cdef const unsigned char* hex_address_bytestr
    cdef unsigned char c
    cdef unsigned char hash_out[32]

    # Create a buffer for our result
    # 2 for "0x" prefix and 40 for the address itself
    cdef char result_buffer[42]
    result_buffer[0] = 48  # '0'
    result_buffer[1] = 120  # 'x'
    
    if isinstance(value, str):
        hex_address_bytes = lowercase_ascii_and_validate(PyUnicode_AsEncodedString(value, b"ascii", NULL))            
        hex_address_bytestr = hex_address_bytes

    elif isinstance(value, (bytes, bytearray)):
        hex_address_bytes = hexlify(value)
        hex_address_bytestr = hex_address_bytes
        num_bytes = PyBytes_GET_SIZE(hex_address_bytes)

        with nogil:
            for i in range(num_bytes):
                c = hex_address_bytestr[i]
                
                if not is_hex_lower(c):
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
    
    with nogil:
        keccak_256(hex_address_bytestr, 40, hash_out)
        populate_result_buffer(result_buffer, hex_address_bytestr, hash_out)
        
    # It is faster to decode a buffer with a known size ie buffer[:42]
    return result_buffer[:42].decode('ascii')


cpdef list to_checksum_address_many(object values):
    """
    Convert multiple addresses to EIP-55 checksum format.

    Accepts a sequence of address-like inputs (str/bytes/bytearray) or a packed
    bytes-like object containing concatenated 20-byte addresses.
    """
    cdef Py_ssize_t i, n, packed_len
    cdef bytes hex_address_bytes
    cdef const unsigned char* hex_address_bytestr
    cdef object item
    cdef object seq
    cdef const unsigned char[:] packed_view
    cdef const unsigned char* packed_ptr
    cdef unsigned char* norm_ptr
    cdef unsigned char* hash_ptr
    cdef char* result_ptr
    cdef bytearray norm_hex
    cdef bytearray hashes
    cdef bytearray results
    cdef list output

    if isinstance(values, (bytes, bytearray, memoryview)):
        packed_view = values

        if packed_view.ndim != 1 or packed_view.itemsize != 1 or packed_view.strides[0] != 1:
            raise TypeError("Packed addresses must be a contiguous 1-D view of bytes.")

        packed_len = packed_view.shape[0]
        if packed_len % 20 != 0:
            raise ValueError("Packed address bytes length must be a multiple of 20.")

        n = packed_len // 20
        if n == 0:
            return []

        norm_hex = bytearray(n * 40)
        hashes = bytearray(n * 32)
        results = bytearray(n * 42)
        norm_ptr = norm_hex
        hash_ptr = hashes
        result_ptr = results
        packed_ptr = &packed_view[0]

        with nogil:
            for i in range(n):
                hexlify_c_string_to_buffer(packed_ptr + (i * 20), norm_ptr + (i * 40), 20)

            for i in prange(n, schedule="static"):
                keccak_256(norm_ptr + (i * 40), 40, hash_ptr + (i * 32))
                checksum_address_to_buffer(
                    result_ptr + (i * 42),
                    norm_ptr + (i * 40),
                    hash_ptr + (i * 32),
                )

        output = [None] * n
        for i in range(n):
            output[i] = PyUnicode_DecodeASCII(result_ptr + (i * 42), 42, NULL)
        return output

    if isinstance(values, str):
        raise TypeError("to_checksum_address_many expects a sequence of addresses, not a str.")

    seq = PySequence_Fast(values, "to_checksum_address_many expects a sequence of addresses.")
    n = PySequence_Fast_GET_SIZE(seq)
    if n == 0:
        return []

    norm_hex = bytearray(n * 40)
    hashes = bytearray(n * 32)
    results = bytearray(n * 42)
    norm_ptr = norm_hex
    hash_ptr = hashes
    result_ptr = results

    for i in range(n):
        item = <object>PySequence_Fast_GET_ITEM(seq, i)

        if isinstance(item, str):
            hex_address_bytes = lowercase_ascii_and_validate(PyUnicode_AsEncodedString(item, b"ascii", NULL))
            hex_address_bytestr = hex_address_bytes
        elif isinstance(item, (bytes, bytearray)):
            hex_address_bytes = hexlify(item)
            hex_address_bytestr = hex_address_bytes
        else:
            raise TypeError(
                f"Unsupported type: '{repr(type(item))}'. Must be one of: bool, str, bytes, bytearray or int."
            )

        if PyBytes_GET_SIZE(hex_address_bytes) != 40:
            raise ValueError(
                f"Unknown format {repr(item)}, attempted to normalize to '0x{hex_address_bytes.decode()}'"
            )

        memcpy(norm_ptr + (i * 40), hex_address_bytestr, 40)

    with nogil:
        for i in prange(n, schedule="static"):
            keccak_256(norm_ptr + (i * 40), 40, hash_ptr + (i * 32))
            checksum_address_to_buffer(
                result_ptr + (i * 42),
                norm_ptr + (i * 40),
                hash_ptr + (i * 32),
            )

    output = [None] * n
    for i in range(n):
        output[i] = PyUnicode_DecodeASCII(result_ptr + (i * 42), 42, NULL)
    return output


cpdef bytes hexlify(const unsigned char[:] src_buffer):
    return bytes(hexlify_unsafe(src_buffer, len(src_buffer)))


cdef const unsigned char[:] hexlify_unsafe(const unsigned char[:] src_buffer, Py_ssize_t num_bytes) noexcept:
    """Make sure your `num_bytes` is correct or ting go boom"""
    cdef unsigned char[:] result_buffer = bytearray(num_bytes * 2)  # contiguous and writeable
    with nogil:
        hexlify_memview_to_buffer(src_buffer, result_buffer, num_bytes)
    return result_buffer


cdef inline void hexlify_memview_to_buffer(
    const unsigned char[:] src_buffer, 
    unsigned char[:] result_buffer, 
    Py_ssize_t num_bytes,
) noexcept nogil:
    cdef Py_ssize_t i
    cdef unsigned char c
    for i in range(num_bytes):
        c = src_buffer[i]
        result_buffer[2*i] = hexdigits[c >> 4]
        result_buffer[2*i+1] = hexdigits[c & 0x0F]


cdef inline void hexlify_c_string_to_buffer(
    const unsigned char* src_buffer, 
    unsigned char* result_buffer, 
    Py_ssize_t num_bytes,
) noexcept nogil:
    cdef Py_ssize_t i
    cdef unsigned char c
    for i in range(num_bytes):
        c = src_buffer[i]
        result_buffer[2*i] = hexdigits[c >> 4]
        result_buffer[2*i+1] = hexdigits[c & 0x0F]


cdef inline void checksum_address_to_buffer(
    char* buffer,
    const unsigned char* norm_address_no_0x,
    const unsigned char* address_hash_bytes,
) noexcept nogil:
    cdef Py_ssize_t i
    cdef unsigned char hash_byte
    cdef unsigned char hash_nibble
    cdef unsigned char c

    buffer[0] = 48  # '0'
    buffer[1] = 120  # 'x'

    for i in range(40):
        c = norm_address_no_0x[i]
        hash_byte = address_hash_bytes[i >> 1]
        if i & 1:
            hash_nibble = hash_byte & 0x0F
        else:
            hash_nibble = hash_byte >> 4
        if hash_nibble < 8:
            buffer[i + 2] = c
        else:
            buffer[i + 2] = get_char(c)


cdef void populate_result_buffer(
    char[42] buffer,
    const unsigned char* norm_address_no_0x, 
    const unsigned char* address_hash,
) noexcept nogil:
    """
    Computes the checksummed version of an Ethereum address.

    This function takes a normalized Ethereum address (without the '0x' prefix) and its corresponding
    raw keccak hash bytes and returns the checksummed address as per the Ethereum Improvement
    Proposal 55 (EIP-55).

    Args:
        norm_address_no_0x: The normalized Ethereum address without the '0x' prefix.
        address_hash: The raw keccak hash bytes for the normalized address.

    Returns:
        The checksummed Ethereum address with the '0x' prefix.

    See Also:
        - :func:`eth_utils.to_checksum_address`: A utility function for converting addresses to their checksummed form.
    """
    cdef Py_ssize_t i
    cdef Py_ssize_t address_index
    cdef Py_ssize_t buffer_index
    cdef unsigned char hash_byte
    cdef unsigned char high_nibble
    cdef unsigned char low_nibble

    for i in range(20):
        hash_byte = address_hash[i]
        high_nibble = hash_byte >> 4
        low_nibble = hash_byte & 0x0F
        address_index = i * 2
        buffer_index = address_index + 2

        if high_nibble < 8:
            buffer[buffer_index] = norm_address_no_0x[address_index]
        else:
            buffer[buffer_index] = get_char(norm_address_no_0x[address_index])

        if low_nibble < 8:
            buffer[buffer_index + 1] = norm_address_no_0x[address_index + 1]
        else:
            buffer[buffer_index + 1] = get_char(norm_address_no_0x[address_index + 1])


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


cdef inline bint is_hex_lower(unsigned char c) noexcept nogil:
    return (48 <= c <= 57) or (97 <= c <= 102)


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
                c_string[i] = c

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
