/**
 *Submitted for verification at Etherscan.io on 2020-09-11
*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.5 <0.7.17;

 contract ERC20 {
  uint256 public totalSupply;

  function balanceOf(address who) public view  returns (uint256);
  function transfer(address to, uint256 value) public  returns (bool);
  function allowance(address owner, address spender) public view  returns (uint256);
  function transferFrom(address from, address to, uint256 value) public  returns (bool);
  function approve(address spender, uint256 value) public  returns (bool);

  event Approval(address indexed owner, address indexed spender, uint256 value);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ClerkTeamReserve {

    address public owner;
    uint256 public unlockDate;

    modifier onlyOwner {
        require(msg.sender == owner, "You are not the owner");
        _;
    }

    constructor () public{
        owner = address(0x0c51Cc43FbfD7E273181197a800fE70f056BD771); // The reserves wallet address
        unlockDate = 1630454400; // 1st of September 2021 @ 12:00 am (UTC)
    }

    // This can only ever be incremented - never decreased
    function updateUnlockDate(uint256 _newDate) onlyOwner public {
        require(_newDate > unlockDate, "Date specified is less than current unlock date");
        unlockDate = _newDate;
    }

    // keep all tokens sent to this address
    function receive() external payable  {
        emit Received(msg.sender, msg.value);
    }

    // callable by owner only, after specified time
    function withdrawAll() onlyOwner public {
       require(block.timestamp >= unlockDate);
       // withdraw balance
       msg.sender.transfer(address(this).balance);
       emit Withdrew(msg.sender, address(this).balance);
    }

    // callable by owner only, after specified time, only for Tokens implementing ERC20
    function withdrawERC20(address _tokenContract) onlyOwner public {
       require(block.timestamp >= unlockDate, "Funds cannot be withdrawn yet");
       ERC20 token = ERC20(_tokenContract);
       uint256 tokenBalance = token.balanceOf(address(this));
       token.transfer(owner, tokenBalance);
       emit WithdrewTokens(_tokenContract, msg.sender, tokenBalance);
    }

    // callable by owner only, after specified time, only for Tokens implementing ERC20
    function withdrawERC20Amount(address _tokenContract, uint256 _amount) onlyOwner public {
       require(block.timestamp >= unlockDate, "Funds cannot be withdrawn yet");
       ERC20 token = ERC20(_tokenContract);
       uint256 tokenBalance = token.balanceOf(address(this));
       require(tokenBalance >= _amount, "Not enough funds in the reserve");
       token.transfer(owner, _amount);
       emit WithdrewTokens(_tokenContract, msg.sender, _amount);
    }

    function info() public view returns(address, uint256, uint256) {
        return (owner, unlockDate, address(this).balance);
    }

    function infoERC20(address _tokenContract) public view returns(address, uint256, uint256) {
        ERC20 token = ERC20(_tokenContract);
        return (owner, unlockDate, token.balanceOf(address(this)));
    }

    event Received(address from, uint256 amount);
    event Withdrew(address to, uint256 amount);
    event WithdrewTokens(address tokenContract, address to, uint256 amount);

}