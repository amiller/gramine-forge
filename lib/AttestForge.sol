// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.8;

import "./Suave.sol";

interface Vm {
    function ffi(string[] calldata commandInput) external view returns (bytes memory result);
}

library AttestForge {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    function forgeIt(string memory addr, bytes memory data) internal view returns (bytes memory) {
        string memory dataHex = iToHex(data);

        string[] memory inputs = new string[](4);
        inputs[0] = "docker";
        inputs[1] = "forge";
        inputs[2] = addr;
        inputs[3] = dataHex;

        bytes memory res = vm.ffi(inputs);
        return res;
    }

    function iToHex(bytes memory buffer) public pure returns (string memory) {
        bytes memory converted = new bytes(buffer.length * 2);

        bytes memory _base = "0123456789abcdef";

        for (uint256 i = 0; i < buffer.length; i++) {
            converted[i * 2] = _base[uint8(buffer[i]) / _base.length];
            converted[i * 2 + 1] = _base[uint8(buffer[i]) % _base.length];
        }

        return string(abi.encodePacked("0x", converted));
    }
}