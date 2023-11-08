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
    obj = urllib.request.urlopen(f"http://dummyattest.ln.soc1024.com/{msg}").read()
    obj = json.loads(obj)    

    report = obj['report']
    items = (report['id'].encode(),
             report['timestamp'].encode(),
             str(report['version']).encode(),
             report['epidPseudonym'].encode(),
             report['advisoryURL'].encode(),
             json.dumps(report['advisoryIDs']).replace(' ','').encode(),
             report['isvEnclaveQuoteStatus'].encode(),
             report['platformInfoBlob'].encode(),
             base64.b64decode(report['isvEnclaveQuoteBody']))
    abidata = eth_abi.encode(["bytes", "bytes", "bytes", "bytes", "bytes", "bytes", "bytes", "bytes", "bytes"], items)
    sig = base64.b64decode(obj['reportsig'])
    print("abidata:")
    print(hexlify(abidata))
    print("sig:")
    print(hexlify(sig))
