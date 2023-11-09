// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.8;
import "solidity-stringutils/strings.sol";
import { BytesUtils } from "ens-contracts/dnssec-oracle/BytesUtils.sol";

import "forge-std/console2.sol";
import "forge-std/Test.sol";

import { AttestationDemo } from "src/MyRave.sol";
import { AttestForge } from "src/AttestForge.sol";

contract HighLevelAttestationTest is Test, AttestationDemo {
    using strings for *;
    using BytesUtils for *;

    function testRemoteAttestationHighlevel() public view {
    	bytes memory attestation = AttestForge.attest_epid("mytag");

	// console2.logBytes(attestation);

	verify_epid(address(this), "mytag", attestation);
    }

    function testRemoteAttestationHighlevelDcap() public view {
    	bytes memory attestation = AttestForge.attest_dcap("mytag");

	console2.logBytes(attestation);

	//verify_dcap(address(this), "mytag", attestation);
    }
}
