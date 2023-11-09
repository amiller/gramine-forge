import json
import sys
import urllib.request
import eth_abi
import base64
from binascii import hexlify

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print('Usage: python ffi-fetchquote.py 00....00   (a 64-byte hex)')
        sys.exit(1)
    msg = sys.argv[1]
    assert len(bytes.fromhex(msg)) == 64
    attestation = urllib.request.urlopen(f"http://dummyattest.ln.soc1024.com/forge-epid/{msg}").read()
    sys.stdout.buffer.write(attestation)
