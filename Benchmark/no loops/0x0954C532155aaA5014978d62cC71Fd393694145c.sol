/**
 *Submitted for verification at Etherscan.io on 2020-12-23
*/

// SPDX-License-Identifier: MIT
//pragma solidity ^0.6.12;
pragma solidity >=0.5 <0.7.17;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + (((a % 2) + (b % 2)) / 2);
    }
}

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract HbtcStakingPool {
    using SafeMath for uint256;

    event Staked(address indexed staker, uint256 indexed amount, uint256 indexed timestamp);
    event Unstaked(address indexed staker, uint256 indexed amount, uint256 indexed timestamp);

    /* Pool Settings */
    address public poolToken;
    uint256 public startTime;
    uint256 public endTime;
    uint256 public maxStakeAmount;
    uint256 public totalRewardAmount;

    /* Live Pool Data */
    uint256 public totalStakeAmount;
    mapping(address => uint256) public stakeAmounts;
    mapping(address => uint256) public rewards;

    /* Reward Tracking Data */
    uint256 private outputPerSecond;
    uint256 private lastTokenRewardRate;
    uint256 private lastTokenRewardRateUpdateTime;
    mapping(address => uint256) private stakerEntryRewardRates;

    uint256 public constant TOKEN_REWARD_RATE_MULTIPLIER = 10**20; // Precision loss prevention

    bytes4 private constant TRANSFER_SELECTOR = bytes4(keccak256(bytes("transfer(address,uint256)")));
    bytes4 private constant TRANSFERFROM_SELECTOR = bytes4(keccak256(bytes("transferFrom(address,address,uint256)")));

    modifier onlyStarted() {
        require(block.timestamp >= startTime, "HbtcStakingPool: not started");
        _;
    }

    modifier onlyNotEnded() {
        require(block.timestamp < endTime, "HbtcStakingPool: already ended");
        _;
    }

    modifier updateTokenRewardRate() {
        uint256 appliedUpdateTime = Math.min(block.timestamp, endTime);
        uint256 durationInSeconds = appliedUpdateTime.sub(lastTokenRewardRateUpdateTime);

        // This saves tx cost when being called multiple times in the same block
        if (durationInSeconds > 0) {
            // No need to update the rate if no one staked at all
            if (totalStakeAmount > 0) {
                lastTokenRewardRate = lastTokenRewardRate.add(durationInSeconds.mul(outputPerSecond).div(totalStakeAmount));
            }
            lastTokenRewardRateUpdateTime = appliedUpdateTime;
        }
        _;
    }

    modifier updateStakerReward(address staker) {
        uint256 stakeAmount = stakeAmounts[staker];
        uint256 stakerEntryRate = stakerEntryRewardRates[staker];
        uint256 rateDifference = lastTokenRewardRate.sub(stakerEntryRate);

        if (rateDifference > 0) {
            rewards[staker] = rewards[staker].add(stakeAmount.mul(rateDifference).div(TOKEN_REWARD_RATE_MULTIPLIER));
            stakerEntryRewardRates[staker] = lastTokenRewardRate;
        }
        _;
    }

    function getReward(address staker) external view returns (uint256) {
        uint256 latestTokenRewardRate =
            totalStakeAmount > 0
                ? lastTokenRewardRate.add(
                    Math.min(block.timestamp, endTime).sub(lastTokenRewardRateUpdateTime).mul(outputPerSecond).div(
                        totalStakeAmount
                    )
                )
                : lastTokenRewardRate;

        return
            rewards[staker].add(
                stakeAmounts[staker].mul(latestTokenRewardRate.sub(stakerEntryRewardRates[staker])).div(
                    TOKEN_REWARD_RATE_MULTIPLIER
                )
            );
    }

    constructor(
        address _poolToken,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _maxStakeAmount,
        uint256 _totalRewardAmount
    ) public {
        require(_poolToken != address(0), "HbtcStakingPool: zero address");
        require(_startTime > block.timestamp && _endTime > _startTime, "HbtcStakingPool: invalid time range");
        require(_maxStakeAmount > 0, "HbtcStakingPool: max stake amount cannot be zero");
        require(_totalRewardAmount > 0, "HbtcStakingPool: total reward amount cannot be zero");

        poolToken = _poolToken;
        startTime = _startTime;
        endTime = _endTime;
        maxStakeAmount = _maxStakeAmount;
        totalRewardAmount = _totalRewardAmount;

        outputPerSecond = _totalRewardAmount
            .mul(TOKEN_REWARD_RATE_MULTIPLIER) // avoid precision loss
            .div(_endTime.sub(_startTime));
        lastTokenRewardRate = 0;
        lastTokenRewardRateUpdateTime = _startTime;
    }

    function stake(uint256 amount) external onlyStarted onlyNotEnded updateTokenRewardRate updateStakerReward(msg.sender) {
        doStake(amount);
    }

    function unstake(uint256 amount) external onlyStarted updateTokenRewardRate updateStakerReward(msg.sender) {
        doUnstake(amount);
    }

    function unstakeAll() external onlyStarted updateTokenRewardRate updateStakerReward(msg.sender) {
        doUnstake(stakeAmounts[msg.sender]);
    }

    function doStake(uint256 amount) private {
        require(amount > 0, "HbtcStakingPool: cannot stake zero amount");

        stakeAmounts[msg.sender] = stakeAmounts[msg.sender].add(amount);
        totalStakeAmount = totalStakeAmount.add(amount);

        require(totalStakeAmount <= maxStakeAmount, "HbtcStakingPool: maximum stake amount exceeded");

        safeTransferFrom(poolToken, msg.sender, address(this), amount);

        emit Staked(msg.sender, amount, block.timestamp);
    }

    function doUnstake(uint256 amount) private {
        require(amount > 0, "HbtcStakingPool: cannot unstake zero amount");

        // No sufficiency check required as sub() will throw anyways
        stakeAmounts[msg.sender] = stakeAmounts[msg.sender].sub(amount);
        totalStakeAmount = totalStakeAmount.sub(amount);

        safeTransfer(poolToken, msg.sender, amount);

        emit Unstaked(msg.sender, amount, block.timestamp);
    }

    function safeTransfer(
        address token,
        address recipient,
        uint256 amount
    ) private {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(TRANSFER_SELECTOR, recipient, amount));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "HbtcStakingPool: transfer failed");
    }

    function safeTransferFrom(
        address token,
        address sender,
        address recipient,
        uint256 amount
    ) private {
        (bool success, bytes memory data) =
            token.call(abi.encodeWithSelector(TRANSFERFROM_SELECTOR, sender, recipient, amount));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "HbtcStakingPool: transfer from failed");
    }
}
