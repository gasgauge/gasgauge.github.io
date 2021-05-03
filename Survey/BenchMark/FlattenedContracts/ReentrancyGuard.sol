
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
