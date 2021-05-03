/**
 *Submitted for verification at Etherscan.io on 2020-12-30
*/

//pragma solidity 0.6.10;
pragma solidity >=0.5 <0.7.17;

library SafeMath {
  /**
  * @dev Multiplies two unsigned integers, reverts on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
        return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

  /**
  * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // Solidity only automatically asserts when dividing by 0
    require(b > 0);
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
  * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  /**
  * @dev Adds two unsigned integers, reverts on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  /**
  * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
  * reverts when dividing by zero.
  */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

interface ERC20 {
  function symbol() external view returns (string memory);
  function balanceOf(address who) external view returns (uint256);
  function transferFrom(address from, address to, uint value) external returns (bool success);
}

contract Airdrop {
  using SafeMath for uint256;

  address public owner;

  constructor () public {
    owner = msg.sender; 
  }

  function getSymbol(address token) public view returns(string memory) {
    return ERC20(token).symbol();
  }

  function getBalance(address token, address user) public view returns(uint256) {
    return ERC20(token).balanceOf(user);
  }

  function multiTransfer(address token, address[] memory receivers, uint256[] memory amounts) public {
    for (uint256 i = 0; i < receivers.length; i++)
      ERC20(token).transferFrom(msg.sender, receivers[i], amounts[i]);
  }
}
