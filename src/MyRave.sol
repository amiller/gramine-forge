// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.8;
import "solidity-stringutils/strings.sol";
import { Base64 } from "openzeppelin/utils/Base64.sol";
import { BytesUtils } from "ens-contracts/dnssec-oracle/BytesUtils.sol";
import { JSONBuilder2 } from "src/JSONBuilder.sol";
import {RAVE} from "rave/RAVE.sol";

contract MyRAVE is JSONBuilder2, RAVE {
    using strings for *;

    function _buildReportBytes2(bytes memory encodedReportValues)
        internal
        view
        returns (Values2 memory reportValues, bytes memory reportBytes)
    {
        // Decode the report JSON values
        (
            bytes memory id,
            bytes memory timestamp,
            bytes memory version,
            bytes memory epidPseudonym,
            bytes memory advisoryURL,
            bytes memory advisoryIDs,
            bytes memory isvEnclaveQuoteStatus,
	    bytes memory platformInfoBlob,
            bytes memory isvEnclaveQuoteBody
        ) = abi.decode(encodedReportValues, (bytes, bytes, bytes, bytes, bytes, bytes, bytes, bytes, bytes));

        // Assumes the quote body was already decoded off-chain
        bytes memory encBody = bytes(Base64.encode(isvEnclaveQuoteBody));

        // Pack values to struct
        reportValues = Values2(
            id, timestamp, version, epidPseudonym, advisoryURL, advisoryIDs, isvEnclaveQuoteStatus, platformInfoBlob, encBody
        );

        // Reconstruct the JSON report that was signed
        reportBytes = bytes(buildJSON2(reportValues));

        // Pass on the decoded value for later processing
        reportValues.isvEnclaveQuoteBody = isvEnclaveQuoteBody;
    }

}
