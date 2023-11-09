// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "solidity-stringutils/strings.sol";
import {Script, console2} from "forge-std/Script.sol";
//import {AttestForge} from "src/AttestForge.sol";
import {RAVE} from "rave/RAVE.sol";

contract Test is Script {
    using strings for *;
    
    function setUp() public {}

    function run() public {
	//console2.logBytes(AttestForge.attest("run"));
    }
}
