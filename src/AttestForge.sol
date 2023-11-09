// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.8;
import "solidity-stringutils/strings.sol";

/* This produces an EPID attestation by querying a remote service.
 */

interface Vm {
    function ffi(string[] calldata commandInput) external view returns (bytes memory result);
}

library AttestForge {
    using strings for *;
    
    Vm constant vm2 = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    function attest_epid(string memory tag) view internal returns (bytes memory) {
    	string memory userReportData = _userReportData(msg.sender, tag);
        string[] memory inputs = new string[](3);
        inputs[0] = "python";
        inputs[1] = "ffi-fetchquote-epid.py";
        inputs[2] = userReportData;
        bytes memory res = vm2.ffi(inputs);
	return res;
    }
    
    function attest_dcap(string memory tag) view internal returns (bytes memory) {
    	string memory userReportData = _userReportData(msg.sender, tag);
        string[] memory inputs = new string[](3);
        inputs[0] = "python";
        inputs[1] = "ffi-fetchquote-dcap.py";
        inputs[2] = userReportData;
        bytes memory res = vm2.ffi(inputs);
	return res;
    }

    function _userReportData(address addr, string memory tag) pure internal returns (string memory) {
	string memory a = string(iToHex(abi.encodePacked(addr)));
	bytes32 h = sha256(abi.encode(a, tag));
	bytes memory b = abi.encodePacked(h);
	strings.slice memory s = a.toSlice();
	s = s.concat("000000000000000000000000".toSlice()).toSlice();
	return s.concat(iToHex(b).toSlice());
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
