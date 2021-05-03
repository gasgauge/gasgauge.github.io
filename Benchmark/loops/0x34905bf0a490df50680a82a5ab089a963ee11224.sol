/**

 *Submitted for verification at Etherscan.io on 2020-08-18

*/



//pragma solidity 0.5.17;
pragma solidity >=0.5 <0.7.17;


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

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */

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

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following 
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    /**
     * @dev Converts an `address` into `address payable`. Note that this is
     * simply a type cast: the actual underlying value is not changed.
     *
     * _Available since v2.4.0._
     */
    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     *
     * _Available since v2.4.0._
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-call-value
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves.

        // A Solidity high level call has three parts:
        //  1. The target address is checked to verify it contains contract code
        //  2. The call itself is made, and success asserted
        //  3. The return value is decoded, which in turn checks the size of the returned data.
        // solhint-disable-next-line max-line-length
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

interface IOracle {
    function getPriceFeed() external view returns(uint[] memory);
}

interface IStakeLPToken {
    function notify(uint _deficit) external;
    function totalSupply() external view returns(uint);
}

contract IPeak {
    function updateFeed(uint[] calldata _prices) external;
    function portfolioValue() public view returns(uint);
}

interface IDUSD {
    function mint(address account, uint amount) external;
    function burn(address account, uint amount) external;
    function totalSupply() external view returns(uint);
    function burnForSelf(uint amount) external;
}

interface ICore {
    function mint(uint dusdAmount, address account) external returns(uint usd);
    function redeem(uint dusdAmount, address account) external returns(uint usd);
    function rewardDistributionCheckpoint(bool shouldDistribute) external returns(uint periodIncome);

    function lastPeriodIncome() external view returns(uint _totalAssets, uint _periodIncome, uint _adminFee);
    function usdToDusd(uint usd) external view returns(uint);
    function dusdToUsd(uint _dusd, bool fee) external view returns(uint usd);
}

contract Initializable {
    bool initialized = false;

    modifier notInitialized() {
        require(!initialized, "already initialized");
        initialized = true;
        _;
    }

    // Reserved storage space to allow for layout changes in the future.
    uint256[50] private _gap;
}

contract Ownable {
    bytes32 constant OWNER_SLOT = keccak256("proxy.owner");

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() internal {
        _transferOwnership(msg.sender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns(address _owner) {
        bytes32 position = OWNER_SLOT;
        assembly {
            _owner := sload(position)
        }
    }

    modifier onlyOwner() {
        require(isOwner(), "NOT_OWNER");
        _;
    }

    function isOwner() public view returns (bool) {
        return owner() == msg.sender;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(owner(), newOwner);
        bytes32 position = OWNER_SLOT;
        assembly {
            sstore(position, newOwner)
        }
    }
}

contract Core is Ownable, Initializable, ICore {
    using SafeERC20 for IERC20;
    using SafeMath for uint;

    uint constant FEE_PRECISION = 10000;

    IDUSD public dusd;
    IStakeLPToken public stakeLPToken;
    IOracle public oracle;
    address[] public systemCoins;

    uint public totalAssets;
    uint public unclaimedRewards;
    bool public inDeficit;
    uint public redeemFactor;
    uint public adminFee;

    // Interface contracts for third-party protocol integrations
    enum PeakState { Extinct, Active, Dormant }
    struct Peak {
        uint[] systemCoinIds; // system indices of the coins accepted by the peak
        PeakState state;
    }
    mapping(address => Peak) peaks;
    address[] public peaksAddresses;

    // END OF STORAGE VARIABLES

    event Mint(address indexed account, uint amount);
    event Redeem(address indexed account, uint amount);
    event FeedUpdated(uint[] feed);
    event TokenWhiteListed(address indexed token);
    event PeakWhitelisted(address indexed peak);
    event UpdateDeficitState(bool inDeficit);

    modifier checkAndNotifyDeficit() {
        _;
        uint supply = dusd.totalSupply();
        if (supply > totalAssets) {
            if (!inDeficit) {
                emit UpdateDeficitState(true);
                inDeficit = true;
            }
            stakeLPToken.notify(supply.sub(totalAssets));
        } else if (inDeficit) {
            inDeficit = false;
            emit UpdateDeficitState(false);
            stakeLPToken.notify(0);
        }
    }

    modifier onlyStakeLPToken() {
        require(
            msg.sender == address(stakeLPToken),
            "Only stakeLPToken"
        );
        _;
    }

    /**
    * @dev Used to initialize contract state from the proxy
    */
    function initialize(
        IDUSD _dusd,
        IStakeLPToken _stakeLPToken,
        IOracle _oracle,
        uint _redeemFactor,
        uint _adminFee
    )   public
        notInitialized
    {
        require(
            address(_dusd) != address(0) &&
            address(_stakeLPToken) != address(0) &&
            address(_oracle) != address(0),
            "0 address during initialization"
        );
        dusd = _dusd;
        stakeLPToken = _stakeLPToken;
        oracle = _oracle;
        require(
            _redeemFactor <= FEE_PRECISION && _adminFee <= FEE_PRECISION,
            "Incorrect upper bound for fee"
        );
        redeemFactor = _redeemFactor;
        adminFee = _adminFee;
    }

    /**
    * @notice Mint DUSD
    * @dev Only whitelisted peaks can call this function
    * @param dusdAmount DUSD amount to mint
    * @param account Account to mint DUSD to
    * @return dusdAmount DUSD amount minted
    */
    function mint(uint usdDelta, address account)
        external
        checkAndNotifyDeficit
        returns(uint dusdAmount)
    {
        require(usdDelta > 0, "Minting 0");
        Peak memory peak = peaks[msg.sender];
        require(
            peak.state == PeakState.Active,
            "Peak is inactive"
        );
        dusdAmount = usdToDusd(usdDelta);
        dusd.mint(account, dusdAmount);
        totalAssets = totalAssets.add(usdDelta);
        emit Mint(account, dusdAmount);
    }

    /**
    * @notice Redeem DUSD
    * @dev Only whitelisted peaks can call this function
    * @param dusdAmount DUSD amount to redeem.
    * @param account Account to burn DUSD from
    */
    function redeem(uint dusdAmount, address account)
        external
        checkAndNotifyDeficit
        returns(uint usd)
    {
        require(dusdAmount > 0, "Redeeming 0");
        Peak memory peak = peaks[msg.sender];
        require(
            peak.state != PeakState.Extinct,
            "Peak is extinct"
        );
        usd = dusdToUsd(dusdAmount, true);
        dusd.burn(account, dusdAmount);
        totalAssets = totalAssets.sub(usd);
        emit Redeem(account, dusdAmount);
    }

    /**
    * @notice Pull prices from the oracle and update system stats
    * @dev Anyone can call this
    */
    function syncSystem()
        external
        checkAndNotifyDeficit
    {
        _updateFeed();
        totalAssets = totalSystemAssets();
    }

    function rewardDistributionCheckpoint(bool shouldDistribute)
        external
        onlyStakeLPToken
        checkAndNotifyDeficit
        returns(uint periodIncome)
    {
        uint _adminFee;
        (totalAssets, periodIncome, _adminFee) = lastPeriodIncome();
        if (periodIncome == 0) {
            return 0;
        }
        // note that we do not account for devalued dusd here
        if (shouldDistribute) {
            dusd.mint(address(stakeLPToken), periodIncome);
            if (_adminFee > 0) {
                dusd.mint(address(this), _adminFee);
            }
        } else {
            // stakers don't get these, will act as extra volatility cushion
            unclaimedRewards = unclaimedRewards.add(periodIncome).add(_adminFee);
        }
    }

    /* ##### View functions ##### */

    function lastPeriodIncome()
        public
        view
        returns(uint _totalAssets, uint periodIncome, uint _adminFee)
    {
        _totalAssets = totalSystemAssets();
        uint supply = dusd.totalSupply().add(unclaimedRewards);
        if (_totalAssets > supply) {
            periodIncome = _totalAssets.sub(supply);
            if (adminFee > 0) {
                _adminFee = periodIncome.mul(adminFee).div(FEE_PRECISION);
                periodIncome = periodIncome.sub(_adminFee);
            }
        }
    }

    /**
    * @notice Returns the net system assets across all peaks
    * @return _totalAssets system assets denominated in dollars
    */
    function totalSystemAssets()
        public
        view
        returns (uint _totalAssets)
    {
        for (uint i = 0; i < peaksAddresses.length; i++) {
            Peak memory peak = peaks[peaksAddresses[i]];
            if (peak.state == PeakState.Extinct) {
                continue;
            }
            _totalAssets = _totalAssets.add(IPeak(peaksAddresses[i]).portfolioValue());
        }
    }

    function usdToDusd(uint usd)
        public
        view
        returns(uint)
    {
        // system is healthy. Pegged at $1
        if (!inDeficit) {
            return usd;
        }
        // system is in deficit, see if staked funds can make up for it
        uint supply = dusd.totalSupply();
        uint perceivedSupply = supply.sub(stakeLPToken.totalSupply());
        // staked funds make up for the deficit
        if (perceivedSupply <= totalAssets) {
            return usd;
        }
        return usd.mul(perceivedSupply).div(totalAssets);
    }

    function dusdToUsd(uint _dusd, bool fee)
        public
        view
        returns(uint usd)
    {
        // system is healthy. Pegged at $1
        if (!inDeficit) {
            usd = _dusd;
        } else {
        // system is in deficit, see if staked funds can make up for it
            uint supply = dusd.totalSupply();
            // do not perform a dusd.balanceOf(stakeLPToken) because that includes the reward tokens
            uint perceivedSupply = supply.sub(stakeLPToken.totalSupply());
            // staked funds make up for the deficit
            if (perceivedSupply <= totalAssets) {
                usd = _dusd;
            } else {
                usd = _dusd.mul(totalAssets).div(perceivedSupply);
            }
        }
        if (fee) {
            usd = usd.mul(redeemFactor).div(FEE_PRECISION);
        }
        return usd;
    }

    /* ##### Admin functions ##### */

    /**
    * @notice Whitelist new tokens supported by the peaks.
    * These are vanilla coins like DAI, USDC, USDT etc.
    * @dev onlyOwner ACL is provided by the whitelistToken call
    * @param tokens Token addresses to whitelist
    */
    function whitelistTokens(address[] calldata tokens)
        external
        onlyOwner
    {
        for (uint i = 0; i < tokens.length; i++) {
            _whitelistToken(tokens[i]);
        }
    }

    /**
    * @notice Whitelist a new peak
    * @param peak Address of the contract that interfaces with the 3rd-party protocol
    * @param _systemCoins Indices of the system coins, the peak supports
    */
    function whitelistPeak(
        address peak,
        uint[] calldata _systemCoins,
        bool shouldUpdateFeed
    )   external
        onlyOwner
    {
        uint numSystemCoins = systemCoins.length;
        for (uint i = 0; i < _systemCoins.length; i++) {
            require(_systemCoins[i] < numSystemCoins, "Invalid system coin index");
        }
        require(
            peaks[peak].state == PeakState.Extinct,
            "Peak already exists"
        );
        peaksAddresses.push(peak);
        peaks[peak] = Peak(_systemCoins, PeakState.Active);
        if (shouldUpdateFeed) {
            _updateFeed();
        }
        emit PeakWhitelisted(peak);
    }

    /**
    * @notice Change a peaks status
    */
    function setPeakStatus(address peak, PeakState state)
        external
        onlyOwner
    {
        require(
            peaks[peak].state != PeakState.Extinct,
            "Peak is extinct"
        );
        peaks[peak].state = state;
    }

    function setFee(uint _redeemFactor, uint _adminFee)
        external
        onlyOwner
    {
        require(
            _redeemFactor <= FEE_PRECISION && _adminFee <= FEE_PRECISION,
            "Incorrect upper bound for fee"
        );
        redeemFactor = _redeemFactor;
        adminFee = _adminFee;
    }

    function withdrawAdminFee(address destination)
        external
        onlyOwner
    {
        IERC20 _dusd = IERC20(address(dusd));
        _dusd.safeTransfer(destination, _dusd.balanceOf(address(this)));
    }

    /* ##### Internal functions ##### */

    function _updateFeed()
        internal
    {
        uint[] memory feed = oracle.getPriceFeed();
        require(feed.length == systemCoins.length, "Invalid system state");
        uint[] memory prices;
        Peak memory peak;
        for (uint i = 0; i < peaksAddresses.length; i++) {
            peak = peaks[peaksAddresses[i]];
            prices = new uint[](peak.systemCoinIds.length);
            if (peak.state == PeakState.Extinct) {
                continue;
            }
            for (uint j = 0; j < prices.length; j++) {
                prices[j] = feed[peak.systemCoinIds[j]];
            }
            IPeak(peaksAddresses[i]).updateFeed(prices);
        }
        emit FeedUpdated(feed);
    }

    function _whitelistToken(address token)
        internal
    {
        for (uint i = 0; i < systemCoins.length; i++) {
            require(systemCoins[i] != token, "Adding a duplicate token");
        }
        systemCoins.push(token);
        emit TokenWhiteListed(token);
    }
}
