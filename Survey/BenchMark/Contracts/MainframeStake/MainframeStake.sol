pragma solidity ^0.4.21;

import "./SafeMath.sol";
import "./Ownable.sol";
import "./ERC20.sol";
import "./StakeInterface.sol";

contract MainframeStake is Ownable, StakeInterface {
  using SafeMath for uint256;

  ERC20 token;
  uint256 public arrayLimit = 200;
  uint256 public totalDepositBalance;
  uint256 public requiredStake;
  mapping (address => uint256) public balances;

  struct Staker {
    uint256 stakedAmount;
    address stakerAddress;
  }

  mapping (address => Staker) public whitelist; // map of whitelisted addresses for efficient hasStaked check

  constructor(address tokenAddress) public {
    token = ERC20(tokenAddress);
    requiredStake = 1 ether; // ether = 10^18
  }

  /**
  * @dev Staking MFT for a node address
  * @param whitelistAddress representing the address of the node you want to stake for
  */

  function stake(address whitelistAddress) external returns (bool success) {
    require(whitelist[whitelistAddress].stakerAddress == 0x0);

    whitelist[whitelistAddress].stakerAddress = msg.sender;
    whitelist[whitelistAddress].stakedAmount = requiredStake;

    deposit(msg.sender, requiredStake);
    emit Staked(msg.sender, whitelistAddress);
    return true;
  }

  /**
  * @dev Unstake a staked node address, will remove from whitelist and refund stake
  * @param whitelistAddress representing the staked node address
  */

  function unstake(address whitelistAddress) external {
    require(whitelist[whitelistAddress].stakerAddress == msg.sender);

    uint256 stakedAmount = whitelist[whitelistAddress].stakedAmount;
    delete whitelist[whitelistAddress];

    withdraw(msg.sender, stakedAmount);
    emit Unstaked(msg.sender, whitelistAddress);
  }

  /**
  * @dev Deposit stake amount
  * @param fromAddress representing the address to deposit from
  * @param depositAmount representing amount being deposited
  */

  function deposit(address fromAddress, uint256 depositAmount) private returns (bool success) {
    token.transferFrom(fromAddress, this, depositAmount);
    balances[fromAddress] = balances[fromAddress].add(depositAmount);
    totalDepositBalance = totalDepositBalance.add(depositAmount);
    emit Deposit(fromAddress, depositAmount, balances[fromAddress]);
    return true;
  }

  /**
  * @dev Withdraw funds after unstaking
  * @param toAddress representing the stakers address to withdraw to
  * @param withdrawAmount representing stake amount being withdrawn
  */

  function withdraw(address toAddress, uint256 withdrawAmount) private returns (bool success) {
    require(balances[toAddress] >= withdrawAmount);
    token.transfer(toAddress, withdrawAmount);
    balances[toAddress] = balances[toAddress].sub(withdrawAmount);
    totalDepositBalance = totalDepositBalance.sub(withdrawAmount);
    emit Withdrawal(toAddress, withdrawAmount, balances[toAddress]);
    return true;
  }

  function balanceOf(address _address) external view returns (uint256 balance) {
    return balances[_address];
  }

  function totalStaked() external view returns (uint256) {
    return totalDepositBalance;
  }

  function hasStake(address _address) external view returns (bool) {
    return whitelist[_address].stakedAmount > 0;
  }

  function requiredStake() external view returns (uint256) {
    return requiredStake;
  }

  function setRequiredStake(uint256 value) external onlyOwner {
    requiredStake = value;
  }

  function setArrayLimit(uint256 newLimit) external onlyOwner {
    arrayLimit = newLimit;
  }

  function refundBalances(address[] addresses) external onlyOwner {
    require(addresses.length <= arrayLimit);
    for (uint256 i = 0; i < addresses.length; i++) {
      address _address = addresses[i];
      require(balances[_address] > 0);
      token.transfer(_address, balances[_address]);
      totalDepositBalance = totalDepositBalance.sub(balances[_address]);
      emit RefundedBalance(_address, balances[_address]);
      balances[_address] = 0;
    }
  }

  function emergencyERC20Drain(ERC20 _token) external onlyOwner {
    // owner can drain tokens that are sent here by mistake
    uint256 drainAmount;
    if (address(_token) == address(token)) {
      drainAmount = _token.balanceOf(this).sub(totalDepositBalance);
    } else {
      drainAmount = _token.balanceOf(this);
    }
    _token.transfer(owner, drainAmount);
  }

  function destroy() external onlyOwner {
    require(token.balanceOf(this) == 0);
    selfdestruct(owner);
  }

  event Staked(address indexed owner, address whitelistAddress);
  event Unstaked(address indexed owner, address whitelistAddress);
  event Deposit(address indexed _address, uint256 depositAmount, uint256 balance);
  event Withdrawal(address indexed _address, uint256 withdrawAmount, uint256 balance);
  event RefundedBalance(address indexed _address, uint256 refundAmount);
}
