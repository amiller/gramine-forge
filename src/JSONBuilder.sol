// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.0 <0.9.0;

contract JSONBuilder2 {
    struct Values2 {
        bytes id;
        bytes timestamp;
        bytes version;
        bytes epidPseudonym;
        bytes advisoryURL;
        bytes advisoryIDs;
        bytes isvEnclaveQuoteStatus;
	bytes platformInfoBlob;	
        bytes isvEnclaveQuoteBody;
    }

    function buildJSON2(Values2 memory values) public pure returns (string memory json) {
        json = string(
            abi.encodePacked(
                '{"id":"',
                values.id,
                '","timestamp":"',
                values.timestamp,
                '","version":',
                values.version,
                ',"epidPseudonym":"',
                values.epidPseudonym
            )
        );
        json = string(
            abi.encodePacked(
                json,
                '","advisoryURL":"',
                values.advisoryURL,
                '","advisoryIDs":',
                values.advisoryIDs,
                ',"isvEnclaveQuoteStatus":"',
                values.isvEnclaveQuoteStatus,
                '","platformInfoBlob":"',
                values.platformInfoBlob,
                '","isvEnclaveQuoteBody":"',
                values.isvEnclaveQuoteBody,
                '"}'
            )
        );
    }
}