// SPDX-License-Identifier: Apache-2.0
//pragma solidity >=0.6.12;
pragma solidity >=0.5 <0.7.17;

contract Migrations {
    address public owner;
    uint256 public last_completed_migration;

    modifier restricted() {
        if (msg.sender == owner) _;
    }

    constructor() public {
        owner = msg.sender;
    }

    function setCompleted(uint256 completed) public restricted {
        last_completed_migration = completed;
    }
}
