/**

 *Submitted for verification at Etherscan.io on 2020-12-25

*/



library TxDataBuilder {

    string constant public RTTD_FUNCHASH = '0829d713'; // WizRefund - refundTokensTransferredDirectly

    string constant public EFWD_FUNCHASH = 'eee48b02'; // WizRefund - clearFinalWithdrawData

    string constant public FR_FUNCHASH =   '492b2b37'; // WizRefund - forceRegister

    string constant public RP_FUNCHASH =   '422a042e'; // WizRefund - revertPhase

    string constant public WETH_FUNCHASH =   '4782f779'; // WizRefund - withdrawETH



    function uint2bytes32(uint256 x)

        public

        pure returns (bytes memory b) {

            b = new bytes(32);

            assembly { mstore(add(b, 32), x) }

    }

    

    function uint2bytes8(uint256 x)

        public

        pure returns (bytes memory b) {

            b = new bytes(32);

            assembly { mstore(add(b, 32), x) }

    }

    

    function concatb(bytes memory self, bytes memory other)

        public

        pure returns (bytes memory) {

             return bytes(abi.encodePacked(self, other));

        }

        

    // Convert an hexadecimal character to their value

    function fromHexChar(uint8 c) public pure returns (uint8) {

        if (bytes1(c) >= bytes1('0') && bytes1(c) <= bytes1('9')) {

            return c - uint8(bytes1('0'));

        }

        if (bytes1(c) >= bytes1('a') && bytes1(c) <= bytes1('f')) {

            return 10 + c - uint8(bytes1('a'));

        }

        if (bytes1(c) >= bytes1('A') && bytes1(c) <= bytes1('F')) {

            return 10 + c - uint8(bytes1('A'));

        }

        require(false, "unknown variant");

    }

    

    // Convert an hexadecimal string to raw bytes

    function fromHex(string memory s) public pure returns (bytes memory) {

        bytes memory ss = bytes(s);

        require(ss.length%2 == 0); // length must be even

        bytes memory r = new bytes(ss.length/2);

        for (uint i=0; i<ss.length/2; ++i) {

            r[i] = bytes1(fromHexChar(uint8(ss[2*i])) * 16 +

                        fromHexChar(uint8(ss[2*i+1])));

        }

        return r;

    }



    function buildData(string memory function_hash, uint256[] memory argv)

        public

        pure returns (bytes memory data){

            bytes memory f = fromHex(function_hash);

            data = concatb(data, f);

            for(uint i=0;i<argv.length;i++){

                bytes memory d = uint2bytes32(argv[i]);

                data = concatb(data, d);

            }

    }

}
