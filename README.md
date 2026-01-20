## CChecksum

[![PyPI](https://img.shields.io/pypi/v/cchecksum.svg?logo=Python&logoColor=white)](https://pypi.org/project/cchecksum/)
[![Monthly Downloads](https://img.shields.io/pypi/dm/cchecksum)](https://pypistats.org/packages/cchecksum)

CChecksum is an ~18x faster drop-in replacement for `eth_utils.to_checksum_address`, with the most cpu-intensive part implemented in C.

It keeps the exact same API as the existing implementation, exceptions and all.

Just `pip install cchecksum`, drop it in, and run your script with a substantial speed improvement.

![image](https://github.com/user-attachments/assets/b989108f-350d-45a1-93c0-c1eaa3d8b801)
