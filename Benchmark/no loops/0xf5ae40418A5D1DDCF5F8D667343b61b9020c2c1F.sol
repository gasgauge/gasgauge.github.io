/**
 *Submitted for verification at Etherscan.io on 2020-09-15
*/

pragma solidity >=0.5 <0.7.17;

contract Storage {
    uint256 public counter = 1;

    function increment() public {
        require(counter < 3, "Expired counter contract");
        counter++;
    }

}