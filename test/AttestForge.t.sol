// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.8;
import "solidity-stringutils/strings.sol";
import { BytesUtils } from "ens-contracts/dnssec-oracle/BytesUtils.sol";

import "forge-std/console2.sol";
import "forge-std/Test.sol";

import { MyRAVE } from "src/MyRave.sol";
import { AttestForge } from "src/AttestForge.sol";

contract AttestForgeTest is Test, MyRAVE {
    using strings for *;
    using BytesUtils for *;

    function testRemoteAttestationHighlevel() public view {
    	bytes memory attestation = AttestForge.attest("mytag");
	// console2.logBytes(attestation);

	verify(address(this), "mytag", attestation);
    }
}
