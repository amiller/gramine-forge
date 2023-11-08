## Gramine Foundry

Default IAS public key https://github.com/gramineproject/gramine/blob/master/tools/sgx/common/ias.c#L28

## Usage

### Build

```shell
$ forge build
```

### Tests
Running the tests with logs enables you to see the smart contract logs parsing and verifying the signature on the IAS report.
Running the 

```shell
$ forge test -vv --mc AttestVerify
$ forge test --ffi -vv --mc AttestForge
```
