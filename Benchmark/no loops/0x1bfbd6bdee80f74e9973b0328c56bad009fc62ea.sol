/**
 *Submitted for verification at Etherscan.io on 2020-09-12
*/

pragma solidity >=0.5 <0.7.17;


// SPDX-License-Identifier: MIT
contract Migrations {
  address public owner = msg.sender;
  uint public last_completed_migration;

  modifier restricted() {
    require(
      msg.sender == owner,
      "This function is restricted to the contract's owner"
    );
    _;
  }

  function setCompleted(uint completed) public restricted {
    last_completed_migration = completed;
  }

}