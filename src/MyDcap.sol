// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.8;
import "solidity-stringutils/strings.sol";
import { Base64 } from "openzeppelin/utils/Base64.sol";
import { BytesUtils } from "ens-contracts/dnssec-oracle/BytesUtils.sol";

import {AutomataDcapV3Attestation} from "automata-dcap-v3-attestation/AutomataDcapV3Attestation.sol";

import "forge-std/console.sol";
import "forge-std/Vm.sol";
import "forge-std/StdJson.sol";

contract DcapDemo is AutomataDcapV3Attestation {

     
/*    function 
  {
    var enclaveId = parseEnclaveId();
    await attestation.configureQeIdentityJson(enclaveId);
    console.log("configureQeIdentityJson");
  }
  {
    const tcbInfo = parseTcbInfo();
    await attestation.configureTcbInfoJson(tcbInfo.fmspc, tcbInfo);
    console.log("configureTcbInfoJson");
    }*/
    constructor() AutomataDcapV3Attestation(address(0)) {

    }
}
