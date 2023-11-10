#!/usr/bin/env bash
set -x

if [ -f .env ]
then
  export $(cat .env | xargs) 
else
    echo "Please set your .env file"
    exit 1
fi

# Sepolia
# forge create ./src/MyRave.sol:AttestationDemo --libraries lib/rave/src/X509Verifier.sol:X509Verifier:0x5712bdf16e06e923149606cf658F101B79143213 -i --rpc-url 'https://sepolia.infura.io/v3/'${INFURA_API_KEY} --private-key ${PRIVATE_KEY}
LIBSTR="--libraries lib/rave/src/X509Verifier.sol:X509Verifier:0x5712bdf16e06e923149606cf658F101B79143213"

forge create ./src/MyRave.sol:AttestationDemo -i $LIBSTR --rpc-url 'https://sepolia.infura.io/v3/'${INFURA_API_KEY} --private-key ${PRIVATE_KEY}
#contract=0x9a7A7fb1fcc8A1BcDc12fBB2844C712D55bC2850
#forge verify-contract --compiler-version v0.8.20 --num-of-optimizations 200 $LIBSTR --chain-id 11155111 $contract ./src/MyRave.sol:AttestationDemo
