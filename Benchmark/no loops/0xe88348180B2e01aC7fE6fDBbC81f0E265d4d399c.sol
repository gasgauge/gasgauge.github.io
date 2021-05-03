/**
 *Submitted for verification at Etherscan.io on 2020-09-13
*/

// SPDX-License-Identifier: SPDX-License-Identifiers

pragma solidity >=0.5 <0.7.17;


// 
contract Migrations {
  address public owner;
  uint public last_completed_migration;

  modifier restricted() {
    if (msg.sender == owner) _;
  }

  constructor() public {
    owner = msg.sender;
  }

  function setCompleted(uint completed) public restricted {
    last_completed_migration = completed;
  }

}