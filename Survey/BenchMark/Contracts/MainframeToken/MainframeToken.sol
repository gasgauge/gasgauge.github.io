pragma solidity ^0.4.21;

import "./StandardToken.sol";
import "./Pausable.sol";
import "./Claimable.sol";

contract MainframeToken is StandardToken, Pausable, Claimable {
  string public constant name = "Mainframe Token";
  string public constant symbol = "MFT";
  uint8  public constant decimals = 18;
  address public distributor;

  modifier validDestination(address to) {
    require(to != address(this));
    _;
  }

  modifier isTradeable() {
    require(
      !paused ||
      msg.sender == owner ||
      msg.sender == distributor
    );
    _;
  }

  constructor() public {
    totalSupply_ = 10000000000 ether; // 10 billion, 18 decimals (ether = 10^18)
    balances[msg.sender] = totalSupply_;
    emit Transfer(address(0x0), msg.sender, totalSupply_);
  }

  // ERC20 Methods

  function transfer(address to, uint256 value) public validDestination(to) isTradeable returns (bool) {
    return super.transfer(to, value);
  }

  function transferFrom(address from, address to, uint256 value) public validDestination(to) isTradeable returns (bool) {
    return super.transferFrom(from, to, value);
  }

  function approve(address spender, uint256 value) public isTradeable returns (bool) {
    return super.approve(spender, value);
  }

  function increaseApproval(address spender, uint addedValue) public isTradeable returns (bool) {
    return super.increaseApproval(spender, addedValue);
  }

  function decreaseApproval(address spender, uint subtractedValue) public isTradeable returns (bool) {
    return super.decreaseApproval(spender, subtractedValue);
  }

  // Setters

  function setDistributor(address newDistributor) external onlyOwner {
    distributor = newDistributor;
  }

  // Token Drain

  function emergencyERC20Drain(ERC20 token, uint256 amount) external onlyOwner {
    // owner can drain tokens that are sent here by mistake
    token.transfer(owner, amount);
  }
}
