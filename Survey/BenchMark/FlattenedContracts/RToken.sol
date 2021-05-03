
// File: contracts\Proxiable.sol

pragma solidity ^0.5.0;

contract Proxiable {
    // Code position in storage is keccak256("PROXIABLE") = "0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7"

    function updateCodeAddress(address newAddress) internal {
        require(
            bytes32(
                    0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7
                ) ==
                Proxiable(newAddress).proxiableUUID(),
            "Not compatible"
        );
        assembly {
            // solium-disable-line
            sstore(
                0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7,
                newAddress
            )
        }
    }
    function proxiableUUID() public pure returns (bytes32) {
        return
            0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7;
    }
}

// File: contracts\RTokenStructs.sol

pragma solidity >=0.5.10 <0.6.0;

contract RTokenStructs {
    /**
     * @notice Global stats
     */
    struct GlobalStats {
        /// @notice Total redeemable tokens supply
        uint256 totalSupply;
        /// @notice Total saving assets in redeemable amount
        uint256 totalSavingsAmount;
    }


    /**
     * @notice Account stats stored
     */
    struct AccountStatsView {
        /// @notice Current hat ID
        uint256 hatID;
        /// @notice Current redeemable amount
        uint256 rAmount;
        /// @notice Interest portion of the rAmount
        uint256 rInterest;
        /// @notice Current loan debt amount
        uint256 lDebt;
        /// @notice Current internal savings amount
        uint256 sInternalAmount;
        /// @notice Interest payable
        uint256 rInterestPayable;
        /// @notice Cumulative interest generated for the account
        uint256 cumulativeInterest;
    }

    /**
     * @notice Account stats stored
     */
    struct AccountStatsStored {
        /// @notice Cumulative interest generated for the account
        uint256 cumulativeInterest;
    }

    /**
     * @notice Hat stats view
     */
    struct HatStatsView {
        /// @notice Number of addresses has the hat
        uint256 useCount;
        /// @notice Total net loans distributed through the hat
        uint256 totalLoans;
        /// @notice Total net savings distributed through the hat
        uint256 totalSavings;
    }

    /**
     * @notice Hat stats stored
     */
    struct HatStatsStored {
        /// @notice Number of addresses has the hat
        uint256 useCount;
        /// @notice Total net loans distributed through the hat
        uint256 totalLoans;
        /// @notice Total net savings distributed through the hat
        uint256 totalInternalSavings;
    }

    /**
     * @notice Hat structure describes who are the recipients of the interest
     *
     * To be a valid hat structure:
     *   - at least one recipient
     *   - recipients.length == proportions.length
     *   - each value in proportions should be greater than 0
     */
    struct Hat {
        address[] recipients;
        uint32[] proportions;
    }

    /// @dev Account structure
    struct Account {
        uint256 hatID;
        uint256 rAmount;
        uint256 rInterest;
        mapping(address => uint256) lRecipients;
        uint256 lDebt;
        uint256 sInternalAmount;
    }
}

// File: contracts\IERC20.sol

pragma solidity ^0.5.0;

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

// File: contracts\IRToken.sol

/**
 * Because the use of ABIEncoderV2 , the pragma should be locked above 0.5.10 ,
 * as there is a known bug in array storage:
 * https://blog.ethereum.org/2019/06/25/solidity-storage-array-bugs/
 */
pragma solidity >=0.5.10 <0.6.0;
pragma experimental ABIEncoderV2;



/**
 * @notice RToken interface a ERC20 interface and one can mint new tokens by
 *      trasfering underlying token into the contract, configure _hats_ for
 *      addresses and pay earned interest in new _rTokens_.
 */
contract IRToken is RTokenStructs, IERC20 {
    ////////////////////////////////////////////////////////////////////////////
    // For external transactions
    ////////////////////////////////////////////////////////////////////////////
    /**
     * @notice Sender supplies assets into the market and receives rTokens in exchange
     * @param mintAmount The amount of the underlying asset to supply
     * @return bool true=success, otherwise a failure
     */
    function mint(uint256 mintAmount) external returns (bool);

    /**
     * @notice Sender supplies assets into the market and receives rTokens in exchange
     *         Also setting the a selected hat for the account.
     * @param hatID The id of the selected Hat
     * @return bool true=success, otherwise a failure
     */
    function mintWithSelectedHat(uint256 mintAmount, uint256 hatID)
        external
        returns (bool);

    /**
     * @notice Sender supplies assets into the market and receives rTokens in exchange
     *         Also setting the a new hat for the account.
     * @param mintAmount The amount of the underlying asset to supply
     * @param proportions Relative proportions of benefits received by the recipients
     * @return bool true=success, otherwise a failure
     */
    function mintWithNewHat(
        uint256 mintAmount,
        address[] calldata recipients,
        uint32[] calldata proportions
    ) external returns (bool);

    /**
     * @notice Moves all tokens from the caller's account to `dst`.
     * @param dst The destination address.
     * @return bool true=success, otherwise a failure
     */
    function transferAll(address dst) external returns (bool);

    /**
     * @notice Moves all tokens from `src` account to `dst`.
     * @param src The source address which approved the msg.sender to spend
     * @param dst The destination address.
     * @return bool true=success, otherwise a failure
     */
    function transferAllFrom(address src, address dst) external returns (bool);

    /**
     * @notice Sender redeems rTokens in exchange for the underlying asset
     * @param redeemTokens The number of rTokens to redeem into underlying
     * @return bool true=success, otherwise a failure
     */
    function redeem(uint256 redeemTokens) external returns (bool);

    /**
     * @notice Sender redeems all rTokens in exchange for the underlying asset
     * @return bool true=success, otherwise a failure
     */
    function redeemAll() external returns (bool);

    /**
     * @notice Sender redeems rTokens in exchange for the underlying asset then immediately transfer them to a differen user
     * @param redeemTo Destination address to send the redeemed tokens to
     * @param redeemTokens The number of rTokens to redeem into underlying
     * @return bool true=success, otherwise a failure
     */
    function redeemAndTransfer(address redeemTo, uint256 redeemTokens)
        external
        returns (bool);

    /**
     * @notice Sender redeems all rTokens in exchange for the underlying asset then immediately transfer them to a differen user
     * @param redeemTo Destination address to send the redeemed tokens to
     * @return bool true=success, otherwise a failure
     */
    function redeemAndTransferAll(address redeemTo) external returns (bool);

    /**
     * @notice Create a new Hat
     * @param recipients List of beneficial recipients
     * @param proportions Relative proportions of benefits received by the recipients
     * @param doChangeHat Should the hat of the `msg.sender` be switched to the new one
     * @return uint256 ID of the newly creatd Hat.
     */
    function createHat(
        address[] calldata recipients,
        uint32[] calldata proportions,
        bool doChangeHat
    ) external returns (uint256 hatID);

    /**
     * @notice Change the hat for `msg.sender`
     * @param hatID The id of the Hat
     * @return bool true=success, otherwise a failure
     */
    function changeHat(uint256 hatID) external returns (bool);

    /**
     * @notice pay interest to the owner
     * @param owner Account owner address
     * @return bool true=success, otherwise a failure
     *
     * Anyone can trigger the interest distribution on behalf of the recipient,
     * due to the fact that the recipient can be a contract code that has not
     * implemented the interaction with the rToken contract internally`.
     *
     * A interest lock-up period may apply, in order to mitigate the "hat
     * inheritance scam".
     */
    function payInterest(address owner) external returns (bool);

    ////////////////////////////////////////////////////////////////////////////
    // Essential info views
    ////////////////////////////////////////////////////////////////////////////
    /**
     * @notice Get the maximum hatID in the system
     */
    function getMaximumHatID() external view returns (uint256 hatID);

    /**
     * @notice Get the hatID of the owner and the hat structure
     * @param owner Account owner address
     * @return hatID Hat ID
     * @return recipients Hat recipients
     * @return proportions Hat recipient's relative proportions
     */
    function getHatByAddress(address owner)
        external
        view
        returns (
            uint256 hatID,
            address[] memory recipients,
            uint32[] memory proportions
        );

    /**
     * @notice Get the hat structure
     * @param hatID Hat ID
     * @return recipients Hat recipients
     * @return proportions Hat recipient's relative proportions
     */
    function getHatByID(uint256 hatID)
        external
        view
        returns (address[] memory recipients, uint32[] memory proportions);

    /**
     * @notice Amount of saving assets given to the recipient along with the
     *         loans.
     * @param owner Account owner address
     */
    function receivedSavingsOf(address owner)
        external
        view
        returns (uint256 amount);

    /**
     * @notice Amount of token loaned to the recipient along with the savings
     *         assets.
     * @param owner Account owner address
     * @return amount
     */
    function receivedLoanOf(address owner)
        external
        view
        returns (uint256 amount);

    /**
     * @notice Get the current interest balance of the owner.
               It is equivalent of: receivedSavings - receivedLoan - freeBalance
     * @param owner Account owner address
     * @return amount
     */
    function interestPayableOf(address owner)
        external
        view
        returns (uint256 amount);

    ////////////////////////////////////////////////////////////////////////////
    // statistics views
    ////////////////////////////////////////////////////////////////////////////
    /**
     * @notice Get the current saving strategy contract
     * @return Saving strategy address
     */
    function getCurrentSavingStrategy() external view returns (address);

    /**
    * @notice Get saving asset balance for specific saving strategy
    * @return rAmount Balance in redeemable amount
    * @return sOriginalAmount Balance in native amount of the strategy
    */
    function getSavingAssetBalance()
        external
        view
        returns (uint256 rAmount, uint256 sOriginalAmount);

    /**
    * @notice Get global stats
    * @return global stats
    */
    function getGlobalStats() external view returns (GlobalStats memory);

    /**
    * @notice Get account stats
    * @param owner Account owner address
    * @return account stats
    */
    function getAccountStats(address owner)
        external
        view
        returns (AccountStatsView memory);

    /**
    * @notice Get hat stats
    * @param hatID Hat ID
    * @return hat stats
    */
    function getHatStats(uint256 hatID)
        external
        view
        returns (HatStatsView memory);

    ////////////////////////////////////////////////////////////////////////////
    // Events
    ////////////////////////////////////////////////////////////////////////////
    /**
     * @notice Event emitted when loans get transferred
     */
    event LoansTransferred(
        address indexed owner,
        address indexed recipient,
        uint256 indexed hatId,
        bool isDistribution,
        uint256 redeemableAmount,
        uint256 internalSavingsAmount);

    /**
     * @notice Event emitted when interest paid
     */
    event InterestPaid(address indexed recipient, uint256 amount);

    /**
     * @notice A new hat is created
     */
    event HatCreated(uint256 indexed hatID);

    /**
     * @notice Hat is changed for the account
     */
    event HatChanged(address indexed account, uint256 indexed oldHatID, uint256 indexed newHatID);
}

// File: contracts\IAllocationStrategy.sol

pragma solidity ^0.5.8;

/**
 * @notice Allocation strategy for assets.
 *         - It invests the underlying assets into some yield generating contracts,
 *           usually lending contracts, in return it gets new assets aka. saving assets.
 *         - Sainv assets can be redeemed back to the underlying assets plus interest any time.
 */
interface IAllocationStrategy {

    /**
     * @notice Underlying asset for the strategy
     * @return address Underlying asset address
     */
    function underlying() external view returns (address);

    /**
     * @notice Calculates the exchange rate from underlying to saving assets
     * @return uint256 Calculated exchange rate scaled by 1e18
     *
     * NOTE:
     *
     *   underlying = savingAssets × exchangeRate
     */
    function exchangeRateStored() external view returns (uint256);

    /**
      * @notice Applies accrued interest to all savings
      * @dev This should calculates interest accrued from the last checkpointed
      *      block up to the current block and writes new checkpoint to storage.
      * @return bool success(true) or failure(false)
      */
    function accrueInterest() external returns (bool);

    /**
     * @notice Sender supplies underlying assets into the market and receives saving assets in exchange
     * @dev Interst shall be accrued
     * @param investAmount The amount of the underlying asset to supply
     * @return uint256 Amount of saving assets created
     */
    function investUnderlying(uint256 investAmount) external returns (uint256);

    /**
     * @notice Sender redeems saving assets in exchange for a specified amount of underlying asset
     * @dev Interst shall be accrued
     * @param redeemAmount The amount of underlying to redeem
     * @return uint256 Amount of saving assets burned
     */
    function redeemUnderlying(uint256 redeemAmount) external returns (uint256);

}

// File: contracts\RTokenStorage.sol

/**
 * Because the use of ABIEncoderV2 , the pragma should be locked above 0.5.10 ,
 * as there is a known bug in array storage:
 * https://blog.ethereum.org/2019/06/25/solidity-storage-array-bugs/
 */
pragma solidity >=0.5.10 <0.6.0;
pragma experimental ABIEncoderV2;




contract RTokenStorage is RTokenStructs, IERC20 {
    /* WARNING: NEVER RE-ORDER VARIABLES! Always double-check that new variables are added APPEND-ONLY. Re-ordering variables can permanently BREAK the deployed proxy contract.*/
    address public _owner;
    bool public initialized;
    /// @dev counter to allow mutex lock with only one SSTORE operation
    uint256 public _guardCounter;
    /**
     * @notice EIP-20 token name for this token
     */
    string public name;
    /**
     * @notice EIP-20 token symbol for this token
     */
    string public symbol;
    /**
     * @notice EIP-20 token decimals for this token
     */
    uint256 public decimals;
    /**
     * @notice Total number of tokens in circulation
     */
    uint256 public totalSupply;
    /// @dev Current saving strategy
    IAllocationStrategy public ias;
    /// @dev Underlying token
    IERC20 public token;
    /// @dev Saving assets original amount
    /// This amount is in the same unit used in allocation strategy
    uint256 public savingAssetOrignalAmount;
    /// @dev Saving asset original to internal amount conversion rate.
    ///      - It has 18 decimals
    ///      - It starts with value 1.
    ///      - Each strategy switching results a new conversion rate
    ///
    /// NOTE:
    ///
    /// 1. The reason there is an exchange rate is that, each time the
    ///    allocation strategy is switched, the unit of the original amount gets
    ///    changed, it is impossible to change all the internal savings
    ///    accounting entries for all accounts, hence instead a conversaion rate
    ///    is used to simplify the process.
    /// 2. internalSavings == originalSavings * savingAssetConversionRate
    uint256 public savingAssetConversionRate;
    /// @dev Approved token transfer amounts on behalf of others
    mapping(address => mapping(address => uint256)) public transferAllowances;
    /// @dev Hat list
    Hat[] internal hats;
    /// @dev Account mapping
    mapping(address => Account) public accounts;
    /// @dev AccountStats mapping
    mapping(address => AccountStatsStored) public accountStats;
    /// @dev HatStats mapping
    mapping(uint256 => HatStatsStored) public hatStats;
}

// File: contracts\Ownable.sol

pragma solidity ^0.5.0;


contract Ownable is RTokenStorage {
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
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
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * > Note: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: contracts\LibraryLock.sol

pragma solidity ^0.5.0;


contract LibraryLock is RTokenStorage {
    // Ensures no one can manipulate the Logic Contract once it is deployed.
    // PARITY WALLET HACK PREVENTION

    modifier delegatedOnly() {
        require(
            initialized == true,
            "The library is locked. No direct 'call' is allowed."
        );
        _;
    }
    function initialize() internal {
        initialized = true;
    }
}

// File: contracts\SafeMath.sol

pragma solidity ^0.5.0;

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

// File: contracts\ReentrancyGuard.sol

pragma solidity ^0.5.0;


contract ReentrancyGuard is RTokenStorage {
    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(
            localCounter == _guardCounter,
            "ReentrancyGuard: reentrant call"
        );
    }
}

// File: contracts\IRTokenAdmin.sol

/**
 * In order to build a Aragon App, it is required to have a solidity requirement
 * that is without ABIEncoderV2.
 */
pragma solidity >= 0.4.24;

/**
 * IRTokenAdmin interface
 */
interface IRTokenAdmin {

    /**
     * @notice Get current owner
     */
    function owner() external view returns (address);

    /**
     * @notice Transfers ownership of the contract to a new account (`newOwner`).
     *
     * To be implemented by Ownable
     */
    function transferOwnership(address newOwner) external;

    /**
    * @notice Get the current allocation strategy
    */
    function getCurrentAllocationStrategy()
        external view returns (address allocationStrategy);

    /**
    * @notice Change allocation strategy for the contract instance
    * @param allocationStrategy Allocation strategy instance
    */
    function changeAllocationStrategy(address allocationStrategy)
        external;

    /**
     * @notice Change hat for the contract address
     * @param contractAddress contract address
     * @param hatID Hat ID
     */
    function changeHatFor(address contractAddress, uint256 hatID)
        external;

    /**
     * @notice Update the rToken logic contract code
     */
    function updateCode(address newCode) external;

    /**
     * @notice Code updated event
     */
    event CodeUpdated(address newCode);

    /**
     * @notice Allocation strategy changed event
     * @param strategy New strategy address
     * @param conversionRate New saving asset conversion rate
     */
    event AllocationStrategyChanged(address strategy, uint256 conversionRate);
}

// File: contracts\RToken.sol

/**
 * Because the use of ABIEncoderV2 , the pragma should be locked above 0.5.10 ,
 * as there is a known bug in array storage:
 * https://blog.ethereum.org/2019/06/25/solidity-storage-array-bugs/
 */
pragma solidity  ^0.5.11;
pragma experimental ABIEncoderV2;











/**
 * @notice RToken an ERC20 token that is 1:1 redeemable to its underlying ERC20 token.
 */
contract RToken is
    RTokenStorage,
    IRToken,
    IRTokenAdmin,
    Ownable,
    Proxiable,
    LibraryLock,
    ReentrancyGuard {
    using SafeMath for uint256;


    uint256 public constant ALLOCATION_STRATEGY_EXCHANGE_RATE_SCALE = 1e18;
    uint256 public constant INITIAL_SAVING_ASSET_CONVERSION_RATE = 1e18;
    uint256 public constant MAX_UINT256 = uint256(int256(-1));
    uint256 public constant SELF_HAT_ID = MAX_UINT256;
    uint32 public constant PROPORTION_BASE = 0xFFFFFFFF;
    uint256 public constant MAX_NUM_HAT_RECIPIENTS = 50;

    /**
     * @notice Create rToken linked with cToken at `cToken_`
     */
    function initialize(
        IAllocationStrategy allocationStrategy,
        string calldata name_,
        string calldata symbol_,
        uint256 decimals_) external {
        require(!initialized, "The library has already been initialized.");
        LibraryLock.initialize();
        _owner = msg.sender;
        _guardCounter = 1;
        name = name_;
        symbol = symbol_;
        decimals = decimals_;
        savingAssetConversionRate = INITIAL_SAVING_ASSET_CONVERSION_RATE;
        ias = allocationStrategy;
        token = IERC20(ias.underlying());

        // special hat aka. zero hat : hatID = 0
        hats.push(Hat(new address[](0), new uint32[](0)));

        // everyone is using it by default!
        hatStats[0].useCount = MAX_UINT256;

        emit AllocationStrategyChanged(address(ias), savingAssetConversionRate);
    }

    //
    // ERC20 Interface
    //

    /**
     * @notice Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address owner) external view returns (uint256) {
        return accounts[owner].rAmount;
    }

    /**
     * @notice Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through `transferFrom`. This is
     * zero by default.
     *
     * This value changes when `approve` or `transferFrom` are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256)
    {
        return transferAllowances[owner][spender];
    }

    /**
     * @notice Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * > Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an `Approval` event.
     */
    function approve(address spender, uint256 amount) external returns (bool) {
        address src = msg.sender;
        transferAllowances[src][spender] = amount;
        emit Approval(src, spender, amount);
        return true;
    }

    /**
     * @notice Moves `amount` tokens from the caller's account to `dst`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a `Transfer` event.
     * May also emit `InterestPaid` event.
     */
    function transfer(address dst, uint256 amount)
        external
        nonReentrant
        returns (bool)
    {
        address src = msg.sender;
        payInterestInternal(src);
        transferInternal(src, src, dst, amount);
        payInterestInternal(dst);
        return true;
    }

    /// @dev IRToken.transferAll implementation
    function transferAll(address dst) external nonReentrant returns (bool) {
        address src = msg.sender;
        payInterestInternal(src);
        transferInternal(src, src, dst, accounts[src].rAmount);
        payInterestInternal(dst);
        return true;
    }

    /// @dev IRToken.transferAllFrom implementation
    function transferAllFrom(address src, address dst)
        external
        nonReentrant
        returns (bool)
    {
        payInterestInternal(src);
        transferInternal(msg.sender, src, dst, accounts[src].rAmount);
        payInterestInternal(dst);
        return true;
    }

    /**
     * @notice Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a `Transfer` event.
     */
    function transferFrom(address src, address dst, uint256 amount)
        external
        nonReentrant
        returns (bool)
    {
        payInterestInternal(src);
        transferInternal(msg.sender, src, dst, amount);
        payInterestInternal(dst);
        return true;
    }

    //
    // rToken interface
    //

    /// @dev IRToken.mint implementation
    function mint(uint256 mintAmount) external nonReentrant returns (bool) {
        mintInternal(mintAmount);
        payInterestInternal(msg.sender);
        return true;
    }

    /// @dev IRToken.mintWithSelectedHat implementation
    function mintWithSelectedHat(uint256 mintAmount, uint256 hatID)
        external
        nonReentrant
        returns (bool)
    {
        changeHatInternal(msg.sender, hatID);
        mintInternal(mintAmount);
        payInterestInternal(msg.sender);
        return true;
    }

    /**
     * @dev IRToken.mintWithNewHat implementation
     */
    function mintWithNewHat(
        uint256 mintAmount,
        address[] calldata recipients,
        uint32[] calldata proportions
    ) external nonReentrant returns (bool) {
        uint256 hatID = createHatInternal(recipients, proportions);
        changeHatInternal(msg.sender, hatID);
        mintInternal(mintAmount);
        payInterestInternal(msg.sender);
        return true;
    }

    /**
     * @dev IRToken.redeem implementation
     *      It withdraws equal amount of initially supplied underlying assets
     */
    function redeem(uint256 redeemTokens) external nonReentrant returns (bool) {
        address src = msg.sender;
        payInterestInternal(src);
        redeemInternal(src, redeemTokens);
        return true;
    }

    /// @dev IRToken.redeemAll implementation
    function redeemAll() external nonReentrant returns (bool) {
        address src = msg.sender;
        payInterestInternal(src);
        redeemInternal(src, accounts[src].rAmount);
        return true;
    }

    /// @dev IRToken.redeemAndTransfer implementation
    function redeemAndTransfer(address redeemTo, uint256 redeemTokens)
        external
        nonReentrant
        returns (bool)
    {
        address src = msg.sender;
        payInterestInternal(src);
        redeemInternal(redeemTo, redeemTokens);
        return true;
    }

    /// @dev IRToken.redeemAndTransferAll implementation
    function redeemAndTransferAll(address redeemTo)
        external
        nonReentrant
        returns (bool)
    {
        address src = msg.sender;
        payInterestInternal(src);
        redeemInternal(redeemTo, accounts[src].rAmount);
        return true;
    }

    /// @dev IRToken.createHat implementation
    function createHat(
        address[] calldata recipients,
        uint32[] calldata proportions,
        bool doChangeHat
    ) external nonReentrant returns (uint256 hatID) {
        hatID = createHatInternal(recipients, proportions);
        if (doChangeHat) {
            changeHatInternal(msg.sender, hatID);
        }
    }

    /// @dev IRToken.changeHat implementation
    function changeHat(uint256 hatID) external nonReentrant returns (bool) {
        changeHatInternal(msg.sender, hatID);
        payInterestInternal(msg.sender);
        return true;
    }

    /// @dev IRToken.getMaximumHatID implementation
    function getMaximumHatID() external view returns (uint256 hatID) {
        return hats.length - 1;
    }

    /// @dev IRToken.getHatByAddress implementation
    function getHatByAddress(address owner)
        external
        view
        returns (
            uint256 hatID,
            address[] memory recipients,
            uint32[] memory proportions
        )
    {
        hatID = accounts[owner].hatID;
        (recipients, proportions) = _getHatByID(hatID);
    }

    /// @dev IRToken.getHatByID implementation
    function getHatByID(uint256 hatID)
        external
        view
        returns (address[] memory recipients, uint32[] memory proportions) {
        (recipients, proportions) = _getHatByID(hatID);
    }

    function _getHatByID(uint256 hatID)
        private
        view
        returns (address[] memory recipients, uint32[] memory proportions) {
        if (hatID != 0 && hatID != SELF_HAT_ID) {
            Hat memory hat = hats[hatID];
            recipients = hat.recipients;
            proportions = hat.proportions;
        } else {
            recipients = new address[](0);
            proportions = new uint32[](0);
        }
    }

    /// @dev IRToken.receivedSavingsOf implementation
    function receivedSavingsOf(address owner)
        external
        view
        returns (uint256 amount)
    {
        Account storage account = accounts[owner];
        uint256 rGross = sInternalToR(account.sInternalAmount);
        return rGross;
    }

    /// @dev IRToken.receivedLoanOf implementation
    function receivedLoanOf(address owner)
        external
        view
        returns (uint256 amount)
    {
        Account storage account = accounts[owner];
        return account.lDebt;
    }

    /// @dev IRToken.interestPayableOf implementation
    function interestPayableOf(address owner)
        external
        view
        returns (uint256 amount)
    {
        Account storage account = accounts[owner];
        return getInterestPayableOf(account);
    }

    /// @dev IRToken.payInterest implementation
    function payInterest(address owner) external nonReentrant returns (bool) {
        payInterestInternal(owner);
        return true;
    }

    /// @dev IRToken.getAccountStats implementation!1
    function getGlobalStats() external view returns (GlobalStats memory) {
        uint256 totalSavingsAmount;
        totalSavingsAmount += sOriginalToR(savingAssetOrignalAmount);
        return
            GlobalStats({
                totalSupply: totalSupply,
                totalSavingsAmount: totalSavingsAmount
            });
    }

    /// @dev IRToken.getAccountStats implementation
    function getAccountStats(address owner)
        external
        view
        returns (AccountStatsView memory stats)
    {
        Account storage account = accounts[owner];
        stats.hatID = account.hatID;
        stats.rAmount = account.rAmount;
        stats.rInterest = account.rInterest;
        stats.lDebt = account.lDebt;
        stats.sInternalAmount = account.sInternalAmount;

        stats.rInterestPayable = getInterestPayableOf(account);

        AccountStatsStored storage statsStored = accountStats[owner];
        stats.cumulativeInterest = statsStored.cumulativeInterest;

        return stats;
    }

    /// @dev IRToken.getHatStats implementation
    function getHatStats(uint256 hatID)
        external
        view
        returns (HatStatsView memory stats) {
        HatStatsStored storage statsStored = hatStats[hatID];
        stats.useCount = statsStored.useCount;
        stats.totalLoans = statsStored.totalLoans;

        stats.totalSavings = sInternalToR(statsStored.totalInternalSavings);
        return stats;
    }

    /// @dev IRToken.getCurrentSavingStrategy implementation
    function getCurrentSavingStrategy() external view returns (address) {
        return address(ias);
    }

    /// @dev IRToken.getSavingAssetBalance implementation
    function getSavingAssetBalance()
        external
        view
        returns (uint256 rAmount, uint256 sOriginalAmount)
    {
        sOriginalAmount = savingAssetOrignalAmount;
        rAmount = sOriginalToR(sOriginalAmount);
    }

    /// @dev IRToken.changeAllocationStrategy implementation
    function changeAllocationStrategy(address allocationStrategy_)
        external
        nonReentrant
        onlyOwner
    {
        IAllocationStrategy allocationStrategy = IAllocationStrategy(allocationStrategy_);
        require(
            allocationStrategy.underlying() == address(token),
            "New strategy should have the same underlying asset"
        );
        IAllocationStrategy oldIas = ias;
        ias = allocationStrategy;
        // redeem everything from the old strategy
        uint256 sOriginalBurned = oldIas.redeemUnderlying(totalSupply);
        // invest everything into the new strategy
        require(token.approve(address(ias), totalSupply), "token approve failed");
        uint256 sOriginalCreated = ias.investUnderlying(totalSupply);

        // calculate new saving asset conversion rate
        //
        // NOTE:
        //   - savingAssetConversionRate should be scaled by 1e18
        //   - to keep internalSavings constant:
        //     internalSavings == sOriginalBurned * savingAssetConversionRateOld
        //     internalSavings == sOriginalCreated * savingAssetConversionRateNew
        //     =>
        //     savingAssetConversionRateNew = sOriginalBurned
        //          * savingAssetConversionRateOld
        //          / sOriginalCreated
        //
        uint256 savingAssetConversionRateOld = savingAssetConversionRate;
        savingAssetConversionRate = sOriginalBurned
            .mul(savingAssetConversionRateOld)
            .div(sOriginalCreated);

        emit AllocationStrategyChanged(allocationStrategy_, savingAssetConversionRate);
    }

    /// @dev IRToken.changeHatFor implementation
    function getCurrentAllocationStrategy()
        external view returns (address allocationStrategy) {
        return address(ias);
    }

    /// @dev IRToken.changeHatFor implementation
    function changeHatFor(address contractAddress, uint256 hatID) external onlyOwner {
        require(_isContract(contractAddress), "Admin can only change hat for contract address");
        changeHatInternal(contractAddress, hatID);
    }

    /// @dev Update the rToken logic contract code
    function updateCode(address newCode) external onlyOwner delegatedOnly {
        updateCodeAddress(newCode);
        emit CodeUpdated(newCode);
    }

    /**
     * @dev Transfer `tokens` tokens from `src` to `dst` by `spender`
            Called by both `transfer` and `transferFrom` internally
     * @param spender The address of the account performing the transfer
     * @param src The address of the source account
     * @param dst The address of the destination account
     * @param tokens The number of tokens to transfer
     * @return Whether or not the transfer succeeded
     */
    function transferInternal(
        address spender,
        address src,
        address dst,
        uint256 tokens
    ) internal {
        require(src != dst, "src should not equal dst");

        require(
            accounts[src].rAmount >= tokens,
            "Not enough balance to transfer"
        );

        /* Get the allowance, infinite for the account owner */
        uint256 startingAllowance = 0;
        if (spender == src) {
            startingAllowance = MAX_UINT256;
        } else {
            startingAllowance = transferAllowances[src][spender];
        }
        require(
            startingAllowance >= tokens,
            "Not enough allowance for transfer"
        );

        /* Do the calculations, checking for {under,over}flow */
        uint256 allowanceNew = startingAllowance.sub(tokens);
        uint256 srcTokensNew = accounts[src].rAmount.sub(tokens);
        uint256 dstTokensNew = accounts[dst].rAmount.add(tokens);

        /////////////////////////
        // EFFECTS & INTERACTIONS
        // (No safe failures beyond this point)

        // check if src & dst have the same hat
        bool sameHat = accounts[src].hatID == accounts[dst].hatID;

        // apply hat inheritance rule
        if ((accounts[src].hatID != 0 &&
            accounts[dst].hatID == 0 &&
            accounts[src].hatID != SELF_HAT_ID)) {
            changeHatInternal(dst, accounts[src].hatID);
        }

        accounts[src].rAmount = srcTokensNew;
        accounts[dst].rAmount = dstTokensNew;

        /* Eat some of the allowance (if necessary) */
        if (startingAllowance != MAX_UINT256) {
            transferAllowances[src][spender] = allowanceNew;
        }

        // lRecipients adjustments
        if (!sameHat) {
            uint256 sInternalAmountCollected = estimateAndRecollectLoans(
                src,
                tokens
            );
            distributeLoans(dst, tokens, sInternalAmountCollected);
        } else {
            // apply same hat optimization
            sameHatTransfer(src, dst, accounts[src].hatID, tokens);
        }

        // rInterest adjustment for src
        //
        // rInterest should be the portion that is from interest payment, by
        // definition it should not be larger than rAmount.
        // It could happen because of rounding errors.
        if (accounts[src].rInterest > accounts[src].rAmount) {
            accounts[src].rInterest = accounts[src].rAmount;
        }

        /* We emit a Transfer event */
        emit Transfer(src, dst, tokens);
    }

    /**
     * @dev Sender supplies assets into the market and receives rTokens in exchange
     * @dev Invest into underlying assets immediately
     * @param mintAmount The amount of the underlying asset to supply
     */
    function mintInternal(uint256 mintAmount) internal {
        require(
            token.allowance(msg.sender, address(this)) >= mintAmount,
            "Not enough allowance"
        );

        Account storage account = accounts[msg.sender];

        // create saving assets
        require(token.transferFrom(msg.sender, address(this), mintAmount), "token transfer failed");
        require(token.approve(address(ias), mintAmount), "token approve failed");
        uint256 sOriginalCreated = ias.investUnderlying(mintAmount);

        // update global and account r balances
        totalSupply = totalSupply.add(mintAmount);
        account.rAmount = account.rAmount.add(mintAmount);

        // update global stats
        savingAssetOrignalAmount = savingAssetOrignalAmount.add(sOriginalCreated);

        // distribute saving assets as loans to recipients
        uint256 sInternalCreated = sOriginalToSInternal(sOriginalCreated);
        distributeLoans(msg.sender, mintAmount, sInternalCreated);

        emit Transfer(address(0), msg.sender, mintAmount);
    }

    /**
     * @notice Sender redeems rTokens in exchange for the underlying asset
     * @dev Withdraw equal amount of initially supplied underlying assets
     * @param redeemTo Destination address to send the redeemed tokens to
     * @param redeemAmount The number of rTokens to redeem into underlying
     */
    function redeemInternal(address redeemTo, uint256 redeemAmount) internal {
        Account storage account = accounts[msg.sender];
        require(redeemAmount > 0, "Redeem amount cannot be zero");
        require(
            redeemAmount <= account.rAmount,
            "Not enough balance to redeem"
        );

        uint256 sOriginalBurned = redeemAndRecollectLoans(
            msg.sender,
            redeemAmount
        );

        // update Account r balances and global statistics
        account.rAmount = account.rAmount.sub(redeemAmount);
        if (account.rInterest > account.rAmount) {
            account.rInterest = account.rAmount;
        }
        totalSupply = totalSupply.sub(redeemAmount);

        // update global stats
        if (savingAssetOrignalAmount > sOriginalBurned) {
            savingAssetOrignalAmount -= sOriginalBurned;
        } else {
            savingAssetOrignalAmount = 0;
        }

        // transfer the token back
        require(token.transfer(redeemTo, redeemAmount), "token transfer failed");

        emit Transfer(msg.sender, address(0), redeemAmount);
    }

    /**
     * @dev Create a new Hat
     * @param recipients List of beneficial recipients
*    * @param proportions Relative proportions of benefits received by the recipients
     */
    function createHatInternal(
        address[] memory recipients,
        uint32[] memory proportions
    ) internal returns (uint256 hatID) {
        uint256 i;

        require(recipients.length > 0, "Invalid hat: at least one recipient");
        require(recipients.length <= MAX_NUM_HAT_RECIPIENTS, "Invalild hat: maximum number of recipients reached");
        require(
            recipients.length == proportions.length,
            "Invalid hat: length not matching"
        );

        // normalize the proportions
        // safemath is not used here, because:
        // proportions are uint32, there is no overflow concern
        uint256 totalProportions = 0;
        for (i = 0; i < recipients.length; ++i) {
            require(
                proportions[i] > 0,
                "Invalid hat: proportion should be larger than 0"
            );
            require(recipients[i] != address(0), "Invalid hat: recipient should not be 0x0");
            // don't panic, no safemath, look above comment
            totalProportions += uint256(proportions[i]);
        }
        for (i = 0; i < proportions.length; ++i) {
            proportions[i] = uint32(
                // don't panic, no safemath, look above comment
                (uint256(proportions[i]) * uint256(PROPORTION_BASE)) /
                    totalProportions
            );
        }

        hatID = hats.push(Hat(recipients, proportions)) - 1;
        emit HatCreated(hatID);
    }

    /**
     * @dev Change the hat for `owner`
     * @param owner Account owner
     * @param hatID The id of the Hat
     */
    function changeHatInternal(address owner, uint256 hatID) internal {
        require(hatID == SELF_HAT_ID || hatID < hats.length, "Invalid hat ID");
        Account storage account = accounts[owner];
        uint256 oldHatID = account.hatID;
        HatStatsStored storage oldHatStats = hatStats[oldHatID];
        HatStatsStored storage newHatStats = hatStats[hatID];
        account.hatID = hatID;
        if (account.rAmount > 0) {
            uint256 sInternalAmountCollected = estimateAndRecollectLoans(
                owner,
                account.rAmount
            );
            distributeLoans(owner, account.rAmount, sInternalAmountCollected);
        }
        oldHatStats.useCount -= 1;
        newHatStats.useCount += 1;
        emit HatChanged(owner, oldHatID, hatID);
    }

    /**
     * @dev Get interest payable of the account
     */
    function getInterestPayableOf(Account storage account)
        internal
        view
        returns (uint256)
    {
        uint256 rGross = sInternalToR(account.sInternalAmount);
        if (rGross > (account.lDebt.add(account.rInterest))) {
            // don't panic, the condition guarantees that safemath is not needed
            return rGross - account.lDebt - account.rInterest;
        } else {
            // no interest accumulated yet or even negative interest rate!?
            return 0;
        }
    }

    /**
     * @dev Distribute the incoming tokens to the recipients as loans.
     *      The tokens are immediately invested into the saving strategy and
     *      add to the sAmount of the recipient account.
     *      Recipient also inherits the owner's hat if it does already have one.
     * @param owner Owner account address
     * @param rAmount rToken amount being loaned to the recipients
     * @param sInternalAmount Amount of saving assets (internal amount) being given to the recipients
     */
    function distributeLoans(
        address owner,
        uint256 rAmount,
        uint256 sInternalAmount
    ) internal {
        Account storage account = accounts[owner];
        Hat storage hat = hats[account.hatID == SELF_HAT_ID
            ? 0
            : account.hatID];
        uint256 i;
        if (hat.recipients.length > 0) {
            uint256 rLeft = rAmount;
            uint256 sInternalLeft = sInternalAmount;
            for (i = 0; i < hat.proportions.length; ++i) {
                address recipientAddress = hat.recipients[i];
                Account storage recipientAccount = accounts[recipientAddress];
                bool isLastRecipient = i == (hat.proportions.length - 1);

                // calculate the loan amount of the recipient
                uint256 lDebtRecipient = isLastRecipient
                    ? rLeft
                    : (rAmount.mul(hat.proportions[i])) / PROPORTION_BASE;
                // distribute the loan to the recipient
                account.lRecipients[recipientAddress] = account.lRecipients[recipientAddress]
                    .add(lDebtRecipient);
                recipientAccount.lDebt = recipientAccount.lDebt
                    .add(lDebtRecipient);
                // remaining value adjustments
                rLeft = gentleSub(rLeft, lDebtRecipient);

                // calculate the savings holdings of the recipient
                uint256 sInternalAmountRecipient = isLastRecipient
                    ? sInternalLeft
                    : (sInternalAmount.mul(hat.proportions[i])) / PROPORTION_BASE;
                recipientAccount.sInternalAmount = recipientAccount.sInternalAmount
                    .add(sInternalAmountRecipient);
                // remaining value adjustments
                sInternalLeft = gentleSub(sInternalLeft, sInternalAmountRecipient);

                _updateLoanStats(owner, recipientAddress, account.hatID, true, lDebtRecipient, sInternalAmountRecipient);
            }
        } else {
            // Account uses the zero/self hat, give all interest to the owner
            account.lDebt = account.lDebt.add(rAmount);
            account.sInternalAmount = account.sInternalAmount
                .add(sInternalAmount);

            _updateLoanStats(owner, owner, account.hatID, true, rAmount, sInternalAmount);
        }
    }

    /**
     * @dev Recollect loans from the recipients for further distribution
     *      without actually redeeming the saving assets
     * @param owner Owner account address
     * @param rAmount rToken amount neeeds to be recollected from the recipients
     *                by giving back estimated amount of saving assets
     * @return Estimated amount of saving assets (internal) needs to recollected
     */
    function estimateAndRecollectLoans(address owner, uint256 rAmount)
        internal
        returns (uint256 sInternalAmount)
    {
        // accrue interest so estimate is up to date
        require(ias.accrueInterest(), "accrueInterest failed");
        sInternalAmount = rToSInternal(rAmount);
        recollectLoans(owner, rAmount, sInternalAmount);
    }

    /**
     * @dev Recollect loans from the recipients for further distribution
     *      by redeeming the saving assets in `rAmount`
     * @param owner Owner account address
     * @param rAmount rToken amount neeeds to be recollected from the recipients
     *                by redeeming equivalent value of the saving assets
     * @return Amount of saving assets redeemed for rAmount of tokens.
     */
    function redeemAndRecollectLoans(address owner, uint256 rAmount)
        internal
        returns (uint256 sOriginalBurned)
    {
        sOriginalBurned = ias.redeemUnderlying(rAmount);
        uint256 sInternalBurned = sOriginalToSInternal(sOriginalBurned);
        recollectLoans(owner, rAmount, sInternalBurned);
    }

    /**
     * @dev Recollect loan from the recipients
     * @param owner   Owner address
     * @param rAmount rToken amount being written of from the recipients
     * @param sInternalAmount Amount of sasving assets (internal amount) recollected from the recipients
     */
    function recollectLoans(
        address owner,
        uint256 rAmount,
        uint256 sInternalAmount
    ) internal {
        Account storage account = accounts[owner];
        Hat storage hat = hats[account.hatID == SELF_HAT_ID
            ? 0
            : account.hatID];
        if (hat.recipients.length > 0) {
            uint256 rLeft = rAmount;
            uint256 sInternalLeft = sInternalAmount;
            uint256 i;
            for (i = 0; i < hat.proportions.length; ++i) {
                address recipientAddress = hat.recipients[i];
                Account storage recipientAccount = accounts[recipientAddress];
                bool isLastRecipient = i == (hat.proportions.length - 1);

                // calulate loans to be collected from the recipient
                uint256 lDebtRecipient = isLastRecipient
                    ? rLeft
                    : (rAmount.mul(hat.proportions[i])) / PROPORTION_BASE;
                recipientAccount.lDebt = gentleSub(
                    recipientAccount.lDebt,
                    lDebtRecipient);
                account.lRecipients[recipientAddress] = gentleSub(
                    account.lRecipients[recipientAddress],
                    lDebtRecipient);
                // loans leftover adjustments
                rLeft = gentleSub(rLeft, lDebtRecipient);

                // calculate savings to be collected from the recipient
                uint256 sInternalAmountRecipient = isLastRecipient
                    ? sInternalLeft
                    : (sInternalAmount.mul(hat.proportions[i])) / PROPORTION_BASE;
                recipientAccount.sInternalAmount = gentleSub(
                    recipientAccount.sInternalAmount,
                    sInternalAmountRecipient);
                // savings leftover adjustments
                sInternalLeft = gentleSub(sInternalLeft, sInternalAmountRecipient);

                _updateLoanStats(owner, recipientAddress, account.hatID, false, lDebtRecipient, sInternalAmountRecipient);
            }
        } else {
            // Account uses the zero hat, recollect interests from the owner
            account.lDebt = gentleSub(account.lDebt, rAmount);
            account.sInternalAmount = gentleSub(account.sInternalAmount, sInternalAmount);

            _updateLoanStats(owner, owner, account.hatID, false, rAmount, sInternalAmount);
        }
    }

    /**
     * @dev Optimized recollect and distribute loan for the same hat
     * @param src Source address
     * @param dst Destination address
     * @param rAmount rToken amount being written of from the recipients
     */
    function sameHatTransfer(
        address src,
        address dst,
        uint256 hatID,
        uint256 rAmount) internal {
        // accrue interest so estimate is up to date
        require(ias.accrueInterest(), "accrueInterest failed");

        Account storage srcAccount = accounts[src];
        Account storage dstAccount = accounts[dst];

        uint256 sInternalAmount = rToSInternal(rAmount);

        srcAccount.lDebt = gentleSub(srcAccount.lDebt, rAmount);
        srcAccount.sInternalAmount = gentleSub(srcAccount.sInternalAmount, sInternalAmount);
        _updateLoanStats(src, src, hatID, false, rAmount, sInternalAmount);

        dstAccount.lDebt = dstAccount.lDebt.add(rAmount);
        dstAccount.sInternalAmount = dstAccount.sInternalAmount.add(sInternalAmount);
        _updateLoanStats(dst, dst, hatID, true, rAmount, sInternalAmount);
    }

    /**
     * @dev pay interest to the owner
     * @param owner Account owner address
     */
    function payInterestInternal(address owner) internal {
        Account storage account = accounts[owner];
        AccountStatsStored storage stats = accountStats[owner];

        require(ias.accrueInterest(), "accrueInterest failed");
        uint256 interestAmount = getInterestPayableOf(account);

        if (interestAmount > 0) {
            stats.cumulativeInterest = stats
                .cumulativeInterest
                .add(interestAmount);
            account.rInterest = account.rInterest.add(interestAmount);
            account.rAmount = account.rAmount.add(interestAmount);
            totalSupply = totalSupply.add(interestAmount);
            emit InterestPaid(owner, interestAmount);
            emit Transfer(address(0), owner, interestAmount);
        }
    }

    function _updateLoanStats(
        address owner,
        address recipient,
        uint256 hatID,
        bool isDistribution,
        uint256 redeemableAmount,
        uint256 sInternalAmount) private {
        HatStatsStored storage hatStats = hatStats[hatID];

        emit LoansTransferred(owner, recipient, hatID,
            isDistribution,
            redeemableAmount,
            sInternalAmount);

        if (isDistribution) {
            hatStats.totalLoans = hatStats.totalLoans.add(redeemableAmount);
            hatStats.totalInternalSavings = hatStats.totalInternalSavings
                .add(sInternalAmount);
        } else {
            hatStats.totalLoans = gentleSub(hatStats.totalLoans, redeemableAmount);
            hatStats.totalInternalSavings = gentleSub(
                hatStats.totalInternalSavings,
                sInternalAmount);
        }
    }

    function _isContract(address addr) private view returns (bool) {
      uint size;
      assembly { size := extcodesize(addr) }
      return size > 0;
    }

    /**
     * @dev Gently subtract b from a without revert
     *
     * Due to the use of integer arithmatic, imprecision may cause a tiny
     * amount to be off when substracting the otherwise precise proportions.
     */
    function gentleSub(uint256 a, uint256 b) private pure returns (uint256) {
        if (a < b) return 0;
        else return a - b;
    }

    /// @dev convert internal savings amount to redeemable amount
    function sInternalToR(uint256 sInternalAmount)
        private view
        returns (uint256 rAmount) {
        // - rGross is in underlying(redeemable) asset unit
        // - Both ias.exchangeRateStored and savingAssetConversionRate are scaled by 1e18
        //   they should cancel out
        // - Formula:
        //   savingsOriginalAmount = sInternalAmount / savingAssetConversionRate
        //   rGross = savingAssetOrignalAmount * ias.exchangeRateStored
        //   =>
        return sInternalAmount
            .mul(ias.exchangeRateStored())
            .div(savingAssetConversionRate);
    }

    /// @dev convert redeemable amount to internal savings amount
    function rToSInternal(uint256 rAmount)
        private view
        returns (uint256 sInternalAmount) {
        return rAmount
            .mul(savingAssetConversionRate)
            .div(ias.exchangeRateStored());
    }

    /// @dev convert original savings amount to redeemable amount
    function sOriginalToR(uint sOriginalAmount)
        private view
        returns (uint256 sInternalAmount) {
        return sOriginalAmount
            .mul(ias.exchangeRateStored())
            .div(ALLOCATION_STRATEGY_EXCHANGE_RATE_SCALE);
    }

    // @dev convert from original savings amount to internal savings amount
    function sOriginalToSInternal(uint sOriginalAmount)
        private view
        returns (uint256 sInternalAmount) {
        // savingAssetConversionRate is scaled by 1e18
        return sOriginalAmount
            .mul(savingAssetConversionRate)
            .div(ALLOCATION_STRATEGY_EXCHANGE_RATE_SCALE);
    }
}
