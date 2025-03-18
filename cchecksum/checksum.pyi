from typing import Union

from eth_typing import AnyAddress, ChecksumAddress


def to_checksum_address(value: Union[AnyAddress, str, bytes]) -> ChecksumAddress:
  ...
