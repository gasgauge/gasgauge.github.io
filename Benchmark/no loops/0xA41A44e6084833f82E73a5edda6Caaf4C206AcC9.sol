/**
 *Submitted for verification at Etherscan.io on 2020-09-14
*/

// SPDX-License-Identifier: No License (None)
pragma solidity >=0.5 <0.7.17;

interface IERC20Token {
    function transfer(address _to, uint256 _value) external returns (bool);
    function approve(address _spender, uint256 _value) external returns (bool);
}

contract RealEstate {

    address public owner;     

    event Transfer(address indexed from, address indexed to, uint256 value, address indexed token);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner,"Not Owner");
        _;
    }

    // set GovernanceProxy as Owner
    constructor(address newOwner) public {
        require(newOwner != address(0),"Zero address not allowed");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0),"Zero address not allowed");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    // transfer tokens/ETH to selected wallet. If token == address(0), transfer ETH
    function transfer(address payable to, uint256 value, address token) external onlyOwner {
        if (token == address(0)) {
            to.transfer(value);
        }
        else {
            IERC20Token(token).transfer(to, value);
        }
        emit Transfer(address(this), to, value, token);
    }


    // approve spender to transfer tokens
    function approve(address spender, uint256 value, address token) external onlyOwner {
        IERC20Token(token).approve(spender, value);
    }

    /**
     * @dev Trigger arbitrary function on target address.
     * @param target The target address (contract) to call
     * @param params encoded params
     */
    function trigger(address target, bytes calldata params) external onlyOwner {
        target.call(params);
    }

    // accept ETH
   function receive() external payable {
    }

}