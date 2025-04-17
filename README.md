## CChecksum

CChecksum is a ~5x faster drop-in replacement for eth_utils.to_checksum_address, with the most cpu-intensive part implemented in c.

It keeps the exact same API as the existing implementation, exceptions and all.

Just `pip install cchecksum`, drop it in, and run your script with a substantial speed improvement.

![image](https://github.com/user-attachments/assets/f2732c1f-f36e-486c-9258-cdeb09bb5eb5)
