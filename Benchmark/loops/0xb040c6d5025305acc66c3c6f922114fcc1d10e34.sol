/**
 *Submitted for verification at Etherscan.io on 2020-09-09
*/

// File: contracts/pricing/PricingStrategy.sol

//pragma solidity^0.6.17;
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
