// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.8;
import "solidity-stringutils/strings.sol";

interface Vm {
    function ffi(string[] calldata commandInput) external view returns (bytes memory result);
}

library AttestForge {
    using strings for *;
    
    Vm constant vm2 = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    function attest(string memory tag) view internal returns (string memory) {
	bytes memory res = forgeIt(string(iToHex(abi.encodePacked(msg.sender))), tag);
	return string(res);
    }

    function forgeIt(string memory addr, string memory tag) internal view returns (bytes memory) {
	bytes32 h = sha256(abi.encode(addr, tag));
	bytes memory b = abi.encodePacked(h);
	strings.slice memory s = addr.toSlice();
	s = s.concat("000000000000000000000000".toSlice()).toSlice();
	string memory dataHex = s.concat(iToHex(b).toSlice());

        string[] memory inputs = new string[](3);
        inputs[0] = "bash";
        inputs[1] = "ffi-fetchquote.sh";
        inputs[2] = dataHex;

        bytes memory res = vm2.ffi(inputs);
        return res;
    }

    function iToHex(bytes memory buffer) public pure returns (string memory) {
        // Fixed buffer size for hexadecimal convertion
        bytes memory converted = new bytes(buffer.length * 2);
        bytes memory _base = "0123456789abcdef";
        for (uint256 i = 0; i < buffer.length; i++) {
            converted[i * 2] = _base[uint8(buffer[i]) / _base.length];
            converted[i * 2 + 1] = _base[uint8(buffer[i]) % _base.length];
        }
        return string(converted);
    }
}
