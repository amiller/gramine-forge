// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {AttestForge} from "src/AttestForge.sol";

contract Test is Script, AttestForge {

    function setUp() public {}

    function run() public {
	console2.log(attest());
    }
}

