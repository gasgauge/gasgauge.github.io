/**
 *Submitted for verification at Etherscan.io on 2020-09-11
*/

//
// by Agustin Aguilar <[email protected]>
//
pragma solidity >=0.5 <0.7.17;
contract NanoUniversalDeployer {
    event Deploy(address _addr) anonymous;

    function() external payable {
        address addr;
        bytes memory code = msg.data;
        assembly { addr := create2(callvalue(), add(code, 32), mload(code), 0) }
        emit Deploy(addr);
    }

}