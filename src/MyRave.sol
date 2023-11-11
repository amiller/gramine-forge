// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.8;
import "solidity-stringutils/strings.sol";
import { Base64 } from "openzeppelin/utils/Base64.sol";
import { BytesUtils } from "ens-contracts/dnssec-oracle/BytesUtils.sol";
import { JSONBuilder2 } from "src/JSONBuilder.sol";
import {RAVE} from "rave/RAVE.sol";

contract AttestationDemo is JSONBuilder2, RAVE {
    using strings for *;
    using BytesUtils for *;

    function reportDataHelper(address addr, string memory tag) public pure returns(string memory) {
	// The last 32 bytes are defined by the caller
	// The first 20 bytes are an address
	string memory addr_str = string(iToHex(abi.encodePacked(addr)));
	//require(bytes(addr_str).length == 32);

	// Reconstruct the message
	bytes32 h = sha256(abi.encode(addr_str, tag));
	bytes memory b = abi.encodePacked(h);
	strings.slice memory s = addr_str.toSlice();
	s = s.concat("000000000000000000000000".toSlice()).toSlice();
	return s.concat(iToHex(b).toSlice());
    }

    function geturl(address addr, string memory tag) public pure returns(string memory) {
	string memory userReportData = reportDataHelper(addr, tag);
	strings.slice memory s = "http://dummyattest.ln.soc1024.com/forge-epid/".toSlice();
	return s.concat(userReportData.toSlice());
    }

    function decodeAttestation(bytes memory attestation) public pure returns(
	string memory id,
        string memory timestamp,
        string memory version,
        string memory epidPseudonym,
        string memory advisoryURL,
        string memory advisoryIDs,
        string memory isvEnclaveQuoteStatus,
	string memory platformInfoBlob,
        string memory isvEnclaveQuoteBody) {
	// Decode the outer layer, report and sig separately
	(bytes memory report, bytes memory sig) = abi.decode(attestation, (bytes, bytes));

	// Parse to RAVE structure and regenerate the canonical JSON
        (Values2 memory reportValues, bytes memory reportBytes) = _buildReportBytes2(report);
	
	id = string(reportValues.id);
	timestamp = string(reportValues.timestamp);
	version = string(reportValues.version);
	epidPseudonym = string(reportValues.epidPseudonym);
	advisoryURL = string(reportValues.advisoryURL);
	advisoryIDs = string(reportValues.advisoryIDs);
	isvEnclaveQuoteStatus = string(reportValues.isvEnclaveQuoteStatus);
	platformInfoBlob = string(reportValues.platformInfoBlob);
	isvEnclaveQuoteBody = iToHex(reportValues.isvEnclaveQuoteBody);
    }
    
    // See https://github.com/amiller/gramine-dummy-attester
    bytes32 public mrenclave = bytes32(hex"e3c2f2a5b840d89e069acaffcadb6510ef866a73d3a9ee57100ed5f8646ee4bb");

    // Hardcoded Intel public key
    bytes constant signingMod = hex"a97a2de0e66ea6147c9ee745ac0162686c7192099afc4b3f040fad6de093511d74e802f510d716038157dcaf84f4104bd3fed7e6b8f99c8817fd1ff5b9b864296c3d81fa8f1b729e02d21d72ffee4ced725efe74bea68fbc4d4244286fcdd4bf64406a439a15bcb4cf67754489c423972b4a80df5c2e7c5bc2dbaf2d42bb7b244f7c95bf92c75d3b33fc5410678a89589d1083da3acc459f2704cd99598c275e7c1878e00757e5bdb4e840226c11c0a17ff79c80b15c1ddb5af21cc2417061fbd2a2da819ed3b72b7efaa3bfebe2805c9b8ac19aa346512d484cfc81941e15f55881cc127e8f7aa12300cd5afb5742fa1d20cb467a5beb1c666cf76a368978b5";
    bytes constant signingExp = hex"0000000000000000000000000000000000000000000000000000000000010001";

    function verify_epid(string memory userReportData, bytes memory attestation) public view returns(bool) {

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

	return true;
    }

    function _buildReportBytes2(bytes memory encodedReportValues)
        internal
        pure
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
