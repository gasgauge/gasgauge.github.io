/**
 *Submitted for verification at Etherscan.io on 2020-09-09
*/

// File: @openzeppelin/contracts/GSN/Context.sol

//pragma solidity ^0.5.0;
pragma solidity >=0.5 <0.7.17;

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
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: @openzeppelin/contracts/ownership/Ownable.sol

//pragma solidity ^0.5.0;
pragma solidity >=0.5 <0.7.17;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
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
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: @openzeppelin/contracts/math/SafeMath.sol

//pragma solidity ^0.5.0;
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

// File: contracts/managment/Constants.sol

//pragma solidity 0.5.17;
pragma solidity >=0.5 <0.7.17;


contract Constants {
    // Permissions bit constants
    uint256 public constant CAN_MINT_TOKENS = 0;
    uint256 public constant CAN_BURN_TOKENS = 1;
    uint256 public constant CAN_UPDATE_STATE = 2;
    uint256 public constant CAN_LOCK_TOKENS = 3;
    uint256 public constant CAN_UPDATE_PRICE = 4;
    uint256 public constant CAN_INTERACT_WITH_ALLOCATOR = 5;
    uint256 public constant CAN_SET_ALLOCATOR_MAX_SUPPLY = 6;
    uint256 public constant CAN_PAUSE_TOKENS = 7;
    uint256 public constant ECLIUDED_ADDRESSES = 8;
    uint256 public constant WHITELISTED = 9;
    uint256 public constant SIGNERS = 10;
    uint256 public constant EXTERNAL_CONTRIBUTORS = 11;
    uint256 public constant CAN_SEE_BALANCE = 12;
    uint256 public constant CAN_CANCEL_TRANSACTION = 13;
    uint256 public constant CAN_ALLOCATE_REFERRAL_TOKENS = 14;
    uint256 public constant CAN_SET_REFERRAL_MAX_SUPPLY = 15;
    uint256 public constant MANUAL_TOKENS_ALLOCATION = 16;
    uint256 public constant CAN_SET_WHITELISTED = 17;

    // Contract Registry keys
    uint256 public constant CONTRACT_TOKEN = 1;
    uint256 public constant CONTRACT_PRICING = 2;
    uint256 public constant CONTRACT_CROWDSALE = 3;
    uint256 public constant CONTRACT_ALLOCATOR = 4;
    uint256 public constant CONTRACT_AGENT = 5;
    uint256 public constant CONTRACT_FORWARDER = 6;
    uint256 public constant CONTRACT_REFERRAL = 7;
    uint256 public constant CONTRACT_STATS = 8;
    uint256 public constant CONTRACT_LOCKUP = 9;

    uint256 public constant YEAR_IN_SECONDS = 31556952;
    uint256 public constant SIX_MONTHS =  15778476;
    uint256 public constant MONTH_IN_SECONDS = 2629746;

    string public constant ERROR_ACCESS_DENIED = "ERROR_ACCESS_DENIED";
    string public constant ERROR_WRONG_AMOUNT = "ERROR_WRONG_AMOUNT";
    string public constant ERROR_NO_CONTRACT = "ERROR_NO_CONTRACT";
    string public constant ERROR_NOT_AVAILABLE = "ERROR_NOT_AVAILABLE";
}

// File: contracts/managment/Management.sol

//pragma solidity 0.5.17;
pragma solidity >=0.5 <0.7.17;




contract Management is Ownable, Constants {

    // Contract Registry
    mapping (uint256 => address payable) public contractRegistry;

    // Permissions
    mapping (address => mapping(uint256 => bool)) public permissions;

    event PermissionsSet(
        address subject, 
        uint256 permission, 
        bool value
    );

    event ContractRegistered(
        uint256 key,
        address source,
        address target
    );

    function setPermission(
        address _address, 
        uint256 _permission, 
        bool _value
    )
        public
        onlyOwner
    {
        permissions[_address][_permission] = _value;
        emit PermissionsSet(_address, _permission, _value);
    }

    function registerContract(
        uint256 _key, 
        address payable _target
    ) 
        public 
        onlyOwner 
    {
        contractRegistry[_key] = _target;
        emit ContractRegistered(_key, address(0), _target);
    }

    function setWhitelisted(
        address _address,
        bool _value
    )
        public
    {
        require(
            permissions[msg.sender][CAN_SET_WHITELISTED] == true,
            ERROR_ACCESS_DENIED
        );

        permissions[_address][WHITELISTED] = _value;

        emit PermissionsSet(_address, WHITELISTED, _value);
    }

}

// File: contracts/managment/Managed.sol

//pragma solidity 0.5.17;
pragma solidity >=0.5 <0.7.17;






contract Managed is Ownable, Constants {

    using SafeMath for uint256;

    Management public management;

    modifier requirePermission(uint256 _permissionBit) {
        require(
            hasPermission(msg.sender, _permissionBit),
            ERROR_ACCESS_DENIED
        );
        _;
    }

    modifier canCallOnlyRegisteredContract(uint256 _key) {
        require(
            msg.sender == management.contractRegistry(_key),
            ERROR_ACCESS_DENIED
        );
        _;
    }

    modifier requireContractExistsInRegistry(uint256 _key) {
        require(
            management.contractRegistry(_key) != address(0),
            ERROR_NO_CONTRACT
        );
        _;
    }

    constructor(address _managementAddress) public {
        management = Management(_managementAddress);
    }

    function setManagementContract(address _management) public onlyOwner {
        require(address(0) != _management, ERROR_NO_CONTRACT);

        management = Management(_management);
    }

    function hasPermission(address _subject, uint256 _permissionBit)
        internal
        view
        returns (bool)
    {
        return management.permissions(_subject, _permissionBit);
    }

}

// File: contracts/allocator/TokenAllocator.sol

//pragma solidity 0.5.17;
pragma solidity >=0.5 <0.7.17;



/// @title TokenAllocator
/// @author Applicature
/// @notice Contract responsible for defining distribution logic of tokens.
/// @dev Base class
contract TokenAllocator is Managed {

    uint256 public maxSupply;

    constructor(uint256 _maxSupply, address _management)
        public
        Managed(_management)
    {
        maxSupply = _maxSupply;
    }

    function allocate(
        address _holder,
        uint256 _tokens,
        uint256 _allocatedTokens
    )
        public
        requirePermission(CAN_INTERACT_WITH_ALLOCATOR)
    {
        require(
            tokensAvailable(_allocatedTokens) >= _tokens,
            ERROR_WRONG_AMOUNT
        );
        internalAllocate(_holder, _tokens);
    }

    function updateMaxSupply(uint256 _maxSupply)
        internal
        requirePermission(CAN_INTERACT_WITH_ALLOCATOR)
    {
        maxSupply = _maxSupply;
    }

    /// @notice Check whether contract is initialised
    /// @return true if initialized
    function isInitialized() public view returns (bool) {
        if (
            address(management) == address(0) ||
            management.contractRegistry(CONTRACT_TOKEN) == address(0) ||
            management.contractRegistry(CONTRACT_ALLOCATOR) != address(this)
        ) {
            return false;
        }
        return true;
    }

    /// @return available tokens
    function tokensAvailable(uint256 _allocatedTokens)
        public
        view
        returns (uint256)
    {
        return maxSupply.sub(_allocatedTokens);
    }

    function internalAllocate(
        address _holder,
        uint256 _tokens
    )
        internal;
}

// File: contracts/pricing/PricingStrategy.sol

//pragma solidity 0.5.17;
pragma solidity >=0.5 <0.7.17;


/// @title PricingStrategy
/// @author Applicature
/// @notice Contract is responsible for calculating tokens amount depending on different criterias
/// @dev Base class
contract PricingStrategy {

    function isInitialized() public view returns (bool);

    function getCurrencyAmount(uint256 _weiAmount)
        public
        view
        returns (uint256);

    function getTokens(
        address _contributor,
        uint256 _tokensAvailable, uint256 _tokensSold,
        uint256 _weiAmount, uint256 _collectedWei
    )
        public
        view
        returns (
            uint256 tokens,
            uint256 tokensExludingBonus,
            uint256 bonus
        );

    function getWeis(
        uint256 _collectedWei,
        uint256 _tokensSold,
        uint256 _tokens
    )
        public
        view
        returns (
            uint256 weiAmount,
            uint256 tokensBonus
        );
}

// File: contracts/pricing/ExchangeContract.sol

//pragma solidity 0.5.17;
pragma solidity >=0.5 <0.7.17;



contract ExchangeContract is Managed {

    uint256 public etherPriceInCurrency;
    uint256 public currencyDecimals;
    uint256 public priceUpdateAt;

    event NewPriceTicker(string _price);

    constructor(
        address _management,
        uint256 _etherPriceInCurrency,
        uint256 _currencyDecimals
    )
        public
        Managed(_management)
    {
        require(_etherPriceInCurrency > 0, ERROR_WRONG_AMOUNT);
        require(_currencyDecimals > 0, ERROR_WRONG_AMOUNT);

        etherPriceInCurrency = _etherPriceInCurrency;
        currencyDecimals = _currencyDecimals;
        priceUpdateAt = block.timestamp;
    }

    function setEtherInCurrency(string memory _price)
        public
        requirePermission(CAN_UPDATE_PRICE)
    {
        bytes memory bytePrice = bytes(_price);
        uint256 dot = bytePrice.length.sub(uint256(currencyDecimals).add(1));

        require(0x2e == uint(uint8(bytePrice[dot])), ERROR_WRONG_AMOUNT);

        etherPriceInCurrency = parseInt(_price, currencyDecimals);

        require(etherPriceInCurrency > 0, ERROR_WRONG_AMOUNT);

        priceUpdateAt = block.timestamp;

        emit NewPriceTicker(_price);
    }

    function parseInt(
        string memory _a,
        uint _b
    )
        internal
        pure
        returns (uint _parsedInt)
    {
        bytes memory bresult = bytes(_a);
        uint mint = 0;
        bool decimals = false;
        for (uint i = 0; i < bresult.length; i++) {
            if (
                (uint(uint8(bresult[i])) >= 48) &&
                (uint(uint8(bresult[i])) <= 57)
            ) {
                if (decimals) {
                    if (_b == 0) {
                        break;
                    } else {
                        _b--;
                    }
                }
                mint *= 10;
                mint += uint(uint8(bresult[i])) - 48;
            } else if (uint(uint8(bresult[i])) == 46) {
                decimals = true;
            }
        }
        if (_b > 0) {
            mint *= 10 ** _b;
        }
        return mint;
    }

}

// File: contracts/pricing/PricingStrategyImpl.sol

//pragma solidity 0.5.17;
pragma solidity >=0.5 <0.7.17;




/**
 * @title PricingStrategy
 * @author Applicature
 * @notice Contract is responsible for calculating tokens amount depending on price in USD
 * @dev implementation
 */
contract PricingStrategyImpl is PricingStrategy, ExchangeContract {

    uint256 public constant TIER_ELEMENTS_AMOUNT = 9;

    struct Tier {
        uint256 tokenInCurrency;
        uint256 maxTokensCollected;
        uint256 bonusCap;
        uint256 discountPercents;
        uint256 bonusPercents;
        uint256 minInvestInCurrency;
        uint256 maxInvestInCurrency;
        uint256 startTime;
        uint256 endTime;
    }

    Tier[] public tiers;
    uint256 public tokenDecimals;
    uint256 public percentageAbsMax;
    bool tiersChangingAllowed;
    bool updateChangeRateAllowed;

    constructor(
        address _management,
        bool _tiersChangingAllowed,
        bool _updateChangeRateAllowed,
        uint256[] memory _tiers,
        uint256 _etherPriceInCurrency,
        uint256 _currencyDecimals,
        uint256 _tokenDecimals,
        uint256 _percentageAbsMax
    )
        public
        ExchangeContract(_management, _etherPriceInCurrency, _currencyDecimals)
    {
        require(_tiers.length % TIER_ELEMENTS_AMOUNT == 0, ERROR_WRONG_AMOUNT);
        require(_tokenDecimals > 0, ERROR_WRONG_AMOUNT);
        require(_percentageAbsMax > 0, ERROR_WRONG_AMOUNT);

        tokenDecimals = _tokenDecimals;
        percentageAbsMax = _percentageAbsMax;
        tiersChangingAllowed = _tiersChangingAllowed;
        updateChangeRateAllowed = _updateChangeRateAllowed;

        uint256 length = _tiers.length.div(TIER_ELEMENTS_AMOUNT);
        for (uint256 i = 0; i < length; i++) {
            require(
                _tiers[i.mul(TIER_ELEMENTS_AMOUNT).add(1)] > 0 &&
                _tiers[i.mul(TIER_ELEMENTS_AMOUNT).add(3)] < _percentageAbsMax &&
                _tiers[i.mul(TIER_ELEMENTS_AMOUNT).add(4)] < _percentageAbsMax &&
                _tiers[i.mul(TIER_ELEMENTS_AMOUNT).add(7)] > 0 &&
                _tiers[i.mul(TIER_ELEMENTS_AMOUNT).add(8)] > _tiers[i.mul(TIER_ELEMENTS_AMOUNT).add(7)],
                ERROR_WRONG_AMOUNT
            );
            require (
                _tiers[i.mul(TIER_ELEMENTS_AMOUNT).add(6)] == 0 ||
                _tiers[i.mul(TIER_ELEMENTS_AMOUNT).add(6)] >= _tiers[i.mul(TIER_ELEMENTS_AMOUNT).add(5)],
                ERROR_WRONG_AMOUNT
            );
            tiers.push(
                Tier(
                    _tiers[i.mul(TIER_ELEMENTS_AMOUNT)],//tokenInCurrency
                    _tiers[i.mul(TIER_ELEMENTS_AMOUNT).add(1)],//maxTokensCollected
                    _tiers[i.mul(TIER_ELEMENTS_AMOUNT).add(2)],//bonusCap
                    _tiers[i.mul(TIER_ELEMENTS_AMOUNT).add(3)],//discountPercents
                    _tiers[i.mul(TIER_ELEMENTS_AMOUNT).add(4)],//bonusPercents
                    _tiers[i.mul(TIER_ELEMENTS_AMOUNT).add(5)],//minInvestInCurrency
                    _tiers[i.mul(TIER_ELEMENTS_AMOUNT).add(6)],//maxInvestInCurrency
                    _tiers[i.mul(TIER_ELEMENTS_AMOUNT).add(7)],//startTime
                    _tiers[i.mul(TIER_ELEMENTS_AMOUNT).add(8)]//endTime
                )
            );
        }
    }

    function updateDates(
        uint8 _tierId,
        uint256 _start,
        uint256 _end
    )
        public
        onlyOwner
    {
        require (
            _start != 0 &&
            _start < _end &&
            _tierId < tiers.length,
            ERROR_WRONG_AMOUNT
        );
        Tier storage tier = tiers[_tierId];
        tier.startTime = _start;
        tier.endTime = _end;
    }

    function updateTier(
        uint256 _tierId,
        uint256 _tokenInCurrency,
        uint256 _maxTokensCollected,
        uint256 _bonusCap,
        uint256 _discountPercents,
        uint256 _bonusPercents,
        uint256 _minInvestInCurrency,
        uint256 _maxInvestInCurrency,
        uint256 _startTime,
        uint256 _endTime
    )
        public
        onlyOwner
    {
        require(
            tiersChangingAllowed == true &&
            _maxTokensCollected >= _bonusCap &&
            _discountPercents < percentageAbsMax &&
            _bonusPercents < percentageAbsMax &&
            (_maxInvestInCurrency == 0 || _maxInvestInCurrency >= _minInvestInCurrency) &&
            _startTime != 0 &&
            _startTime < _endTime &&
            _tierId < tiers.length,
            ERROR_WRONG_AMOUNT
        );

        Tier storage tier = tiers[_tierId];
        tier.tokenInCurrency = _tokenInCurrency;
        tier.maxTokensCollected = _maxTokensCollected;
        tier.bonusCap = _bonusCap;
        tier.discountPercents = _discountPercents;
        tier.bonusPercents = _bonusPercents;
        tier.minInvestInCurrency = _minInvestInCurrency;
        tier.maxInvestInCurrency = _maxInvestInCurrency;
        tier.startTime = _startTime;
        tier.endTime = _endTime;
    }

    function setEtherInCurrency(string memory _price)
        public
        requirePermission(CAN_UPDATE_PRICE)
    {
        require(updateChangeRateAllowed == true, ERROR_NOT_AVAILABLE);
        super.setEtherInCurrency(_price);
    }

    function isInitialized() 
        public 
        view 
        returns (bool) 
    {
        return tiers.length > 0;
    }

    function getArrayOfTiers() 
        public 
        view 
        returns (uint256[] memory)
    {
        uint256[] memory tiersData = new uint256[](
            getTiersAmount().mul(TIER_ELEMENTS_AMOUNT)
        );

        uint256 j = 0;
        for (uint256 i = 0; i < tiers.length; i++) {
            tiersData[j++] = uint256(tiers[i].tokenInCurrency);
            tiersData[j++] = uint256(tiers[i].maxTokensCollected);
            tiersData[j++] = uint256(tiers[i].bonusCap);
            tiersData[j++] = uint256(tiers[i].discountPercents);
            tiersData[j++] = uint256(tiers[i].bonusPercents);
            tiersData[j++] = uint256(tiers[i].minInvestInCurrency);
            tiersData[j++] = uint256(tiers[i].maxInvestInCurrency);
            tiersData[j++] = uint256(tiers[i].startTime);
            tiersData[j++] = uint256(tiers[i].endTime);
        }

        return tiersData;
    }

    function getTiersAmount()
        public 
        view 
        returns (uint256) 
    {
        return tiers.length;
    }

    function getTierIndex(uint256 _tokensSold) 
        public 
        view 
        returns (uint256) 
    {
        for (uint256 i = 0; i < tiers.length; i++) {
            if (
                block.timestamp >= tiers[i].startTime &&
                block.timestamp < tiers[i].endTime &&
                tiers[i].maxTokensCollected > _tokensSold
            ) {
                return i;
            }
        }

        return tiers.length;
    }

    function getActualTierIndex(uint256 _tokensSold)
        public
        view
        returns (uint256)
    {
        for (uint256 i = 0; i < tiers.length; i++) {
            if (
                block.timestamp >= tiers[i].startTime &&
                block.timestamp < tiers[i].endTime &&
                tiers[i].maxTokensCollected > _tokensSold ||
                block.timestamp < tiers[i].startTime
            ) {
                return i;
            }
        }

        return tiers.length.sub(1);
    }

    function getTierActualDates(uint256 _tokensSold)
        public
        view
        returns (uint256 startTime, uint256 endTime)
    {
        uint256 tierIndex = getActualTierIndex(_tokensSold);
        startTime = tiers[tierIndex].startTime;
        endTime = tiers[tierIndex].endTime;
    }

    function getCurrencyAmount(uint256 _weiAmount)
        public
        view
        returns (uint256)
    {
        return _weiAmount.mul(etherPriceInCurrency).div(1 ether);
    }

    function getTokenInCurrency(uint256 _tierIndex)
        public
        view
        returns (uint256)
    {
        if (_tierIndex < tiers.length) {
            if (getDiscount(_tierIndex) > 0) {

                return tiers[_tierIndex].tokenInCurrency.mul(
                    percentageAbsMax.sub(getDiscount(_tierIndex))
                ).div(percentageAbsMax);
            }

            return tiers[_tierIndex].tokenInCurrency;
        }
    }

    function calculateTokensByCurrency(
        uint256 _tierIndex,
        uint256 _currencyAmount
    )
        public
        view
        returns (uint256)
    {
        return _currencyAmount.mul(uint256(10) ** tokenDecimals)
            .div(getTokenInCurrency(_tierIndex));
    }

    function calculateCurrencyByTokens(
        uint256 _tierIndex,
        uint256 _tokenAmount
    )
        public
        view
        returns (uint256)
    {
        return _tokenAmount.mul(getTokenInCurrency(_tierIndex))
            .div(uint256(10) ** tokenDecimals);
    }

    function getDiscount(uint256 _tierIndex) 
        public 
        view 
        returns (uint256) 
    {
        if (_tierIndex < uint256(tiers.length)) {
            return tiers[_tierIndex].discountPercents;
        }
    }

    function getMinEtherInvest(uint256 _tierIndex)
        public
        view
        returns (uint256)
    {
        if (
            _tierIndex < uint256(tiers.length) && 
            tiers[_tierIndex].minInvestInCurrency > 0
        ) {
            return tiers[_tierIndex].minInvestInCurrency
                .mul(1 ether)
                .div(etherPriceInCurrency);
        }
    }

    function getMaxEtherInvest(uint256 _tierIndex)
        public
        view
        returns (uint256)
    {
        if (
            _tierIndex < uint256(tiers.length) && 
            tiers[_tierIndex].maxInvestInCurrency > 0
        ) {
            return tiers[_tierIndex].maxInvestInCurrency
                .mul(1 ether)
                .div(etherPriceInCurrency);
        }
    }

    function getRemainingTokens(uint256 _tokensSold)
        public
        view
        returns (uint256)
    {
        return tiers[tiers.length.sub(1)]
            .maxTokensCollected
            .sub(_tokensSold);
    }

    function getTierUnsoldTokens(uint256 _tokensSold) 
        public 
        view 
        returns (uint256) 
    {   
        return tiers[getActualTierIndex(_tokensSold)]
            .maxTokensCollected
            .sub(_tokensSold);
    }

    function calculateBonusAmount(
        uint256 _tierIndex, 
        uint256 _tokens, 
        uint256 _bonusProduced
    )
        public
        view
        returns (uint256)
    {
        if (_bonusProduced.add(_tokens) <= tiers[_tierIndex].bonusCap) {
            return _tokens
                .mul(tiers[_tierIndex].bonusPercents)
                .div(percentageAbsMax);
        }

        return tiers[_tierIndex]
            .bonusCap
            .sub(_bonusProduced)
            .mul(tiers[_tierIndex].bonusPercents)
            .div(percentageAbsMax);
    }

    function getTokensWithoutRestrictions(
        uint256 _currencyAmount,
        uint256 _tokensSold
    )
        public
        view
        returns (
            uint256 tokens, 
            uint256 tokensExcludingBonus, 
            uint256 bonus
        )
    {
        if (_currencyAmount == 0) {
            return (0, 0, 0);
        }

        uint256 tierIndex = getActualTierIndex(_tokensSold);

        tokensExcludingBonus = calculateTokensByCurrency(
            tierIndex,
            _currencyAmount
        );
        bonus = tokensExcludingBonus
            .mul(tiers[tierIndex].bonusPercents)
            .div(percentageAbsMax);
        tokens = tokensExcludingBonus.add(bonus);
    }

    function getTokens(
        address,
        uint256 _tokensAvailable,
        uint256 _tokensSold,
        uint256 _currencyAmount,
        uint256 _bonusProduced
    )
        public
        view
        returns (
            uint256 tokens,
            uint256 tokensExcludingBonus,
            uint256 bonus
        )
    {
        if (_currencyAmount == 0) {
            return (0, 0, 0);
        }

        uint256 tierIndex = getTierIndex(_tokensSold);
        if (tierIndex == tiers.length) {
            return (0, 0, 0);
        }

        if (
            _currencyAmount < tiers[tierIndex].minInvestInCurrency ||
            tiers[tierIndex].maxInvestInCurrency > 0 &&
            _currencyAmount > tiers[tierIndex].maxInvestInCurrency
        ) {
            return (0, 0, 0);
        }

        uint256 remainingCurrencyAmount = _currencyAmount;
        uint256 newTokensSold = _tokensSold;
        uint256 tierTokens;
        uint256 diff;

        for (uint256 i = tierIndex; i < tiers.length; i++) {
            tierTokens = calculateTokensByCurrency(i, remainingCurrencyAmount);

            if (
                tiers[i].startTime < block.timestamp &&
                tiers[i].endTime > block.timestamp
            ) {
                if (newTokensSold.add(tierTokens) > tiers[i].maxTokensCollected) {
                    diff = tiers[i].maxTokensCollected.sub(newTokensSold);
                    remainingCurrencyAmount = remainingCurrencyAmount.sub(
                        calculateCurrencyByTokens(i, diff)
                    );
                } else {
                    diff = tierTokens;
                    remainingCurrencyAmount = 0;
                }

                tokensExcludingBonus = tokensExcludingBonus.add(diff);
                bonus = bonus.add(calculateBonusAmount(i, diff, _bonusProduced));

                if (remainingCurrencyAmount == 0) {
                    break;
                }
            }
        }

        tokens = tokens.add(tokensExcludingBonus.add(bonus));

        if (remainingCurrencyAmount > 0 || tokens > _tokensAvailable) {
            return (0, 0, 0);
        }
    }

    function getWeis(
        uint256 _bonusProduced,
        uint256 _tokensSold,
        uint256 _tokens
    )
        public
        view
        returns (
            uint256 totalWeiAmount, 
            uint256 tokensBonus
        )
    {
        if (_tokens == 0) {
            return (0, 0);
        }

        uint256 tierIndex = getTierIndex(_tokensSold);
        if (tierIndex == tiers.length) {
            return (0, 0);
        }

        uint256 remainingTokens = _tokens;
        uint256 newTokensSold = _tokensSold;
        uint256 diff;

        for (uint i = tierIndex; i < tiers.length; i++) {
            if (
                tiers[i].startTime < block.timestamp &&
                tiers[i].endTime > block.timestamp
            ) {
                if (
                    newTokensSold.add(remainingTokens) > 
                    tiers[i].maxTokensCollected
                ) {
                    diff = tiers[i].maxTokensCollected.sub(newTokensSold);
                    remainingTokens = remainingTokens.sub(diff);
                } else {
                    diff = remainingTokens;
                    remainingTokens = 0;
                }

                totalWeiAmount = totalWeiAmount.add(
                    calculateCurrencyByTokens(i, diff).mul(1 ether).div(etherPriceInCurrency)
                );
                tokensBonus = tokensBonus
                    .add(calculateBonusAmount(i, diff, _bonusProduced));

                if (remainingTokens == 0) {
                    break;
                }
            }
        }

        uint256 currencyAmount = getCurrencyAmount(totalWeiAmount);
        if (
            currencyAmount < tiers[tierIndex].minInvestInCurrency ||
            tiers[tierIndex].maxInvestInCurrency > 0 &&
            currencyAmount > tiers[tierIndex].maxInvestInCurrency
        ) {
            return (0, 0);
        }

        if (remainingTokens > 0) {
            return (0, 0);
        }
    }
}

// File: contracts/CLIPricingStrategy.sol

//pragma solidity 0.5.17;
pragma solidity >=0.5 <0.7.17;



contract CLIPricingStrategy is PricingStrategyImpl {

    constructor(
        address _management,
        uint256 _etherPriceInCurrency,
        uint256[] memory _tiers
    ) public PricingStrategyImpl(
        _management,
        true,
        true,
        _tiers,
        _etherPriceInCurrency,
        5,  // main currency decimals - 1$ = 100000
        18, // token decimals
        100 // absolute percent amount  - 100%
    ) {
    }

}

// File: contracts/agent/Agent.sol

//pragma solidity 0.5.17;
pragma solidity >=0.5 <0.7.17;



/// @title Agent
/// @author Applicature
/// @notice Contract which takes actions on state change and contribution
/// @dev Base class
contract Agent is Managed {

    constructor(address _management) public Managed(_management) {}

    function isInitialized() public view returns (bool);
}

// File: contracts/crowdsale/Crowdsale.sol

//pragma solidity 0.5.17;
pragma solidity >=0.5 <0.7.17;


contract Crowdsale {

    uint256 public tokensSold;
    uint256 public bonusProduced;

    enum State {
        Unknown,
        Initializing,
        BeforeCrowdsale,
        InCrowdsale,
        Success,
        Finalized,
        Refunding
    }

    function externalContribution(
        address payable _contributor,
        uint256 _currencyAmount
    )
        external
        payable;

    function contribute(uint8 _v, bytes32 _r, bytes32 _s) external payable;

    function updateState() public;

    function getState() public view returns (State);

    function isInitialized() public view returns (bool);

    function internalContribution(
        address payable _contributor,
        uint256 _currencyAmount
    )
        internal;
}

// File: contracts/agent/CrowdsaleAgent.sol

//pragma solidity 0.5.17;
pragma solidity >=0.5 <0.7.17;




/// @title CrowdsaleAgent
/// @author Applicature
/// @notice Contract which takes actions on state change and contribution
/// @dev Base class
contract CrowdsaleAgent is Agent {

    constructor(address _management) public Agent(_management) {}

    function isInitialized()
        public
        view
        returns (bool)
    {
        return (
            address(management) != address(0) &&
            management.contractRegistry(CONTRACT_CROWDSALE) != address(0)
        );
    }

    function onContribution(
        address _contributor,
        uint256 _currencyAmount,
        uint256 _tokens,
        uint256 _bonus
    )
        public
        canCallOnlyRegisteredContract(CONTRACT_CROWDSALE)
    {}

    function onStateChange(
        Crowdsale.State _state
    )
        public
        requirePermission(CAN_UPDATE_STATE)
        requireContractExistsInRegistry(CONTRACT_CROWDSALE)
    {}

    function onRefund(
        address _contributor,
        uint256 _tokens
    )
        public
        canCallOnlyRegisteredContract(CONTRACT_CROWDSALE)
        returns (uint256 burned)
    {}

}

// File: contracts/contribution/ContributionForwarder.sol

//pragma solidity 0.5.17;
pragma solidity >=0.5 <0.7.17;



/// @title ContributionForwarder
/// @author Applicature
/// @notice Contract is responsible for distributing collected ethers, that are received from CrowdSale.
/// @dev Base class
contract ContributionForwarder is Managed {

    uint256 public weiCollected;
    uint256 public weiForwarded;

    event ContributionForwarded(
        address receiver,
        uint256 weiAmount
    );

    constructor(address _management) 
        public 
        Managed(_management) 
    {}

    /// @notice transfer wei to receiver
    function forward() 
        public 
        payable 
    {
        require(msg.value > 0, ERROR_WRONG_AMOUNT);

        weiCollected = weiCollected.add(msg.value);
        internalForward();
    }

    function isInitialized()
        public
        view
        returns (bool)
    {
        return (
            address(management) != address(0) &&
            management.contractRegistry(
                CONTRACT_FORWARDER
            ) != address(0)
        );
    }

    function internalForward() internal;
}

// File: contracts/crowdsale/CrowdsaleImpl.sol

//pragma solidity 0.5.17;
pragma solidity >=0.5 <0.7.17;








/// @title Crowdsale
/// @author Applicature
/// @notice Contract is responsible for collecting, refunding, allocating tokens during different stages of Crowdsale.
contract CrowdsaleImpl is Crowdsale, Managed {

    State public currentState;
    bool public finalized;
    uint256 public startDate;
    uint256 public endDate;
    bool public allowWhitelisted;
    bool public allowSigned;
    bool public allowAnonymous;

    event Contribution(
        address _contributor,
        uint256 _currencyAmount,
        uint256 _tokensExcludingBonus,
        uint256 _bonus
    );

    constructor(
        uint256 _startDate,
        uint256 _endDate,
        bool _allowWhitelisted,
        bool _allowSigned,
        bool _allowAnonymous,
        address _management
    ) 
        public 
        Managed(_management) 
    {
        startDate = _startDate;
        endDate = _endDate;

        allowWhitelisted = _allowWhitelisted;
        allowSigned = _allowSigned;
        allowAnonymous = _allowAnonymous;

        currentState = State.Unknown;
    }

    /// @notice default payable function
    function()
        external
        payable
    {
        buyInternal(
            msg.sender,
            msg.value
        );
    }

    /// @notice allows external user to do contribution
    function externalContribution(
        address payable _contributor,
        uint256 _currencyAmount
    )
        external
        payable 
        requirePermission(EXTERNAL_CONTRIBUTORS)
    {
        internalContribution(_contributor, _currencyAmount);
    }

    /// @notice allows to do signed contributions
    function contribute(
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    )
        external
        payable
    {
        address recoveredAddress = verify(
            msg.sender,
            _v,
            _r,
            _s
        );

        require(hasPermission(recoveredAddress, SIGNERS), ERROR_ACCESS_DENIED);
        internalContribution(
            msg.sender,
            PricingStrategy(management.contractRegistry(CONTRACT_PRICING)).getCurrencyAmount(msg.value)
        );
    }

    /// @notice Crowdsale state
    function updateState() public {
        State state = getState();

        if (currentState != state) {
            if (management.contractRegistry(CONTRACT_AGENT) != address(0)) {
                CrowdsaleAgent(management.contractRegistry(CONTRACT_AGENT)).onStateChange(state);
            }
            currentState = state;
        }
    }

    /// @notice check sign
    function verify(
        address _sender, 
        uint8 _v, 
        bytes32 _r, 
        bytes32 _s
    )
        public
        view
        returns (address)
    {

        bytes32 hash = keccak256(abi.encodePacked(address(this), _sender));

        bytes memory prefix = "\x19Ethereum Signed Message:\n32";

        return ecrecover(
            keccak256(abi.encodePacked(prefix, hash)),
            _v, 
            _r, 
            _s
        );
    }

    /// @return Crowdsale state
    function getState() public view returns (State) {
        if (finalized) {
            return State.Finalized;
        } else if (TokenAllocator(management.contractRegistry(CONTRACT_ALLOCATOR)).isInitialized() == false) {
            return State.Initializing;
        } else if (ContributionForwarder(management.contractRegistry(CONTRACT_FORWARDER)).isInitialized() == false) {
            return State.Initializing;
        } else if (PricingStrategy(management.contractRegistry(CONTRACT_PRICING)).isInitialized() == false) {
            return State.Initializing;
        } else if (block.timestamp < startDate) {
            return State.BeforeCrowdsale;
        } else if (block.timestamp >= startDate && block.timestamp <= endDate) {
            return State.InCrowdsale;
        } else if (block.timestamp > endDate) {
            return State.Success;
        }

        return State.Unknown;
    }

    function isInitialized() public view returns (bool) {
        return (
            management.contractRegistry(CONTRACT_TOKEN) != address(0) &&
            management.contractRegistry(CONTRACT_AGENT) != address(0) &&
            management.contractRegistry(CONTRACT_FORWARDER) != address(0) &&
            management.contractRegistry(CONTRACT_PRICING) != address(0) &&
            management.contractRegistry(CONTRACT_ALLOCATOR) != address(0)
        );
    }

    function buyInternal(
        address payable _contributor,
        uint256 ethAmount
    ) internal {
        require(allowWhitelisted || allowAnonymous, ERROR_ACCESS_DENIED);

        if (!allowAnonymous && allowWhitelisted) {
            require(hasPermission(_contributor, WHITELISTED), ERROR_ACCESS_DENIED);
        }

        internalContribution(
            _contributor,
            PricingStrategy(management.contractRegistry(CONTRACT_PRICING)).getCurrencyAmount(ethAmount)
        );
    }

    function internalContribution(
        address payable _contributor,
        uint256 _currencyAmount
    )
        internal
    {
        updateState();
        require(getState() == State.InCrowdsale, ERROR_ACCESS_DENIED);

        TokenAllocator allocator = TokenAllocator(
            management.contractRegistry(CONTRACT_ALLOCATOR)
        );

        uint256 tokensAvailable = allocator.tokensAvailable(tokensSold);

        uint256 tokens;
        uint256 tokensExcludingBonus;
        uint256 bonus;

        (tokens, tokensExcludingBonus, bonus) = PricingStrategy(
            management.contractRegistry(CONTRACT_PRICING)
        ).getTokens(
            _contributor,
            tokensAvailable,
            tokensSold,
            _currencyAmount,
            bonusProduced
        );

        preValidatePurchase(_contributor, tokens);

        allocator.allocate(_contributor, tokens, tokensSold);

        onContribution(
            _contributor,
            _currencyAmount,
            tokens,
            bonus
        );
    }

    function preValidatePurchase(
        address _beneficiary,
        uint256 _tokensAmount
    )
        internal
        view
    {
        require(_beneficiary != address(0), ERROR_WRONG_AMOUNT);
        require(_tokensAmount > 0, ERROR_WRONG_AMOUNT);
    }

    function onContribution(
        address payable _contributor,
        uint256 _currencyAmount,
        uint256 _tokens,
        uint256 _bonus
    ) internal {
        tokensSold = tokensSold.add(_tokens);
        bonusProduced = bonusProduced.add(_bonus);

        CrowdsaleAgent(
            management.contractRegistry(CONTRACT_AGENT)
        ).onContribution(
            _contributor,
            _currencyAmount,
            _tokens,
            _bonus
        );

        forwardFunds(_contributor);

        emit Contribution(
            _contributor,
            _currencyAmount,
            _tokens.sub(_bonus),
            _bonus
        );
    }

    function forwardFunds(address) internal
    requireContractExistsInRegistry(CONTRACT_FORWARDER)
    {
        if (msg.value > 0) {
            ContributionForwarder(
                management.contractRegistry(CONTRACT_FORWARDER)
            ).forward.value(msg.value)();
        }
    }
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

//pragma solidity ^0.5.0;
pragma solidity >=0.5 <0.7.17;

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

// File: @openzeppelin/contracts/token/ERC20/ERC20.sol

//pragma solidity ^0.5.0;
pragma solidity >=0.5 <0.7.17;




/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20Mintable}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`.`amount` is then deducted
     * from the caller's allowance.
     *
     * See {_burn} and {_approve}.
     */
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
    }
}

// File: @openzeppelin/contracts/access/Roles.sol

//pragma solidity ^0.5.0;
pragma solidity >=0.5 <0.7.17;

/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    /**
     * @dev Give an account access to this role.
     */
    function add(Role storage role, address account) internal {
        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    /**
     * @dev Remove an account's access to this role.
     */
    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    /**
     * @dev Check if an account has this role.
     * @return bool
     */
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}

// File: @openzeppelin/contracts/access/roles/MinterRole.sol

//pragma solidity ^0.5.0;
pragma solidity >=0.5 <0.7.17;



contract MinterRole is Context {
    using Roles for Roles.Role;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    Roles.Role private _minters;

    constructor () internal {
        _addMinter(_msgSender());
    }

    modifier onlyMinter() {
        require(isMinter(_msgSender()), "MinterRole: caller does not have the Minter role");
        _;
    }

    function isMinter(address account) public view returns (bool) {
        return _minters.has(account);
    }

    function addMinter(address account) public onlyMinter {
        _addMinter(account);
    }

    function renounceMinter() public {
        _removeMinter(_msgSender());
    }

    function _addMinter(address account) internal {
        _minters.add(account);
        emit MinterAdded(account);
    }

    function _removeMinter(address account) internal {
        _minters.remove(account);
        emit MinterRemoved(account);
    }
}

// File: @openzeppelin/contracts/token/ERC20/ERC20Mintable.sol

//pragma solidity ^0.5.0;
pragma solidity >=0.5 <0.7.17;



/**
 * @dev Extension of {ERC20} that adds a set of accounts with the {MinterRole},
 * which have permission to mint (create) new tokens as they see fit.
 *
 * At construction, the deployer of the contract is the only minter.
 */
contract ERC20Mintable is ERC20, MinterRole {
    /**
     * @dev See {ERC20-_mint}.
     *
     * Requirements:
     *
     * - the caller must have the {MinterRole}.
     */
    function mint(address account, uint256 amount) public onlyMinter returns (bool) {
        _mint(account, amount);
        return true;
    }
}

// File: contracts/allocator/MintableTokenAllocator.sol

//pragma solidity 0.5.17;
pragma solidity >=0.5 <0.7.17;




/// @title MintableTokenAllocator
/// @author Applicature
/// @notice Contract responsible for defining distribution logic of tokens.
/// @dev implementation
contract MintableTokenAllocator is TokenAllocator {

    constructor(uint256 _maxSupply, address _management)
        public
        TokenAllocator(_maxSupply, _management)
    {}

    /// @notice Check whether contract is initialised
    /// @return true if initialized
    function isInitialized() public view returns (bool) {
        return (
            super.isInitialized() &&
            hasPermission(address(this), CAN_MINT_TOKENS)
        );
    }


    function decreaseCap(uint256 _valueToSubtract)
        public
        requirePermission(CAN_INTERACT_WITH_ALLOCATOR)
        requireContractExistsInRegistry(CONTRACT_TOKEN)
    {
        require(
            maxSupply.sub(_valueToSubtract) >= ERC20Mintable(
                management.contractRegistry(CONTRACT_TOKEN)
            ).totalSupply(),
            ERROR_WRONG_AMOUNT
        );
        updateMaxSupply(maxSupply.sub(_valueToSubtract));
    }

    function internalAllocate(
        address _holder,
        uint256 _tokens
    )
        internal
        requireContractExistsInRegistry(CONTRACT_TOKEN)
        requirePermission(CAN_INTERACT_WITH_ALLOCATOR)
    {
        ERC20Mintable(management.contractRegistry(CONTRACT_TOKEN))
            .mint(_holder, _tokens);
    }

}

// File: contracts/LockupContract.sol

//pragma solidity 0.5.17;
pragma solidity >=0.5 <0.7.17;




contract LockupContract is Managed {
    using SafeMath for uint256;

    uint256 public constant PERCENT_ABS_MAX = 100;
    bool public isPostponedStart;
    uint256 public postponedStartDate;

    mapping(address => uint256[]) public lockedAllocationData;

    mapping(address => uint256) public manuallyLockedBalances;

    event Lock(address holderAddress, uint256 amount);

    constructor(address _management) public Managed(_management) {
        isPostponedStart = true;
    }

    function isTransferAllowed(
        address _address,
        uint256 _value,
        uint256 _time,
        uint256 _holderBalance
    )
    external
    view
    returns (bool)
    {
        uint256 unlockedBalance = getUnlockedBalance(
            _address,
            _time,
            _holderBalance
        );
        if (unlockedBalance >= _value) {
            return true;
        }
        return false;
    }

    function allocationLog(
        address _address,
        uint256 _amount,
        uint256 _startingAt,
        uint256 _lockPeriodInSeconds,
        uint256 _initialUnlockInPercent,
        uint256 _releasePeriodInSeconds
    )
        public
        requirePermission(CAN_LOCK_TOKENS)
    {
        lockedAllocationData[_address].push(_startingAt);
        if (_initialUnlockInPercent > 0) {
            _amount = _amount.mul(uint256(PERCENT_ABS_MAX)
                .sub(_initialUnlockInPercent)).div(PERCENT_ABS_MAX);
        }
        lockedAllocationData[_address].push(_amount);
        lockedAllocationData[_address].push(_lockPeriodInSeconds);
        lockedAllocationData[_address].push(_releasePeriodInSeconds);
        emit Lock(_address, _amount);
    }

    function getUnlockedBalance(
        address _address,
        uint256 _time,
        uint256 _holderBalance
    )
        public
        view
        returns (uint256)
    {
        uint256 blockedAmount = manuallyLockedBalances[_address];

        if (lockedAllocationData[_address].length == 0) {
            return _holderBalance.sub(blockedAmount);
        }
        uint256[] memory  addressLockupData = lockedAllocationData[_address];
        for (uint256 i = 0; i < addressLockupData.length / 4; i++) {
            uint256 lockedAt = addressLockupData[i.mul(4)];
            uint256 lockedBalance = addressLockupData[i.mul(4).add(1)];
            uint256 lockPeriodInSeconds = addressLockupData[i.mul(4).add(2)];
            uint256 _releasePeriodInSeconds = addressLockupData[
                i.mul(4).add(3)
            ];
            if (lockedAt == 0 && true == isPostponedStart) {
                if (postponedStartDate == 0) {
                    blockedAmount = blockedAmount.add(lockedBalance);
                    continue;
                }
                lockedAt = postponedStartDate;
            }
            if (lockedAt > _time) {
                blockedAmount = blockedAmount.add(lockedBalance);
                continue;
            }
            if (lockedAt.add(lockPeriodInSeconds) > _time) {
                if (lockedBalance == 0) {
                    blockedAmount = _holderBalance;
                    break;
                } else {
                    uint256 tokensUnlocked;
                    if (_releasePeriodInSeconds > 0) {
                        uint256 duration = (_time.sub(lockedAt))
                            .div(_releasePeriodInSeconds);
                        tokensUnlocked = lockedBalance.mul(duration)
                            .mul(_releasePeriodInSeconds)
                            .div(lockPeriodInSeconds);
                    }
                    blockedAmount = blockedAmount
                        .add(lockedBalance)
                        .sub(tokensUnlocked);
                }
            }
        }

        return _holderBalance.sub(blockedAmount);
    }

    function setManuallyLockedForAddress (
        address _holder,
        uint256 _balance
    )
        public
        requirePermission(CAN_LOCK_TOKENS)
    {
        manuallyLockedBalances[_holder] = _balance;
    }

    function setPostponedStartDate(uint256 _postponedStartDate)
        public
        requirePermission(CAN_LOCK_TOKENS)
    {
        postponedStartDate = _postponedStartDate;

    }
}

// File: contracts/CLIAllocator.sol

//pragma solidity 0.5.17;
pragma solidity >=0.5 <0.7.17;




contract CLIAllocator is MintableTokenAllocator {

    /* solium-disable */
    address public constant strategicPartners = 0xd5249aB86Ef7cE0651DF1b111E607f59950514c3;
    address public constant promotionsBounty = 0x38069DD2C6D385a7dE7dbB90eF74E23B12D124e3;
    address public constant shareholders = 0xA210F19b4C1c52dB213f88fdCA76fD83859052FA;
    address public constant advisors = 0x5d6019C130158FC00bc4Dc1edc949Fa84b8ad098;
    address public constant pharmaIndustrialTrials = 0x880574A5b701e017C254840063DFBd1f59dF9a15;
    address public constant managementTeam = 0x1e2Ce74Bc0a9A9fB2D6b3f630d585E0c00FF66B0;
    address public constant teamIncentive = 0xD4184B19170af014c595EF0b0321760d89918B95;
    address public constant publicSaleTokensHolder = 0x9ED362b5A8aF29CBC06548ba5C2f40978ca48Ec1;
    address public constant applicature = 0x63e638d15462037161003a6083A9c4AeD50f8F73;

    uint256 public constant strategicPartnersTokensAmount = 20000000e18;
    uint256 public constant promotionsBountyTokensAmount = 5200000e18;
    uint256 public constant shareholdersTokensAmount = 25000000e18;
    uint256 public constant advisorsTokensAmount = 8000000e18;
    uint256 public constant applicatureTokensAmount = 2000000e18;
    uint256 public constant pharmaIndustrialTrialsTokensAmount = 10000000e18;
    uint256 public constant managementTeamTokensAmount = 25000000e18;
    uint256 public constant teamIncentiveTokensAmount = 24000000e18;
    uint256 public constant publicSaleTokensAmount = 60000000e18;
    /* solium-enable */

    bool public isAllocated;

    constructor(uint256 _maxSupply, address _management)
        public
        MintableTokenAllocator(_maxSupply, _management)
    {

    }

    function increasePublicSaleCap(uint256 valueToAdd)
        external
        canCallOnlyRegisteredContract(CONTRACT_CROWDSALE)
    {
        internalAllocate(publicSaleTokensHolder, valueToAdd);
    }

    function unlockManuallyLockedBalances(address _holder)
        public
        requirePermission(CAN_LOCK_TOKENS)
    {
        LockupContract lockupContract = LockupContract(
            management.contractRegistry(CONTRACT_LOCKUP)
        );
        lockupContract.setManuallyLockedForAddress(
            _holder,
            0
        );
    }

    function allocateRequiredTokensToHolders() public {
        require(isAllocated == false, ERROR_NOT_AVAILABLE);
        isAllocated = true;
        allocateTokensWithSimpleLockUp();
        allocateTokensWithComplicatedLockup();
        allocateTokensWithManualUnlock();
        allocatePublicSale();
    }

    function allocatePublicSale() private {
        internalAllocate(publicSaleTokensHolder, publicSaleTokensAmount);
    }

    function allocateTokensWithSimpleLockUp() private {
        LockupContract lockupContract = LockupContract(
            management.contractRegistry(CONTRACT_LOCKUP)
        );
        internalAllocate(strategicPartners, strategicPartnersTokensAmount);

        internalAllocate(promotionsBounty, promotionsBountyTokensAmount);
        lockupContract.allocationLog(
            promotionsBounty,
            promotionsBountyTokensAmount,
            0,
            SIX_MONTHS,
            0,
            SIX_MONTHS
        );
        internalAllocate(advisors, advisorsTokensAmount);
        lockupContract.allocationLog(
            advisors,
            advisorsTokensAmount,
            0,
            SIX_MONTHS,
            0,
            SIX_MONTHS
        );
        internalAllocate(applicature, applicatureTokensAmount);
        // 25% each  6 months
        lockupContract.allocationLog(
            applicature,
            applicatureTokensAmount,
            0,
            SIX_MONTHS.mul(4),
            0,
            SIX_MONTHS
        );
    }

    function allocateTokensWithComplicatedLockup() private {
        LockupContract lockupContract = LockupContract(
            management.contractRegistry(CONTRACT_LOCKUP)
        );

        internalAllocate(shareholders, shareholdersTokensAmount);
        lockupContract.allocationLog(
            shareholders,
            shareholdersTokensAmount.div(5),
            0,
            SIX_MONTHS,
            0,
            SIX_MONTHS
        );
        lockupContract.allocationLog(
            shareholders,
            shareholdersTokensAmount.sub(shareholdersTokensAmount.div(5)),
            0,
            uint256(48).mul(MONTH_IN_SECONDS),
            0,
            YEAR_IN_SECONDS
        );

        internalAllocate(managementTeam, managementTeamTokensAmount);
        lockupContract.allocationLog(
            managementTeam,
            managementTeamTokensAmount.mul(2).div(5),
            0,
            SIX_MONTHS,
            50,
            SIX_MONTHS
        );
        lockupContract.allocationLog(
            managementTeam,
            managementTeamTokensAmount.sub(
                managementTeamTokensAmount.mul(2).div(5)
            ),
            0,
            uint256(36).mul(MONTH_IN_SECONDS),
            0,
            YEAR_IN_SECONDS
        );
    }

    function allocateTokensWithManualUnlock() private {
        LockupContract lockupContract = LockupContract(
            management.contractRegistry(CONTRACT_LOCKUP)
        );

        internalAllocate(
            pharmaIndustrialTrials,
            pharmaIndustrialTrialsTokensAmount
        );
        lockupContract.setManuallyLockedForAddress(
            pharmaIndustrialTrials,
            pharmaIndustrialTrialsTokensAmount
        );
        internalAllocate(teamIncentive, teamIncentiveTokensAmount);
        lockupContract.setManuallyLockedForAddress(
            teamIncentive,
            teamIncentiveTokensAmount
        );
    }
}

// File: @openzeppelin/contracts/token/ERC20/ERC20Detailed.sol

//pragma solidity ^0.5.0;
pragma solidity >=0.5 <0.7.17;


/**
 * @dev Optional functions from the ERC20 standard.
 */
contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for `name`, `symbol`, and `decimals`. All three of
     * these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}

// File: contracts/CLIToken.sol

//pragma solidity 0.5.17;
pragma solidity >=0.5 <0.7.17;







contract CLIToken is ERC20, ERC20Detailed, Managed {

    modifier requireUnlockedBalance(
        address _address,
        uint256 _value,
        uint256 _time,
        uint256 _holderBalance
    ) {

        require(
            LockupContract(
                management.contractRegistry(CONTRACT_LOCKUP)
            ).isTransferAllowed(
                _address,
                _value,
                _time,
                _holderBalance
            ),
            ERROR_NOT_AVAILABLE
        );
        _;
    }

    constructor(
        address _management
    )
        public
        ERC20Detailed("ClinTex", "CTI", 18)
        Managed(_management)
    {
        _mint(0x8FAE27b50457C10556C45798c34f73AE263282a6, 151000000000000000);
    }

    function mint(
        address _account,
        uint256 _amount
    )
        public
        requirePermission(CAN_MINT_TOKENS)
        canCallOnlyRegisteredContract(CONTRACT_ALLOCATOR)
        returns (bool)
    {
        require(
            _amount <= CLIAllocator(
                management.contractRegistry(CONTRACT_ALLOCATOR)
            ).tokensAvailable(totalSupply()),
            ERROR_WRONG_AMOUNT
        );
        _mint(_account, _amount);
        return true;
    }

    function transfer(
        address _to,
        uint256 _tokens
    )
        public
        requireUnlockedBalance(
            msg.sender,
            _tokens,
            block.timestamp,
            balanceOf(msg.sender)
        )
        returns (bool)
    {
        super.transfer(_to, _tokens);

        return true;
    }

    function transferFrom(
        address _holder,
        address _to,
        uint256 _tokens
    )
        public
        requireUnlockedBalance(
            _holder,
            _tokens,
            block.timestamp,
            balanceOf(_holder)
        )
        returns (bool)
    {
        super.transferFrom(_holder, _to, _tokens);

        return true;
    }

    function burn(uint256 value)
        public
        requirePermission(CAN_BURN_TOKENS)
        requireUnlockedBalance(
            msg.sender,
            value,
            block.timestamp,
            balanceOf(msg.sender)
        )
    {
        require(balanceOf(msg.sender) >= value, ERROR_WRONG_AMOUNT);
        super._burn(msg.sender, value);
    }
}

// File: contracts/CLIContribution.sol

//pragma solidity 0.5.17;
pragma solidity >=0.5 <0.7.17;




contract CLIContribution is ContributionForwarder {

    address payable public receiver;

    Contribution[] public contributions;

    struct Contribution {
        address payable contributor;
        uint256 weiAmount;
        uint256 currencyAmount;
        uint256 tokensAmount;
        uint256 timestamp;
        uint256 referralTokensSent;
    }

    constructor(
        address payable _receiver,
        address _management
    )
        public
        ContributionForwarder(_management)
    {
        receiver = _receiver;
    }

    function recordContribution(
        address payable _contributor,
        uint256 _currencyAmount,
        uint256 _etherAmount,
        uint256 _tokens,
        uint256 _referralTokens
    )
        external
        payable
        canCallOnlyRegisteredContract(CONTRACT_CROWDSALE)
        returns (uint256 id)
    {
        id = contributions.push(Contribution(
            _contributor,
            _etherAmount,
            _currencyAmount,
            _tokens,
            block.timestamp,
            _referralTokens
        )).sub(1);

    }

    function internalForward() internal {
        weiForwarded = weiForwarded.add(address(this).balance);
        receiver.transfer(address(this).balance);
    }

}

// File: contracts/CLIReferral.sol

//pragma solidity 0.5.17;
pragma solidity >=0.5 <0.7.17;






contract CLIReferral is Managed {

    uint256 public referralMaxSupply = 800000e18;
    uint256 public referralPercent = 4;
    uint256 public absPercentValue = 100;
    uint256 public referralTotalSupply;
    mapping (address => address) public referralToRefererRegistry;

    constructor(address _management) public Managed(_management) {}

    function registerRefererForAddress(
        address _referral,
        address _referrer
    )
        public
        requirePermission(CAN_SET_WHITELISTED)
    {
        require(
            referralToRefererRegistry[_referral] == address(0),
            ERROR_NOT_AVAILABLE
        );
        referralToRefererRegistry[_referral] = _referrer;
    }

    function allocate(
        address _referralAddress,
        uint256 _tokensPurchased
    )
        public
        requirePermission(CAN_ALLOCATE_REFERRAL_TOKENS)
        returns (uint256 allocatedTokens)
    {
        address referrer = referralToRefererRegistry[_referralAddress];

        allocatedTokens = getReferrerTokens(
            _referralAddress, _tokensPurchased
        );

        if (allocatedTokens == 0){
            return allocatedTokens;
        }
        require(
            referralTotalSupply.add(allocatedTokens) <= referralMaxSupply,
            ERROR_WRONG_AMOUNT
        );

        referralTotalSupply = referralTotalSupply.add(allocatedTokens);

        TokenAllocator(
            management.contractRegistry(CONTRACT_ALLOCATOR)
        ).allocate(
            referrer,
            allocatedTokens,
            CLIToken(management.contractRegistry(CONTRACT_TOKEN)).totalSupply()
        );
        // unlock initial 25% tokens
        // lock 25% tokens for 6 months
        LockupContract(
            management.contractRegistry(CONTRACT_LOCKUP)
        ).allocationLog(
            referrer,
            allocatedTokens.div(2),
            0,
            SIX_MONTHS,
            50,
            SIX_MONTHS
        );

        // lock 25% tokens for 12 months
        // lock 25% tokens for 24 months
        LockupContract(
            management.contractRegistry(CONTRACT_LOCKUP)
        ).allocationLog(
            referrer,
            allocatedTokens.sub(allocatedTokens.div(2)),
            0,
            uint256(24).mul(MONTH_IN_SECONDS),
            0,
            YEAR_IN_SECONDS
        );

    }

    function getReferrerTokens(
        address _referralAddress,
        uint256 _tokensPurchased
    )
        public
        view
        returns (uint256)
    {
        address referrer = referralToRefererRegistry[_referralAddress];
        if (referrer == address(0)) {
            return 0;
        }
        return _tokensPurchased.mul(referralPercent).div(absPercentValue);
    }
}

// File: contracts/CLICrowdsale.sol

//pragma solidity 0.5.17;
pragma solidity >=0.5 <0.7.17;








contract CLICrowdsale is CrowdsaleImpl {

    uint256 public constant safeAgreementThreshold = 100000e5;
    uint256 public seedMaxSupply = 20000000e18;

    uint256 public collectedCurrency;

    mapping (address => uint256) public contributedByUser;
    mapping (address => bool) public userSafeAgreementExist;
    address[] public userSafeAgreementsList;

    event Contribution(
        uint256 _id,
        address _contributor,
        uint256 _currencyAmount,
        uint256 _tokensExcludingBonus,
        uint256 _bonus
    );

    constructor(
        uint256 _startTime,
        uint256 _endTime,
        address _management
    )
        public
        CrowdsaleImpl(
            _startTime,
            _endTime,
            true,
            true,
            false,
            _management
        )
    {}

    // function is added to omit issue with fallback gas limits
    function buy()
        external
        payable
    {
        buyInternal(
            msg.sender,
            msg.value
        );
    }

    function updateState() public {
        (startDate, endDate) = CLIPricingStrategy(
            management.contractRegistry(CONTRACT_PRICING)
        ).getTierActualDates(tokensSold);

        super.updateState();
    }


    function discardUnsoldTokens() public {
        updateState();

        if (endDate < block.timestamp && false == finalized) {
            uint256 valueToSubtract = (seedMaxSupply.sub(tokensSold)).div(2);
            CLIAllocator allocatorContract = CLIAllocator(
                management.contractRegistry(CONTRACT_ALLOCATOR)
            );
            allocatorContract.decreaseCap(valueToSubtract);
            allocatorContract.increasePublicSaleCap(
                seedMaxSupply.sub(tokensSold).sub(valueToSubtract)
            );
            seedMaxSupply = tokensSold;
            finalized = true;
        }
    }

    function preValidatePurchase(
        address _beneficiary,
        uint256 _tokensAmount
    )
        internal
        view
    {
        super.preValidatePurchase(_beneficiary, _tokensAmount);
        require(
            tokensSold.add(_tokensAmount) <= seedMaxSupply,
            ERROR_WRONG_AMOUNT
        );
    }

    function onContribution(
        address payable _contributor,
        uint256 _currencyAmount,
        uint256 _tokens,
        uint256
    ) internal {
        tokensSold = tokensSold.add(_tokens);
        collectedCurrency = collectedCurrency.add(_currencyAmount);
        contributedByUser[_contributor] = contributedByUser[_contributor]
            .add(_currencyAmount);
        if (
            !userSafeAgreementExist[_contributor] &&
            _currencyAmount >= safeAgreementThreshold
        ) {
            userSafeAgreementExist[_contributor] = true;
            userSafeAgreementsList.push(_contributor);
        }

        uint256 referralTokens = CLIReferral(
            management.contractRegistry(CONTRACT_REFERRAL)
        ).allocate(_contributor, _tokens);

        lockPurchasedTokens(
            _contributor,
            _tokens
        );

        uint256 contributionId = CLIContribution(
            management.contractRegistry(CONTRACT_FORWARDER)
        ).recordContribution(
            _contributor,
            _currencyAmount,
            msg.value,
            _tokens,
            referralTokens
        );
        forwardFunds(_contributor);

        emit Contribution(
            contributionId,
            _contributor,
            _currencyAmount,
            _tokens,
            0
        );
    }

    function lockPurchasedTokens(
        address _contributor,
        uint256 _tokens
    )
    private
    {
        // unlock initial 25% tokens
        // lock 25% tokens for 6 months
        LockupContract(
            management.contractRegistry(CONTRACT_LOCKUP)
        ).allocationLog(
            _contributor,
            _tokens.div(2),
            0,
            SIX_MONTHS,
            50,
            SIX_MONTHS
        );

        // lock 25% tokens for 12 months
        // lock 25% tokens for 24 months
        LockupContract(
            management.contractRegistry(CONTRACT_LOCKUP)
        ).allocationLog(
            _contributor,
            _tokens.sub(_tokens.div(2)),
            0,
            uint256(24).mul(MONTH_IN_SECONDS),
            0,
            YEAR_IN_SECONDS
        );

    }
}

// File: contracts/CLIStats.sol

//pragma solidity 0.5.17;
pragma solidity >=0.5 <0.7.17;







contract CLIStats is Managed {

    uint256 public constant STATS_DATA_LENGTH = 8;
    uint256 public constant CURRENCY_CONTR_DATA_LENGTH = 3;
    uint256 public constant TIER_DATA_LENGTH = 13;

    constructor(address _management) public Managed(_management) {}

    function getTokens(
        uint256 _currencyAmount
    )
        public
        view
        returns (uint256 tokens, uint256 tokensExcludingBonus, uint256 bonus)
    {
        uint256 tokensSold = CLICrowdsale(
            address(management.contractRegistry(CONTRACT_CROWDSALE))
        ).tokensSold();

        return CLIPricingStrategy(
            management.contractRegistry(CONTRACT_PRICING)
        ).getTokensWithoutRestrictions(_currencyAmount, tokensSold);
    }

    function getWeis(
        uint256 _tokenAmount
    )
        public
        view
        returns (uint256 totalWeiAmount, uint256)
    {
        uint256 tokensSold = CLICrowdsale(
            management.contractRegistry(CONTRACT_CROWDSALE)
        ).tokensSold();

        return CLIPricingStrategy(
            management.contractRegistry(CONTRACT_PRICING)
        ).getWeis(0, tokensSold, _tokenAmount);
    }

    function getStats(
        uint256[7] memory _ethPerCurrency
    )
        public
        view
        returns (
            uint256[] memory stats,
            uint256[] memory tiersData,
            uint256[] memory currencyContr //tokensPerEachCurrency
        )
    {
        stats = getStatsData();
        tiersData = getTiersData();
        currencyContr = getCurrencyContrData(_ethPerCurrency, stats[3]);
    }

    function getTiersData()
        public
        view
        returns (uint256[] memory)
    {
        CLIPricingStrategy pricing = CLIPricingStrategy(
            management.contractRegistry(CONTRACT_PRICING)
        );

        uint256 tiersAmount = pricing.getTiersAmount();
        uint256 tierElements = pricing.TIER_ELEMENTS_AMOUNT();

        uint256[] memory tiers = pricing.getArrayOfTiers();
        uint256[] memory tiersData = new uint256[](
            tiersAmount.mul(TIER_DATA_LENGTH)
        );

        uint256 j = 0;
        for (uint256 i = 0; i < tiers.length; i += tierElements) {
            tiersData[j++] = tiers[i] > 0 ? uint256(1e23)
                .div(tiers[i]) : 0;// tokenInUSD;
            tiersData[j++] = 0;// tokenInWei;
            tiersData[j++] = uint256(tiers[i.add(1)]);// maxTokensCollected;
            tiersData[j++] = CLICrowdsale(
                management.contractRegistry(CONTRACT_CROWDSALE)
            ).tokensSold();// soldTierTokens;
            tiersData[j++] = uint256(tiers[i.add(3)]);// discountPercents;
            tiersData[j++] = uint256(tiers[i.add(4)]);// bonusPercents;
            tiersData[j++] = uint256(tiers[i.add(5)]);// minInvestInCurrency;
            tiersData[j++] = 0;// minInvestInWei;
            tiersData[j++] = uint256(tiers[i.add(6)]);// maxInvestInCurrency;
            tiersData[j++] = 0;// maxInvestInWei;
            tiersData[j++] = uint256(tiers[i.add(7)]);// startDate;
            tiersData[j++] = uint256(tiers[i.add(8)]);// endDate;
            tiersData[j++] = uint256(1);// tierType;
        }

        return tiersData;
    }

    function getStatsData()
        public
        view
        returns (uint256[] memory)
    {
        TokenAllocator allocator = TokenAllocator(
            management.contractRegistry(CONTRACT_ALLOCATOR)
        );
        CLICrowdsale crowdsale = CLICrowdsale(
            management.contractRegistry(CONTRACT_CROWDSALE)
        );
        CLIPricingStrategy pricing = CLIPricingStrategy(
            management.contractRegistry(CONTRACT_PRICING)
        );

        uint256[] memory stats = new uint256[](STATS_DATA_LENGTH);
        stats[0] = allocator.maxSupply();
        stats[1] = CLIToken(
            management.contractRegistry(CONTRACT_TOKEN)
        ).totalSupply();
        stats[2] = allocator.tokensAvailable(stats[1]);
        stats[3] = crowdsale.tokensSold();
        stats[4] = uint256(crowdsale.currentState());
        stats[5] = pricing.getActualTierIndex(stats[3]);
        stats[6] = pricing.getTierUnsoldTokens(stats[3]);
        stats[7] = pricing.getMinEtherInvest(stats[5]);

        return stats;
    }

    function getCurrencyContrData(
        uint256[7] memory _ethPerCurrency,
        uint256 _tokensSold
    )
        public
        view
        returns (uint256[] memory)
    {
        uint256[] memory currencyContr = new uint256[](
            _ethPerCurrency.length.mul(CURRENCY_CONTR_DATA_LENGTH)
        );

        CLIPricingStrategy pricing = CLIPricingStrategy(
            management.contractRegistry(CONTRACT_PRICING)
        );

        uint256 j = 0;
        for (uint256 i = 0; i < _ethPerCurrency.length; i++) {
            (
                currencyContr[j++],
                currencyContr[j++],
                currencyContr[j++]
            ) = pricing.getTokensWithoutRestrictions(
                _ethPerCurrency[i], _tokensSold
            );
        }

        return currencyContr;
    }

}
