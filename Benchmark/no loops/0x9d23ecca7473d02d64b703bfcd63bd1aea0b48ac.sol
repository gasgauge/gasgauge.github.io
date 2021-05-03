/**
 *Submitted for verification at Etherscan.io on 2020-12-15
*/

//pragma solidity ^0.6.12;
pragma solidity >=0.5 <0.7.17;

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
     * - Subtraction cannot overflow.
     *
     * _Available since v2.4.0._
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
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
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
 contract Context {
    function _msgSender() internal view  returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view  returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public  onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public  onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IUniswapV2Router02 {
    function WETH() external pure returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

interface IUniswapV2Pair {
    function sync() external;
}

interface IKeep3rV1 {
    function isKeeper(address) external returns (bool);
    function worked(address keeper) external;
}

contract NodeRunnersLiquidity is Ownable {
    using SafeMath for uint256;

    uint256 public _liquidityRewardsDivisor;

    address payable public _treasury;
    address public _token;
    address public _uniswapV2Pair;
    address public _uniswapV2Router = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    IKeep3rV1 public constant KP3R = IKeep3rV1(0x1cEB5cB57C4D4E2b2433641b95Dd330A33185A44);

    event LockLiquidity(uint256 tokenAmount, uint256 ethAmount);
    event BurnLiquidity(uint256 lpTokenAmount);
    event RewardLiquidityProviders(uint256 tokenAmount);

    constructor (address token, address uniswapV2Pair) public {
        _token = token;
        _uniswapV2Pair = uniswapV2Pair;
    }

    function setTreasury(address payable treasury) onlyOwner external {
        _treasury = treasury;
    }

    function setLiquidityRewardsDivisor(uint256 liquidityRewardsDivisor) onlyOwner external {
        _liquidityRewardsDivisor = liquidityRewardsDivisor;
    }

    function lockLiquidity(uint256 _lockableSupply) public {
        // lockable supply is the token balance of this contract
        require(_lockableSupply <= IERC20(_token).balanceOf(address(this)), "NodeRunnersSave::lockLiquidity: lock amount higher than lockable balance");
        require(_lockableSupply != 0, "NodeRunnersSave::lockLiquidity: lock amount cannot be 0");

        // reward liquidity providers if needed
        if (_liquidityRewardsDivisor != 0) {
            // if no balance left to lock, don't lock
            if (_liquidityRewardsDivisor == 1) {
                rewardLiquidityProviders(_lockableSupply);
                return;
            }

            uint256 liquidityRewards = _lockableSupply.div(_liquidityRewardsDivisor);
            _lockableSupply = _lockableSupply.sub(liquidityRewards);
            rewardLiquidityProviders(liquidityRewards);
        }

        uint256 amountToSwapForEth = _lockableSupply.div(2);
        uint256 amountToAddLiquidity = _lockableSupply.sub(amountToSwapForEth);

        // needed in case contract already owns eth
        uint256 ethBalanceBeforeSwap = address(this).balance;
        swapTokensForEth(amountToSwapForEth);
        uint256 ethReceived = address(this).balance.sub(ethBalanceBeforeSwap);

        addLiquidity(amountToAddLiquidity, ethReceived);
        emit LockLiquidity(amountToAddLiquidity, ethReceived);
    }

    // external util so anyone can easily distribute rewards
    // must call lockLiquidity first which automatically
    // calls _rewardLiquidityProviders
    function rewardLiquidityProviders() external {
        // lock everything that is lockable
        require(KP3R.isKeeper(msg.sender), "Keep3rJob::update: not a valid keeper");
        lockLiquidity(IERC20(_token).balanceOf(address(this)));
        KP3R.worked(msg.sender);
    }

    function burnLiquidity() external {
        uint256 balance = IERC20(_uniswapV2Pair).balanceOf(address(this));
        require(balance != 0, "NodeRunnersSave::burnLiquidity: burn amount cannot be 0");
        IERC20(_uniswapV2Pair).transfer(address(0), balance);
        emit BurnLiquidity(balance);
    }

    // returns token amount
    function lockableSupply() external view returns (uint256) {
        return IERC20(_token).balanceOf(address(this));
    }

    // returns token amount
    function lockedSupply() external view returns (uint256) {
        uint256 lpTotalSupply = IERC20(_uniswapV2Pair).totalSupply();
        uint256 lpBalance = lockedLiquidity();
        uint256 percentOfLpTotalSupply = lpBalance.mul(1e12).div(lpTotalSupply);

        uint256 uniswapBalance = IERC20(_token).balanceOf(_uniswapV2Pair);
        uint256 _lockedSupply = uniswapBalance.mul(percentOfLpTotalSupply).div(1e12);
        return _lockedSupply;
    }

    // returns token amount
    function burnedSupply() external view returns (uint256) {
        uint256 lpTotalSupply = IERC20(_uniswapV2Pair).totalSupply();
        uint256 lpBalance = burnedLiquidity();
        uint256 percentOfLpTotalSupply = lpBalance.mul(1e12).div(lpTotalSupply);

        uint256 uniswapBalance = IERC20(_token).balanceOf(_uniswapV2Pair);
        uint256 _burnedSupply = uniswapBalance.mul(percentOfLpTotalSupply).div(1e12);
        return _burnedSupply;
    }

    function burnableLiquidity() public view returns (uint256) {
        return IERC20(_uniswapV2Pair).balanceOf(address(this));
    }

    function burnedLiquidity() public view returns (uint256) {
        return IERC20(_uniswapV2Pair).balanceOf(address(0));
    }

    function lockedLiquidity() public view returns (uint256) {
        return burnableLiquidity().add(burnedLiquidity());
    }
    
    function withdrawDust(uint256 amount) external onlyOwner {
        _treasury.transfer(amount);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        address[] memory uniswapPairPath = new address[](2);
        uniswapPairPath[0] = _token;
        uniswapPairPath[1] = IUniswapV2Router02(_uniswapV2Router).WETH();

        IERC20(_token).approve(_uniswapV2Router, tokenAmount);
        IUniswapV2Router02(_uniswapV2Router)
            .swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount, 0, uniswapPairPath, address(this), block.timestamp);
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        IERC20(_token).approve(_uniswapV2Router, tokenAmount);
        IUniswapV2Router02(_uniswapV2Router)
            .addLiquidityETH.value(ethAmount)(_token, tokenAmount, 0, 0, address(this), block.timestamp);
    }

    function rewardLiquidityProviders(uint256 liquidityRewards) private {
        // avoid burn by calling super._transfer directly
        IERC20(_token).transfer(_uniswapV2Pair, liquidityRewards);
        IUniswapV2Pair(_uniswapV2Pair).sync();
        emit RewardLiquidityProviders(liquidityRewards);
    }

    // receive eth from uniswap swap
    function receive() external payable { }
}
