/**

 *Submitted for verification at Etherscan.io on 2020-12-19

*/



//pragma solidity ^0.5.10;
pragma solidity >=0.5 <0.7.17;



contract GasToken1 {

    function free(uint256 value) public returns (bool success);

    function freeUpTo(uint256 value) public returns (uint256 freed);

    function freeFrom(address from, uint256 value) public returns (bool success);

    function freeFromUpTo(address from, uint256 value) public returns (uint256 freed);

}



contract ERC918Interface {

  function mint(uint256 nonce, bytes32 challenge_digest) public returns (bool success);

}

contract BurnGas {



    // This function consumes a lot of gas

    function expensiveStuff(address mToken, uint256 nonce, bytes32 challenge_digest) private {

        require(ERC918Interface(mToken).mint(nonce, challenge_digest), "Could not mint token");

    }



    /*

     * Frees free' tokens from the Gastoken at address gas_token'.

     * The freed tokens belong to this Example contract. The gas refund can pay

     * for up to half of the gas cost of the total transaction in which this 

     * call occurs.

     */

    function burnGasAndFree(address gas_token, uint256 free, address mToken, uint256 nonce, bytes32 challenge_digest) public {

        require(GasToken1(gas_token).free(free), "Could not free");

        expensiveStuff(mToken, nonce, challenge_digest);

    }

}
