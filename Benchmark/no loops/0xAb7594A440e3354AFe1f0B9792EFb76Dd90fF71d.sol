/**
 *Submitted for verification at Etherscan.io on 2020-09-14
*/

// SPDX-License-Identifier: No License (None)
pragma solidity >=0.5 <0.7.17;

// This contract address should be the Owner of other contracts which setting we will change.
contract GovernanceProxy {
    address public governance;
    address public _newGovernance;
    event ChangeGovernance(address indexed previousGovernance, address indexed newGovernance);

    /**
     * @dev Throws if called by any account other than the Governance (Voting system).
     */
    modifier onlyGovernance() {
        require(governance == msg.sender, "Not Governance");
        _;
    }

    /**
     * @dev The constructor sets the original `governance` system
     * @param newGovernance The address of Governance smart contract
     */
    constructor (address newGovernance) public {
        require(newGovernance != address(0),"Zero address not allowed");
        emit ChangeGovernance(governance, newGovernance);
        governance = newGovernance;
    }

    /**
     * @dev Transfers control of the contract to a newGovernance.
     * @param newGovernance The new address of Governance smart contract.
     */
    function SetNewGovernance(address newGovernance) external {
        require(address(this) == msg.sender, "Not allowed");
        require(newGovernance != address(0),"Zero address not allowed");
        _newGovernance = newGovernance;
    }

    /**
     * @dev Accept Governance from new Governance contract address.
     */    
    function acceptGovernanceAddress() external {
        require(msg.sender == _newGovernance, "Not allowed");
        emit ChangeGovernance(governance, _newGovernance);
        governance = _newGovernance;
    }    

    /**
     * @dev Apply changes from Governance System. Call destination contract.
     * @param contr The contract address to call
     * @param params encoded params
     */
    function trigger(address contr, bytes calldata params) external onlyGovernance {
        contr.call(params);
    }

}