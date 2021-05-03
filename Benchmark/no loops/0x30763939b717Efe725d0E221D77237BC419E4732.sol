/**
 *Submitted for verification at Etherscan.io on 2020-09-12
*/

/**
 *Submitted for verification at Etherscan.io on 2020-07-28
*/

pragma solidity >=0.5 <0.7.17;

library SafeMath {
  function mul(uint a, uint b) internal pure returns (uint) {
    if (a == 0) {
      return 0;
    }
    uint c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint a, uint b) internal pure returns (uint) {
    uint c = a / b;
    return c;
  }

  function sub(uint a, uint b) internal pure returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function add(uint a, uint b) internal pure returns (uint) {
    uint c = a + b;
    assert(c >= a);
    return c;
  }

  function ceil(uint a, uint m) internal pure returns (uint) {
    uint c = add(a,m);
    uint d = sub(c,1);
    return mul(div(d,m),m);
  }
}

 contract ERC20Token {
  function totalSupply()  public  returns (uint);
  function approve(address spender, uint value)  public  returns (bool);
  function balanceOf(address owner) public  returns (uint);
  function transferFrom (address from, address to, uint value) public  returns (bool);
}

//SPDX-License-Identifier: UNLICENSED

contract TokenLockerII  {
    
    using SafeMath for uint;
    
    uint ONE_DAY = 60*60*24;
   
    mapping(address => mapping(address => lockedTokenSlot)) public lockedTokensData; //address to timestamp to data

    struct lockedTokenSlot {
        address tokenAddress;
        uint unlockTime;
    }
    
    function()  external payable {
        revert();
    } 
    
    function lockToken(address tokenAddress, uint lockDays, uint lockQty) external {
        require(ERC20Token(tokenAddress).balanceOf(address(this)) == 0,"tokenAddressUsed");
        ERC20Token(tokenAddress).transferFrom(address(msg.sender), address(this), lockQty);
        uint finishTime = now + (lockDays*ONE_DAY);
        lockedTokensData[msg.sender][tokenAddress] = lockedTokenSlot(tokenAddress, finishTime);
    }
    
    function unlockToken(address tokenAddress, uint withdrawAmount) external {
        require(lockedTokensData[msg.sender][tokenAddress].unlockTime <= now, "timeNotElapsed");
        ERC20Token(lockedTokensData[msg.sender][tokenAddress].tokenAddress).approve(address(this),withdrawAmount);
        ERC20Token(lockedTokensData[msg.sender][tokenAddress].tokenAddress).transferFrom(address(this),address(msg.sender),withdrawAmount);        
    }

}