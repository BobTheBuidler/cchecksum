from cchecksum._checksum import to_checksum_address


def monkey_patch_eth_utils() -> None:
    """Monkey patch eth_utils to use cchecksum's implementation internally."""
    import eth_utils
    import eth_utils.address
  
    eth_utils.to_checksum_address = to_checksum_address
    eth_utils.address.to_checksum_address = to_checksum_address


def monkey_patch_web3py() -> None:
    """Monkey patch web3.py to use cchecksum's implementation internally."""
    import web3._utils as web3_utils
    import web3.main as web3_main
    import web3.middleware as web3_middleware

    web3_main.to_checksum_address = to_checksum_address
    web3_utils.ens.to_checksum_address = to_checksum_address
    web3_utils.method_formatters.to_checksum_address = to_checksum_address
    web3_utils.normalizers.to_checksum_address = to_checksum_address
    web3_middleware.signing.to_checksum_address = to_checksum_address

    try:
        import web3.utils.address as web3_address

        web3_address.to_checksum_address = to_checksum_address
    except ModuleNotFoundError:
        # youre on an older web3py, no monkey patch for you
        pass

    try:
        import ens.ens

        ens.ens.to_checksum_address = to_checksum_address
    except ModuleNotFoundError:
        # youre on an older web3py, no monkey patch for you
        pass

    try:
        import ens.async_ens

        ens.async_ens.to_checksum_address = to_checksum_address
    except ModuleNotFoundError:
        # youre on an older web3py, no monkey patch for you
        pass
