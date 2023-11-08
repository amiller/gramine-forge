// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "solidity-stringutils/strings.sol";
import {Script, console2} from "forge-std/Script.sol";
import {AttestForge} from "src/AttestForge.sol";
import {RAVE} from "rave/RAVE.sol";

contract MyRAVE is RAVE {

    // This is parsed from the Gramine default public key
    // https://github.com/gramineproject/gramine/blob/master/tools/sgx/common/ias.c#L28
    // Also the same as RealIntelKey in RAVE
    //
    bytes signingMod = hex"a97a2de0e66ea6147c9ee745ac0162686c7192099afc4b3f040fad6de093511d74e802f510d716038157dcaf84f4104bd3fed7e6b8f99c8817fd1ff5b9b864296c3d81fa8f1b729e02d21d72ffee4ced725efe74bea68fbc4d4244286fcdd4bf64406a439a15bcb4cf67754489c423972b4a80df5c2e7c5bc2dbaf2d42bb7b244f7c95bf92c75d3b33fc5410678a89589d1083da3acc459f2704cd99598c275e7c1878e00757e5bdb4e840226c11c0a17ff79c80b15c1ddb5af21cc2417061fbd2a2da819ed3b72b7efaa3bfebe2805c9b8ac19aa346512d484cfc81941e15f55881cc127e8f7aa12300cd5afb5742fa1d20cb467a5beb1c666cf76a368978b5";
    bytes signingExp = hex"0000000000000000000000000000000000000000000000000000000000010001";

    function _test() public returns (bytes memory, bytes memory) {
	bytes memory report = bytes('{"id":"283153309678498271859614468020545074257","timestamp":"2023-11-08T15:52:18.615054","version":4,"epidPseudonym":"+CUyIi74LPqS6M0NF7YrSxLqPdX3MKs6D6LIPqRG/ZEB4WmxZVvxAJwdwg/0m9cYnUUQguLnJotthX645lAogajJudnCGgfocC8HhUTJ+oa3QD2mqzXheQU6scYX/ZLbK+uDRTkt6YNI4El8ZRI0Gzf4GR/7kTK49+MN83x82CE=","advisoryURL":"https://security-center.intel.com","advisoryIDs":["INTEL-SA-00161","INTEL-SA-00219","INTEL-SA-00289","INTEL-SA-00334","INTEL-SA-00615","INTEL-SA-00828"],"isvEnclaveQuoteStatus":"GROUP_OUT_OF_DATE","platformInfoBlob":"150200650400090000141402040180070000000000000000000D00000C000000020000000000000C4F2686E86A8413B0A4B80943A15887147729655B6E11210FA64063AEF1E54C0EC1149026AAA7EA10BF26CBC4D176C4923237AF04B8935F7AA42993DE272F9FD02E","isvEnclaveQuoteBody":"AgABAE8MAAAPAA8AAAAAAFHK9aSLRQ1iSu/jKG0xSJQAAAAAAAAAAAAAAAAAAAAAExQCBwGAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABQAAAAAAAAAHAAAAAAAAAKy8MV6cNy5D3O7oEvRm/DZZT2QC0WjPKxKGKjfDxiknAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAc8uUpEUEPvz8ZkFapjVh5WlWaLoAJM/f80T0EhGInHAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACRE7C+d+1dDWhoDsdyBrjVh+1AZ5txMhzN1UBeTVSmggAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"}');
	//bytes memory sig = bytes("pIFevMEo07fOlEqgkrKmg2Q0zzUH0ORGFpF4IYRQSL3xomizVcW3XAcRxHS7iHODSgKEF/yHlpoYtbbNEXxp4+8PDEKLHLTnkKVqMXmTKkiL/QwwNyaSGXTvhsYoUixT5kE6EWKvlchG41sNZvHAfVdcDvYhO9Wkh/+w4pN57MjydcPfebkgFrpovzie9ujgLWwHDAut10v47eV+/x89QSq+i/nGr/akE5DtgC8OzLqBsVUDwV9CzoTx5e8h0W5o5HztJvZRvvEnIvuoSFyIiVcDUWoPaJQ46NujhH216AZw432t2ZCa/pNV4cPkehiV/emoILaEqiYNA206V0nk0A==");
	bytes memory sig = hex"a4815ebcc128d3b7ce944aa092b2a6836434cf3507d0e44616917821845048bdf1a268b355c5b75c0711c474bb8873834a028417fc87969a18b5b6cd117c69e3ef0f0c428b1cb4e790a56a3179932a488bfd0c303726921974ef86c628522c53e6413a1162af95c846e35b0d66f1c07d575c0ef6213bd5a487ffb0e29379ecc8f275c3df79b92016ba68bf389ef6e8e02d6c070c0badd74bf8ede57eff1f3d412abe8bf9c6aff6a41390ed802f0eccba81b15503c15f42ce84f1e5ef21d16e68e47ced26f651bef12722fba8485c88895703516a0f689438e8dba3847db5e80670e37dadd9909afe9355e1c3e47a1895fde9a820b684aa260d036d3a5749e4d0";
	return (report, sig);
    }
    
    function run() public {
        (bytes memory reportBytes, bytes memory sig) = _test();
        bytes32 mrenclave;
        bytes32 mrsigner;

        // Verify the report was signed by the Signing PK
        if (!this.verifyReportSignature(reportBytes, sig, signingMod, signingExp)) {
            revert BadReportSignature();
        }
        // Verify the report's contents match the expected
        //bytes memory payload = _verifyReportContents(reportValues, mrenclave, mrsigner);
	//this.verifyRemoteAttestation(report, sig, signingMod, signingExp, mrenclave, mrsigner);
    }
}



contract Test is Script {
    using strings for *;
    
    function setUp() public {}

    function run() public {
	console2.log(AttestForge.attest("run"));
    }
}
