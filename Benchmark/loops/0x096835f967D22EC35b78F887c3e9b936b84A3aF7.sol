/**
 *Submitted for verification at Etherscan.io on 2020-12-16
*/

// hevm: flattened sources of src/gemForRewardChecker.sol
//pragma solidity >0.4.13 >=0.4.23 >=0.5.12 >=0.5.0 <0.6.0 >=0.5.10 <0.6.0 >=0.5.12 <0.6.0;
pragma solidity >=0.5 <0.7.17;

////// src/gemForRewardChecker.sol
/* pragma solidity ^0.5.12; */

contract GemForRewardChecker {
    address[] public checkers;
    address public deployer;

    constructor() public {
        deployer = msg.sender;
    }

    function addChecker(address checker) public {
        require(deployer == msg.sender, "addChecker/auth-error");
        checkers.push(checker);
    }

    function check(address gem) external returns (bool) {
        for (uint256 i = 0; i < checkers.length; i++) {
            (bool ret, ) = checkers[i].call(abi.encodeWithSignature("check(address)", gem));
            if (ret) {
                return true;
            }
        }

        return false;
    }
}
