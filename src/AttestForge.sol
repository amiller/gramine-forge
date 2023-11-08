// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.8;
import "solidity-stringutils/strings.sol";

interface Vm {
    function ffi(string[] calldata commandInput) external view returns (bytes memory result);
}

contract AttestForge {
    using strings for *;
    
    Vm constant vm2 = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    function attest() view internal returns (string memory) {
	bytes memory res = forgeIt(string(abi.encodePacked(msg.sender)), bytes(''));
	return string(res);
    }

    function forgeIt(string memory addr, bytes memory data) internal view returns (bytes memory) {
        string memory dataHex = "9113b0be77ed5d0d68680ec77206b8d587ed40679b71321ccdd5405e4d54a6820000000000000000000000000000000000000000000000000000000000000000";

        string[] memory inputs = new string[](3);
        inputs[0] = "bash";
        inputs[1] = "ffi-fetchquote.sh";
        inputs[2] = dataHex;

        bytes memory res = vm2.ffi(inputs);
        return res;
    }
}
