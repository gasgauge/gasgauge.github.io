pragma solidity ^0.4.21;

import "./Ownable.sol";
import "./ERC20.sol";

contract MainframeTokenDistribution is Ownable {

  uint public totalDistributed;
  ERC20 mainframeToken;

  event TokensDistributed(address receiver, uint amount);

  constructor(address tokenAddress) public {
    mainframeToken = ERC20(tokenAddress);
  }

  function distributeTokens(address tokenOwner, address[] recipients, uint[] values) onlyOwner external {
    require(recipients.length == values.length);
    for(uint i = 0; i < recipients.length; i++) {
      if(values[i] > 0) {
        require(mainframeToken.transferFrom(tokenOwner, recipients[i], values[i]));
        emit TokensDistributed(recipients[i], values[i]);
        totalDistributed += values[i];
      }
    }
  }

  function emergencyERC20Drain(ERC20 token) external onlyOwner {
    // owner can drain tokens that are sent here by mistake
    uint256 amount = token.balanceOf(this);
    token.transfer(owner, amount);
  }
}
