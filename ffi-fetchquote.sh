#!/bin/bash
# Assumes you pass in a 64 byte hex-encoded string (so 128 characters)
# Fetches from the dummy attester
# TODO: this will not remain reliable!
curl -s http://dummyattest.ln.soc1024.com/$1
