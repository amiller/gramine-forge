// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.8;
import "solidity-stringutils/strings.sol";
import { Base64 } from "openzeppelin/utils/Base64.sol";
import { BytesUtils } from "ens-contracts/dnssec-oracle/BytesUtils.sol";
import { JSONBuilder2 } from "src/JSONBuilder.sol";
import {RAVE} from "rave/RAVE.sol";

contract MyRAVE is JSONBuilder2, RAVE {
    using strings for *;
    using BytesUtils for *;
    
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

    bytes32 mrenclave = bytes32(hex"acbc315e9c372e43dceee812f466fc36594f6402d168cf2b12862a37c3c62927");

    bytes constant signingMod = hex"a97a2de0e66ea6147c9ee745ac0162686c7192099afc4b3f040fad6de093511d74e802f510d716038157dcaf84f4104bd3fed7e6b8f99c8817fd1ff5b9b864296c3d81fa8f1b729e02d21d72ffee4ced725efe74bea68fbc4d4244286fcdd4bf64406a439a15bcb4cf67754489c423972b4a80df5c2e7c5bc2dbaf2d42bb7b244f7c95bf92c75d3b33fc5410678a89589d1083da3acc459f2704cd99598c275e7c1878e00757e5bdb4e840226c11c0a17ff79c80b15c1ddb5af21cc2417061fbd2a2da819ed3b72b7efaa3bfebe2805c9b8ac19aa346512d484cfc81941e15f55881cc127e8f7aa12300cd5afb5742fa1d20cb467a5beb1c666cf76a368978b5";
    bytes constant signingExp = hex"0000000000000000000000000000000000000000000000000000000000010001";

    function verify(address addr, string memory tag, bytes memory attestation) public view {
	// Check that the last 32 bytes match the tag
	string memory addr_str = string(iToHex(abi.encodePacked(msg.sender)));
	       
	// Reconstruct the message
	bytes32 h = sha256(abi.encode(addr_str, tag));
	bytes memory b = abi.encodePacked(h);
	strings.slice memory s = addr_str.toSlice();
	s = s.concat("000000000000000000000000".toSlice()).toSlice();
	string memory userReportData = s.concat(iToHex(b).toSlice());

	// Decode the outer layer, report and sig separately
	(bytes memory report, bytes memory sig) = abi.decode(attestation, (bytes, bytes));

	// Parse to RAVE structure and regenerate the canonical JSON
        (Values2 memory reportValues, bytes memory reportBytes) = _buildReportBytes2(report);
        if (!this.verifyReportSignature(reportBytes, sig, signingMod, signingExp)) {
            revert BadReportSignature();
        }

        // quote body is already base64 decoded
        bytes memory quoteBody = reportValues.isvEnclaveQuoteBody;
        assert(quoteBody.length == QUOTE_BODY_LENGTH);

        // Verify report's MRENCLAVE matches the expected
        bytes32 mre = quoteBody.readBytes32(MRENCLAVE_OFFSET);
        require(mre == mrenclave);

	// Bypass status check
	// Bypass mrsigner check

        // Verify report's <= 64B payload matches the expected
        bytes memory payload = quoteBody.substring(PAYLOAD_OFFSET, PAYLOAD_SIZE);
	require(bytes(iToHex(payload)).equals(bytes(userReportData)));
    }

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