/**
 *Submitted for verification at Etherscan.io on 2020-09-15
*/

// File: contracts/InterFaces/IAuctionRegistery.sol

//pragma solidity ^0.5.9;
pragma solidity >=0.5 <0.7.17;

contract AuctionRegisteryContracts {
    bytes32 internal constant MAIN_TOKEN = "MAIN_TOKEN";
    bytes32 internal constant ETN_TOKEN = "ETN_TOKEN";
    bytes32 internal constant STOCK_TOKEN = "STOCK_TOKEN";
    bytes32 internal constant WHITE_LIST = "WHITE_LIST";
    bytes32 internal constant AUCTION = "AUCTION";
    bytes32 internal constant AUCTION_PROTECTION = "AUCTION_PROTECTION";
    bytes32 internal constant LIQUIDITY = "LIQUIDITY";
    bytes32 internal constant CURRENCY = "CURRENCY";
    bytes32 internal constant VAULT = "VAULT";
    bytes32 internal constant CONTRIBUTION_TRIGGER = "CONTRIBUTION_TRIGGER";
    bytes32 internal constant COMPANY_FUND_WALLET = "COMPANY_FUND_WALLET";
    bytes32 internal constant SMART_SWAP = "SMART_SWAP";
    bytes32 internal constant SMART_SWAP_P2P = "SMART_SWAP_P2P";
    bytes32 internal constant ESCROW = "ESCROW";
}

interface IAuctionRegistery {
    function getAddressOf(bytes32 _contractName)
        external
        view
        returns (address payable);
}

// File: contracts/Auction/AuctionStorage.sol

//pragma solidity ^0.5.9;
pragma solidity >=0.5 <0.7.17;


contract AuctionStorage {
    IAuctionRegistery public contractsRegistry;

    address payable public whiteListAddress;
    address payable public smartSwapAddress;
    address payable public currencyPricesAddress;
    address payable public vaultAddress;
    address payable public mainTokenAddress;
    address payable public liquidityAddress;
    address payable public companyFundWalletAddress;
    address payable public escrowAddress;
    address payable public auctionProtectionAddress;

    uint256 public constant PRICE_NOMINATOR = 10**9;

    uint256 public constant DECIMAL_NOMINATOR = 10**18;
    
    uint256 public constant PERCENT_NOMINATOR = 10**6;

    // allowed contarct limit the contribution
    uint256 public maxContributionAllowed;
    // managment fee to run auction cut from basesupply
    uint256 public managementFee;
    // staking percentage
    uint256 public staking;
    // fund that will be locked in contacrt
    uint256 public downSideProtectionRatio;
    // Fund goes to companyWallet
    uint256 public fundWalletRatio;
    // if contribution reach above yesterdayContribution groupBonus multiplyer
    uint256 public groupBonusRatio;
    // user neeed this amount of mainToken to contribute
    uint256 public mainTokenRatio;

    //from which day mainTokenCheck start
    uint256 public mainTokencheckDay;
    // current auctionday
    uint256 public auctionDay;
    // current totalContribution
    uint256 public totalContribution;
    // today total contributiton
    uint256 public todayContribution;
    // yesterday's contribution
    uint256 public yesterdayContribution;
    // allowed max contribution in a day
    uint256 public allowMaxContribution;
    // yesterday token Supply
    uint256 public yesterdaySupply;
    // today token supply
    uint256 public todaySupply;

    uint256 public averageDay;

    // address how much invested by them in auciton till date
    mapping(address => uint256) public userTotalFund;

    // how much token recived by address in auciton till date
    mapping(address => uint256) public userTotalReturnToken;

    // day wise supply (groupBounus+coreSupply)
    mapping(uint256 => uint256) public dayWiseSupply;

    // day wise  coreSupply
    mapping(uint256 => uint256) public dayWiseSupplyCore;

    // day wise bonusSupply
    mapping(uint256 => uint256) public dayWiseSupplyBonus;

    // daywise contribution
    mapping(uint256 => uint256) public dayWiseContribution;

    // daywise markertPrice
    mapping(uint256 => uint256) public dayWiseMarketPrice;

    // dayWise downsideProtection Ratio
    mapping(uint256 => uint256) public dayWiseDownSideProtectionRatio;

    // address wise contribution each day
    mapping(uint256 => mapping(address => uint256))
        public walletDayWiseContribution;

    // daywise contribution
    mapping(uint256 => mapping(address => uint256))
        public mainTokenCheckDayWise;

    // return index of user for bonus
    mapping(uint256 => uint256) public indexReturn;

    // day wiser five top contributor
    mapping(uint256 => mapping(uint256 => address)) public topFiveContributor;

    //contributor Index
    mapping(uint256 => mapping(address => uint256)) public topContributorIndex;

    // check if daywise token disturbuted
    mapping(uint256 => mapping(address => bool)) public returnToken;

    uint256 public MIN_AUCTION_END_TIME; //epoch

    uint256 public LAST_AUCTION_START;

    uint256 public INTERVAL;
    
    uint256 public currentMarketPrice;
    
    event FundAdded(
        uint256 indexed _auctionDayId,
        uint256 _todayContribution,
        address indexed _fundBy,
        address indexed _fundToken,
        uint256 _fundAmount,
        uint256 _fundValue,
        uint256 _totalFund,
        uint256 _marketPrice
    );

    event FundAddedBehalf(address indexed _caller, address indexed _recipient);

    event AuctionEnded(
        uint256 indexed _auctionDayId,
        uint256 _todaySupply,
        uint256 _yesterdaySupply,
        uint256 _todayContribution,
        uint256 _yesterdayContribution,
        uint256 _totalContribution,
        uint256 _maxContributionAllowed,
        uint256 _tokenPrice,
        uint256 _tokenMarketPrice
    );

    event FundDeposited(address _token, address indexed _from, uint256 _amount);

    event TokenDistrubuted(
        address indexed _whom,
        uint256 indexed dayId,
        uint256 _totalToken,
        uint256 lockedToken,
        uint256 _userToken
    );

}

// File: contracts/common/Constant.sol

//pragma solidity ^0.5.9;
pragma solidity >=0.5 <0.7.17;

contract Constant {
    string constant ERR_CONTRACT_SELF_ADDRESS = "ERR_CONTRACT_SELF_ADDRESS";

    string constant ERR_ZERO_ADDRESS = "ERR_ZERO_ADDRESS";

    string constant ERR_NOT_OWN_ADDRESS = "ERR_NOT_OWN_ADDRESS";

    string constant ERR_VALUE_IS_ZERO = "ERR_VALUE_IS_ZERO";

    string constant ERR_SAME_ADDRESS = "ERR_SAME_ADDRESS";

    string constant ERR_AUTHORIZED_ADDRESS_ONLY = "ERR_AUTHORIZED_ADDRESS_ONLY";

    modifier notOwnAddress(address _which) {
        require(msg.sender != _which, ERR_NOT_OWN_ADDRESS);
        _;
    }

    // validates an address is not zero
    modifier notZeroAddress(address _which) {
        require(_which != address(0), ERR_ZERO_ADDRESS);
        _;
    }

    // verifies that the address is different than this contract address
    modifier notThisAddress(address _which) {
        require(_which != address(this), ERR_CONTRACT_SELF_ADDRESS);
        _;
    }

    modifier notZeroValue(uint256 _value) {
        require(_value > 0, ERR_VALUE_IS_ZERO);
        _;
    }
}

// File: contracts/common/ProxyOwnable.sol

//pragma solidity ^0.5.9;
pragma solidity >=0.5 <0.7.17;



contract ProxyOwnable is Constant {
    
    address public primaryOwner;

    address public authorityAddress;

    address public newAuthorityAddress;

    address public systemAddress;
    
    bool public isOwnerInitialize = false;

    event OwnershipTransferred(
        string ownerType,
        address indexed previousOwner,
        address indexed newOwner
    );
    
    event AuthorityAddressChnageCall(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev The Ownable constructor sets the `primaryOwner` and `systemAddress` and '_multisigAddress'
     * account.
     */

    function initializeOwner(
        address _primaryOwner,
        address _systemAddress,
        address _authorityAddress
    ) internal notZeroAddress(_primaryOwner) notZeroAddress(_systemAddress) notZeroAddress(_authorityAddress) {
        
        require(!isOwnerInitialize,"ERR_OWNER_INTIALIZED_ALREADY");
        
        require(_primaryOwner != _systemAddress, ERR_SAME_ADDRESS);
        
        require(_systemAddress != _authorityAddress, ERR_SAME_ADDRESS);
        
        require(_primaryOwner != _authorityAddress, ERR_SAME_ADDRESS);
        
        primaryOwner = _primaryOwner;
        systemAddress = _systemAddress;
        authorityAddress = _authorityAddress;
        isOwnerInitialize = true;
    }

    modifier onlyOwner() {
        require(msg.sender == primaryOwner, ERR_AUTHORIZED_ADDRESS_ONLY);
        _;
    }

    modifier onlySystem() {
        require(msg.sender == systemAddress, ERR_AUTHORIZED_ADDRESS_ONLY);
        _;
    }

    modifier onlyOneOfOnwer() {
        require(
            msg.sender == primaryOwner || msg.sender == systemAddress,
            ERR_AUTHORIZED_ADDRESS_ONLY
        );
        _;
    }

    modifier onlyAuthorized() {
        require(msg.sender == authorityAddress, ERR_AUTHORIZED_ADDRESS_ONLY);
        _;
    }

    /**
     * @dev change primary ownership governance 
     */
    function changePrimaryOwner()
        public
        onlyOwner()
        returns (bool)
    {
        emit OwnershipTransferred("PRIMARY_OWNER", primaryOwner, authorityAddress);
        primaryOwner = authorityAddress;
        return true;
    }

    /**
     * @dev change system address
     * @param _which The address to which is new system address
     */
    function changeSystemAddress(address _which)
        public
        onlyAuthorized()
        notThisAddress(_which)
        notZeroAddress(_which)
        returns (bool)
    {
        require(
            _which != systemAddress &&
                _which != authorityAddress &&
                _which != primaryOwner,
            ERR_SAME_ADDRESS
        );
        emit OwnershipTransferred("SYSTEM_ADDRESS", systemAddress, _which);
        systemAddress = _which;
        return true;
    }

    /**
     * @dev change system address
     * @param _which The address to which is new Authority address
     */
    function changeAuthorityAddress(address _which)
        public
        onlyAuthorized()
        notZeroAddress(_which)
        returns (bool)
    {
        require(
            _which != systemAddress &&
                _which != authorityAddress,
            ERR_SAME_ADDRESS
        );
        newAuthorityAddress = _which;
        return true;
    }

    function acceptAuthorityAddress() public returns (bool) {
        require(msg.sender == newAuthorityAddress, ERR_AUTHORIZED_ADDRESS_ONLY);
        emit OwnershipTransferred(
            "AUTHORITY_ADDRESS",
            authorityAddress,
            newAuthorityAddress
        );
        authorityAddress = newAuthorityAddress;
        newAuthorityAddress = address(0);
        return true;
    }
}

// File: contracts/common/SafeMath.sol

//pragma solidity ^0.5.9;
pragma solidity >=0.5 <0.7.17;

contract SafeMath {
    function safeMul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function safeDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        return c;
    }

    function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function safeAdd(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    function safeExponent(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        uint256 result;
        assembly {
            result := exp(a, b)
        }
        return result;
    }

    // calculates a^(1/n) to dp decimal places
    // maxIts bounds the number of iterations performed
    function nthRoot(
        uint256 _a,
        uint256 _n,
        uint256 _dp,
        uint256 _maxIts
    ) internal pure returns (uint256) {
        assert(_n > 1);

        // The scale factor is a crude way to turn everything into integer calcs.
        // Actually do (a * (10 ^ ((dp + 1) * n))) ^ (1/n)
        // We calculate to one extra dp and round at the end
        uint256 one = 10**(1 + _dp);
        uint256 a0 = one**_n * _a;

        // Initial guess: 1.0
        uint256 xNew = one;
        uint256 x;

        uint256 iter = 0;
        while (xNew != x && iter < _maxIts) {
            x = xNew;
            uint256 t0 = x**(_n - 1);
            if (x * t0 > a0) {
                xNew = x - (x - a0 / t0) / _n;
            } else {
                xNew = x + (a0 / t0 - x) / _n;
            }
            ++iter;
        }

        // Round to nearest in the last dp.
        return (xNew + 5) / 10;
    }
}

// File: contracts/InterFaces/IERC20Token.sol

//pragma solidity ^0.5.9;
pragma solidity >=0.5 <0.7.17;


interface IERC20Token {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address _owner) external view returns (uint256);

    function allowance(address _owner, address _spender)
        external
        view
        returns (uint256);

    function transfer(address _to, uint256 _value) external returns (bool);

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool);

    function approve(address _spender, uint256 _value) external returns (bool);
}

// File: contracts/common/TokenTransfer.sol

//pragma solidity ^0.5.9;
pragma solidity >=0.5 <0.7.17;


contract TokenTransfer {
    function ensureTransferFrom(
        IERC20Token _token,
        address _from,
        address _to,
        uint256 _amount
    ) internal {
        if (_from == address(this))
            require(_token.transfer(_to, _amount), "ERR_TOKEN_TRANSFER_FAIL");
        else
            require(
                _token.transferFrom(_from, _to, _amount),
                "ERR_TOKEN_TRANSFER_FAIL"
            );
    }

    function approveTransferFrom(
        IERC20Token _token,
        address _spender,
        uint256 _amount
    ) internal {
        require(_token.approve(_spender, _amount), "ERR_TOKEN_APPROVAL_FAIL");
    }
}

// File: contracts/Proxy/IRegistry.sol

//pragma solidity ^0.5.9;
pragma solidity >=0.5 <0.7.17;

/**
 * @title IRegistry
 * @dev This contract represents the interface of a registry contract
 */
interface IRegistry {
    /**
     * @dev This event will be emitted every time a new proxy is created
     * @param proxy representing the address of the proxy created
     */
    event ProxyCreated(address proxy);

    /**
     * @dev This event will be emitted every time a new implementation is registered
     * @param version representing the version name of the registered implementation
     * @param implementation representing the address of the registered implementation
     */
    event VersionAdded(uint256 version, address implementation);

    /**
     * @dev Registers a new version with its implementation address
     * @param version representing the version name of the new implementation to be registered
     * @param implementation representing the address of the new implementation to be registered
     */
    function addVersion(uint256  version, address implementation)
        external;

    /**
     * @dev Tells the address of the implementation for a given version
     * @param version to query the implementation of
     * @return address of the implementation registered for the given version
     */
    function getVersion(uint256 version)
        external
        view
        returns (address);
}

// File: contracts/Proxy/Proxy.sol

//pragma solidity ^0.5.9;
pragma solidity >=0.5 <0.7.17;

/**
 * @title Proxy
 * @dev Gives the possibility to delegate any call to a foreign implementation.
 */
contract Proxy {
    /**
     * @dev Tells the address of the implementation where every call will be delegated.
     * @return address of the implementation to which it will be delegated
     */
    function implementation() public view returns (address);

    /**
     * @dev Fallback function allowing to perform a delegatecall to the given implementation.
     * This function will return whatever the implementation call returns
     */
    
    function() external payable {
        address _impl = implementation();
        require(_impl != address(0),"ERR_IMPLEMENTEION_ZERO");

        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())
            let result := delegatecall(gas(), _impl, ptr, calldatasize(), 0, 0)
            let size := returndatasize()
            returndatacopy(ptr, 0, size)

            switch result
                case 0 {
                    revert(ptr, size)
                }
                default {
                    return(ptr, size)
                }
        }  
    }
    
    
    
    
}

// File: contracts/Proxy/UpgradeabilityStorage.sol

//pragma solidity ^0.5.9;
pragma solidity >=0.5 <0.7.17;



/**
 * @title UpgradeabilityStorage
 * @dev This contract holds all the necessary state variables to support the upgrade functionality
 */
contract UpgradeabilityStorage is Proxy {
    // Versions registry
    IRegistry public registry;

    // Address of the current implementation
    address internal _implementation;

    /**
     * @dev Tells the address of the current implementation
     * @return address of the current implementation
     */
    function implementation() public view returns (address) {
        return _implementation;
    }
}

// File: contracts/Proxy/Upgradeable.sol

//pragma solidity ^0.5.9;
pragma solidity >=0.5 <0.7.17;



/**
 * @title Upgradeable
 * @dev This contract holds all the minimum required functionality for a behavior to be upgradeable.
 * This means, required state variables for owned upgradeability purpose and simple initialization validation.
 */
contract Upgradeable is UpgradeabilityStorage {
    /**
     * @dev Validates the caller is the versions registry.
     * THIS FUNCTION SHOULD BE OVERRIDDEN CALLING SUPER
     */
    function initialize() public view {
        require(msg.sender == address(registry),"ERR_ONLY_REGISTRERY_CAN_CALL");
    }
}

// File: contracts/InterFaces/IContributionTrigger.sol

//pragma solidity ^0.5.9;
pragma solidity >=0.5 <0.7.17;


interface IContributionTrigger {
    function depositeToken(
        IERC20Token _token,
        address _from,
        uint256 _amount
    ) external returns (bool);

    function contributeTowardLiquidity(uint256 _amount)
        external
        returns (uint256);

    function transferTokenLiquidity(
        IERC20Token _token,
        address _reciver,
        uint256 _amount
    ) external returns (bool);
}

// File: contracts/InterFaces/ICurrencyPrices.sol

//pragma solidity ^0.5.9;
pragma solidity >=0.5 <0.7.17;

interface ICurrencyPrices {
    function getCurrencyPrice(address _which) external view returns (uint256);
}

// File: contracts/InterFaces/IAuctionLiquidity.sol

//pragma solidity ^0.5.9;
pragma solidity >=0.5 <0.7.17;


interface IAuctionLiquidity {
    function contributeWithEther() external payable returns (uint256);

    function auctionEnded() external returns (bool);

    function contributeTowardMainReserve() external returns (uint256);
}

// File: contracts/InterFaces/ITokenVault.sol

//pragma solidity ^0.5.9;
pragma solidity >=0.5 <0.7.17;


interface ITokenVault {
    function depositeToken(
        IERC20Token _token,
        address _from,
        uint256 _amount
    ) external returns (bool);

    function directTransfer(
        address _token,
        address _to,
        uint256 amount
    ) external returns (bool);

    function transferEther(address payable _to, uint256 amount)
        external
        returns (bool);
}

// File: contracts/InterFaces/IToken.sol

//pragma solidity ^0.5.9;
pragma solidity >=0.5 <0.7.17;

interface IToken {
    function mintTokens(uint256 _amount) external returns (bool);

    function buyTokens(address _fromToken, uint256 _amount)
        external
        returns (uint256);

    function burn(uint256 _value) external returns (bool);

    function lockToken(
        address _which,
        uint256 _amount,
        uint256 _locktime
    ) external returns (bool);
}

// File: contracts/InterFaces/IWhiteList.sol

//pragma solidity ^0.5.9;
pragma solidity >=0.5 <0.7.17;

interface IWhiteList {
    function address_belongs(address _who) external view returns (address);

    function isWhiteListed(address _who) external view returns (bool);

    function isAllowedInAuction(address _which) external view returns (bool);

    function isAddressByPassed(address _which) external view returns (bool);

    function isExchangeAddress(address _which) external view returns (bool);

    function main_isTransferAllowed(
        address _msgSender,
        address _from,
        address _to
    ) external view returns (bool);

    function etn_isTransferAllowed(
        address _msgSender,
        address _from,
        address _to
    ) external view returns (bool);

    function stock_isTransferAllowed(
        address _msgSender,
        address _from,
        address _to
    ) external view returns (bool);

    function addWalletBehalfExchange(address _mainWallet, address _subWallet)
        external
        returns (bool);

    function main_isReceiveAllowed(address user) external view returns (bool);

    function etn_isReceiveAllowed(address user) external view returns (bool);

    function stock_isReceiveAllowed(address user) external view returns (bool);
}

// File: contracts/InterFaces/IEscrow.sol

//pragma solidity ^0.5.9;
pragma solidity >=0.5 <0.7.17;

interface IEscrow {
    function depositFee(uint256 value) external returns (bool);
}

// File: contracts/InterFaces/IAuctionProtection.sol

//pragma solidity ^0.5.9;
pragma solidity >=0.5 <0.7.17;


interface IAuctionProtection {
    function lockEther(uint256 _auctionDay,address _which)
        external
        payable
        returns (bool);
    
    function stackFund(uint256 _amount)
        external
        returns (bool);
        
    function depositToken(
        uint256 _auctionDay,
        address _which,
        uint256 _amount
    ) external returns (bool);
    
    function unLockTokens() external returns (bool);
}

// File: contracts/Auction/Auction.sol

//pragma solidity ^0.5.9;
pragma solidity >=0.5 <0.7.17;
















interface AuctionInitializeInterface {
    function initialize(
        uint256 _startTime,
        uint256 _minAuctionTime,
        uint256 _interval,
        uint256 _mainTokenCheckDay,
        address _primaryOwner,
        address _systemAddress,
        address _multisigAddress,
        address _registryaddress
    ) external;
}

contract RegisteryAuction is ProxyOwnable, AuctionRegisteryContracts,AuctionStorage {
    

    function updateRegistery(address _address)
        external
        onlyAuthorized()
        notZeroAddress(_address)
        returns (bool)
    {
        contractsRegistry = IAuctionRegistery(_address);
        _updateAddresses();
        return true;
    }
    
    
    /**@dev updates the address from the registry contract*/

    function getAddressOf(bytes32 _contractName)
        internal
        view
        returns (address payable)
    {
        return contractsRegistry.getAddressOf(_contractName);
    }

    /**@dev updates all the address from the registry contract
    this decision was made to save gas that occurs from calling an external view function */

    function _updateAddresses() internal {
        whiteListAddress = getAddressOf(WHITE_LIST);
        smartSwapAddress = getAddressOf(SMART_SWAP);
        currencyPricesAddress = getAddressOf(CURRENCY);
        vaultAddress = getAddressOf(VAULT);
        mainTokenAddress = getAddressOf(MAIN_TOKEN);
        liquidityAddress = getAddressOf(LIQUIDITY);
        companyFundWalletAddress = getAddressOf(COMPANY_FUND_WALLET);
        escrowAddress = getAddressOf(ESCROW);
        auctionProtectionAddress = getAddressOf(AUCTION_PROTECTION);

    }

    function updateAddresses() external returns (bool) {
        _updateAddresses();
        return true;
    }
}



contract AuctionUtils is RegisteryAuction{
    
    
     function initializeStorage() internal {
        auctionDay = 1;
        totalContribution = 2500000 * PRICE_NOMINATOR;
        yesterdayContribution = 500 * PRICE_NOMINATOR;
        allowMaxContribution = 500 * PRICE_NOMINATOR;
        todaySupply = 50000 * DECIMAL_NOMINATOR;
        maxContributionAllowed = 150;
        managementFee = 2;
        staking = 1;
        downSideProtectionRatio = 90;
        fundWalletRatio = 90;
        groupBonusRatio = 2;
        mainTokenRatio = 100;
        averageDay = 10;
    }

    function setGroupBonusRatio(uint256 _groupBonusRatio)
        external
        onlyOwner()
        returns (bool)
    {
        groupBonusRatio = _groupBonusRatio;
        return true;
    }

    function setDownSideProtectionRatio(uint256 _ratio)
        external
        onlyOwner()
        returns (bool)
    {
        require(_ratio < 100, "ERR_SHOULD_BE_LESS_THAN_100");
        downSideProtectionRatio = _ratio;
        return true;
    }

    function setfundWalletRatio(uint256 _ratio)
        external
        onlyOwner()
        returns (bool)
    {
        require(_ratio < 100, "ERR_SHOULD_BE_LESS_THAN_100");
        fundWalletRatio = _ratio;
        return true;
    }

    function setMainTokenRatio(uint256 _ratio)
        external
        onlyOwner()
        returns (bool)
    {
        mainTokenRatio = _ratio;
        return true;
    }

    function setMainTokenCheckDay(uint256 _mainTokencheckDay)
        external
        onlyOwner()
        returns (bool)
    {
        mainTokencheckDay = _mainTokencheckDay;
        return true;
    }

    function setMaxContributionAllowed(uint256 _maxContributionAllowed)
        external
        onlyOwner()
        returns (bool)
    {
        maxContributionAllowed = _maxContributionAllowed;
        return true;
    }

    function setstakingPercent(uint256 _staking)
        external
        onlyOwner()
        returns (bool)
    {
        staking = _staking;
        return true;
    }
    
    function setAverageDays(uint256 _averageDay)
        external
        onlyOwner()
        returns (bool)
    {
        averageDay = _averageDay;
        return true;
    }
    
}



contract AuctionFormula is SafeMath, TokenTransfer {
    
    // calculate Funds On each day to see how much the user receives
    // split between  _returnAmount totalAmount which the user receives
    // _userAmount is which user get other token is locked
    function calcuateAuctionTokenDistrubution(
        uint256 dayWiseContributionByWallet,
        uint256 dayWiseSupplyCore,
        uint256 dayWiseSupplyBonus,
        uint256 dayWiseContribution,
        uint256 downSideProtectionRatio
    ) internal pure returns (uint256, uint256) {
        uint256 _dayWiseSupplyCore = safeDiv(
            safeMul(dayWiseSupplyCore, dayWiseContributionByWallet),
            dayWiseContribution
        );

        uint256 _dayWiseSupplyBonus = 0;
        if (dayWiseSupplyBonus > 0)
            _dayWiseSupplyBonus = safeDiv(
                safeMul(dayWiseSupplyBonus, dayWiseContributionByWallet),
                dayWiseContribution
            );
        uint256 _returnAmount = safeAdd(
            _dayWiseSupplyCore,
            _dayWiseSupplyBonus
        );

        // user receives only 10% - downSideProtectionRatio(90) fund receives the other 90% which is locked
        uint256 _userAmount = safeDiv(
            safeMul(_dayWiseSupplyCore, safeSub(100, downSideProtectionRatio)),
            100
        );

        return (_returnAmount, _userAmount);
    }

    
    function calculateNewSupply(
        uint256 todayContribution,
        uint256 tokenPrice,
        uint256 decimal
    ) internal pure returns (uint256) {
        return
            safeDiv(
                safeMul(todayContribution, safeExponent(10, decimal)),
                tokenPrice
            );
    }

    function calculateSupplyPercent(uint256 _supply, uint256 _percent)
        internal
        pure
        returns (uint256)
    {
        uint256 _tempSupply = safeDiv(
            safeMul(_supply, 100),
            safeSub(100, _percent)
        );
        uint256 _managementFee = safeSub(_tempSupply, _supply);
        return _managementFee;
    }
}


contract IndividualBonus is AuctionFormula,AuctionUtils {
    
    function updateIndividualBonusRatio(
        uint256 X1,
        uint256 X2,
        uint256 X3,
        uint256 X4,
        uint256 X5
    ) external onlyAuthorized() returns (bool) {
        indexReturn[1] = X1;
        indexReturn[2] = X2;
        indexReturn[3] = X3;
        indexReturn[4] = X4;
        indexReturn[5] = X5;
        return true;
    }

    function _compareForGroupBonus(address _from) internal {
        address contributor;
        uint256 topContributor;
        bool replaced = false;
        address replaceWith;


            uint256 contributionByUser
         = walletDayWiseContribution[auctionDay][_from];


        uint256 smallestContributionByUser
         = walletDayWiseContribution[auctionDay][topFiveContributor[auctionDay][5]];
        
        if (contributionByUser > smallestContributionByUser) {
            
            for (uint256 x = 1; x <= 5; x++) {
                contributor = topFiveContributor[auctionDay][x];
                topContributor = walletDayWiseContribution[auctionDay][contributor];
                if (
                    contributionByUser >= topContributor && replaced == false
                ) {
                    if (
                        contributor != _from &&
                        contributionByUser > topContributor
                    ) {
                        topFiveContributor[auctionDay][x] = _from;
                        topContributorIndex[auctionDay][_from] = x;
                        replaceWith = contributor;
                        replaced = true;
                    } else if (contributor == _from) {
                        replaceWith = contributor;
                        replaced = true;
                    }
                } else if (replaced && replaceWith != _from) {
                    topFiveContributor[auctionDay][x] = replaceWith;
                    topContributorIndex[auctionDay][replaceWith] = x;
                    replaceWith = contributor;
                }
            }
            
            if (replaceWith != address(0) && replaceWith != _from)
                topContributorIndex[auctionDay][replaceWith] = 0;
        }
    }

    function calculateBouns(uint256 _auctionDay, address _from)
        external
        view
        returns (uint256)
    {
        return _calculateBouns(_auctionDay, _from);
    }

    function _calculateBouns(uint256 _auctionDay, address _from)
        internal
        view
        returns (uint256)
    {
        return indexReturn[topContributorIndex[_auctionDay][_from]];
    }
}

contract AuctionFundCollector is IndividualBonus {
    
    // check before contribution
    function _checkContribution(address _from) internal view returns (bool) {
        require(
            IWhiteList(whiteListAddress).isAllowedInAuction(_from),
            "ERR_NOT_ALLOWED_IN_AUCTION"
        );
        return true;
    }

    function mainTokenCheck(address _from, uint256 _contributedAmount)
        internal
        returns (bool)
    {
        IERC20Token mainToken = IERC20Token(mainTokenAddress);
        
        uint256 _mainTokenPrice = currentMarketPrice;

        require(_mainTokenPrice > 0, "ERR_TOKEN_PRICE_NOT_SET");
        
        uint256 lockToken = safeDiv(
            safeMul(safeAdd(
                mainTokenCheckDayWise[auctionDay][_from],
                _contributedAmount
            ),safeExponent(10, mainToken.decimals()))
            ,
            _mainTokenPrice
        );
        
        require(
            mainToken.balanceOf(_from) >= safeDiv(safeMul(lockToken,mainTokenRatio),100),
            "ERR_USER_DOES_NOT_HAVE_EQUAL_BALANCE"
        );
        
        IToken(mainTokenAddress).lockToken(_from, lockToken, now);
        return true;
    }

    // check whether the user sends more funds, if yes
    // revert whatever user send extra revert back to user
    function calculateFund(
        address _token,
        uint256 _amount,
        uint256 _decimal
    ) internal view returns (uint256,uint256) {
        
        uint256 _currencyPrices = ICurrencyPrices(currencyPricesAddress)
            .getCurrencyPrice(_token);

        require(_currencyPrices > 0, "ERR_TOKEN_PRICE_NOT_SET");

        uint256 _contributedAmount = safeDiv(
            safeMul(_amount, _currencyPrices),
            safeExponent(10, _decimal)
        );

        if (
            safeAdd(todayContribution, _contributedAmount) >
            allowMaxContribution
        ) {
            uint256 extraAmount = safeSub(
                safeAdd(todayContribution, _contributedAmount),
                allowMaxContribution
            );
            return
                (safeDiv(
                    safeMul(extraAmount, safeExponent(10, _decimal)),
                    _currencyPrices
                ),_currencyPrices);
        }
        return (0,_currencyPrices);
    }

    function fundAdded(
        address _token,
        uint256 _amount,
        uint256 _decimal,
        address _caller,
        address _recipient,
        uint256 _currencyPrice
    ) internal returns (bool){
        

        uint256 _contributedAmount = safeDiv(
            safeMul(_amount, _currencyPrice),
            safeExponent(10, _decimal)
        );
        
        // Here we check caller balance 
        if (auctionDay >= mainTokencheckDay) {
            mainTokenCheck(_caller, _contributedAmount);
        }

        todayContribution = safeAdd(todayContribution, _contributedAmount);
        
        mainTokenCheckDayWise[auctionDay][_caller] = safeAdd(
            walletDayWiseContribution[auctionDay][_caller],
            _contributedAmount
        );
        
        walletDayWiseContribution[auctionDay][_recipient] = safeAdd(
            walletDayWiseContribution[auctionDay][_recipient],
            _contributedAmount
        );

        userTotalFund[_recipient] = safeAdd(
            userTotalFund[_recipient],
            _contributedAmount
        );

        dayWiseContribution[auctionDay] = safeAdd(
            dayWiseContribution[auctionDay],
            _contributedAmount
        );

        _compareForGroupBonus(_recipient);

        emit FundAdded(
            auctionDay,
            todayContribution,
            _recipient,
            _token,
            _amount,
            _contributedAmount,
            walletDayWiseContribution[auctionDay][_recipient],
            currentMarketPrice
        );
        
        if(_caller != _recipient){
            emit FundAddedBehalf(_caller,_recipient);
        }
            
        return true;
    }

    function _contributeWithEther(uint256 _value,address _caller,address payable _recipient)
        internal
        returns (bool)
    {
        (uint256 returnAmount,uint256 _currencyPrice) = calculateFund(address(0), _value, 18);
        
        // transfer Back Extra Amount To the _recipient
        if (returnAmount != 0) {
            _recipient.transfer(returnAmount);
            _value = safeSub(_value, returnAmount);
        }
        
        uint256 downSideAmount = safeDiv(safeMul(_value,dayWiseDownSideProtectionRatio[auctionDay]),100);
        
        IAuctionProtection(auctionProtectionAddress).lockEther.value(downSideAmount)(auctionDay,_recipient);
        
        return fundAdded(address(0), _value, 18, _caller , _recipient,_currencyPrice);
    }

    // we only start with ether we dont need any token right now
    function contributeWithEther() external payable returns (bool) {
        
        require(_checkContribution(msg.sender));
        
        return _contributeWithEther(msg.value,msg.sender,msg.sender);
    }
    
    // This Method For Exchange 
    // Exchange invests on behalf of their users
    // so we check caller maintoken balance 
    function contributeWithEtherBehalf(address payable _whom) external payable returns (bool) {
        
        require(IWhiteList(whiteListAddress).isExchangeAddress(msg.sender),ERR_AUTHORIZED_ADDRESS_ONLY);
        
        if(IWhiteList(whiteListAddress).address_belongs(_whom) == address(0)){
            IWhiteList(whiteListAddress).addWalletBehalfExchange(msg.sender,_whom);
        }
        
        require(IWhiteList(whiteListAddress).address_belongs(_whom) == msg.sender);
        
        return _contributeWithEther(msg.value,msg.sender,_whom);
    }
    
    function updateCurrentMarketPrice() external returns (bool){
        currentMarketPrice = ICurrencyPrices(currencyPricesAddress)
            .getCurrencyPrice(mainTokenAddress);
        
        return true;
    }
    
    
    function pushEthToLiquidity() external returns(bool){
        return _pushEthToLiquidity();
    }
    
    function _pushEthToLiquidity() internal returns(bool){
        
        uint256 pushToLiquidity = address(this).balance;
        
        if(pushToLiquidity > 0){
            
            uint256 realEstateAmount = safeDiv(safeMul(pushToLiquidity,fundWalletRatio),100);                
            companyFundWalletAddress.transfer(realEstateAmount); 
            uint256 reserveAmount = safeSub(pushToLiquidity,realEstateAmount);
            currentMarketPrice = IAuctionLiquidity(liquidityAddress)
             .contributeWithEther
             .value(reserveAmount)();
             
        }
        return true;
    }
    
}

contract Auction is Upgradeable, AuctionFundCollector, AuctionInitializeInterface {
    

    function changeTimings(uint256 _flag, uint256 _time)
        external
        onlyAuthorized()
        returns (bool)
    {
        if (_flag == 1) MIN_AUCTION_END_TIME = _time;
        else if (_flag == 2) LAST_AUCTION_START == _time;
        else if (_flag == 3) INTERVAL == _time;
        return true;
    }

    function initialize(
        uint256 _startTime,
        uint256 _minAuctionTime,
        uint256 _interval,
        uint256 _mainTokenCheckDay,
        address _primaryOwner,
        address _systemAddress,
        address _multisigAddress,
        address _registryaddress
    ) public {
        super.initialize();
        initializeOwner(_primaryOwner, _systemAddress, _multisigAddress);
        contractsRegistry = IAuctionRegistery(_registryaddress);
        initializeStorage();
        _updateAddresses();
        dayWiseDownSideProtectionRatio[auctionDay] = downSideProtectionRatio;
        LAST_AUCTION_START = _startTime;
        MIN_AUCTION_END_TIME = _minAuctionTime;
        INTERVAL = _interval;
        mainTokencheckDay = _mainTokenCheckDay;
        indexReturn[1] = 50;
        indexReturn[2] = 40;
        indexReturn[3] = 30;
        indexReturn[4] = 20;
        indexReturn[5] = 10;
    }


    function getAuctionDetails()
        external
        view
        returns (
            uint256 _todaySupply,
            uint256 _yesterdaySupply,
            uint256 _todayContribution,
            uint256 _yesterdayContribution,
            uint256 _totalContribution,
            uint256 _maxContributionAllowed,
            uint256 _marketPrice
        )
    {
        uint256 _mainTokenPrice = ICurrencyPrices(currencyPricesAddress)
            .getCurrencyPrice(mainTokenAddress);

        return (
            todaySupply,
            yesterdaySupply,
            todayContribution,
            yesterdayContribution,
            totalContribution,
            allowMaxContribution,
            _mainTokenPrice
        );
    }

    // any one can call this method
    
    function auctionEnd() external returns (bool) {
        require(
            now >= safeAdd(LAST_AUCTION_START, MIN_AUCTION_END_TIME),
            "ERR_MIN_TIME_IS_NOT_OVER"
        );

        _pushEthToLiquidity();
        
        uint256 _mainTokenPrice = currentMarketPrice;
        
        if (todayContribution == 0) {
            
            uint256 _ethPrice = ICurrencyPrices(currencyPricesAddress)
                .getCurrencyPrice(address(0));

            uint256 mainReserveAmount = IAuctionLiquidity(liquidityAddress)
                .contributeTowardMainReserve();

            uint256 mainReserveAmountUsd = safeDiv(
                safeMul(mainReserveAmount, _ethPrice),
                DECIMAL_NOMINATOR
            );

            dayWiseContribution[auctionDay] = mainReserveAmountUsd;

            todayContribution = mainReserveAmountUsd;

            walletDayWiseContribution[auctionDay][vaultAddress] = mainReserveAmountUsd;

            _mainTokenPrice = ICurrencyPrices(currencyPricesAddress)
                .getCurrencyPrice(mainTokenAddress);

            _compareForGroupBonus(vaultAddress);

            emit FundAdded(
                auctionDay,
                todayContribution,
                vaultAddress,
                address(0),
                mainReserveAmount,
                mainReserveAmountUsd,
                mainReserveAmountUsd,
                _mainTokenPrice
            );
        }

        uint256 bonusSupply = 0;

        allowMaxContribution = safeDiv(
            safeMul(todayContribution, maxContributionAllowed),
            100
        );

        if (todayContribution > yesterdayContribution) {
            uint256 _groupBonusRatio = safeMul(
                safeDiv(
                    safeMul(todayContribution, DECIMAL_NOMINATOR),
                    yesterdayContribution
                ),
                groupBonusRatio
            );

            bonusSupply = safeSub(
                safeDiv(
                    safeMul(todaySupply, _groupBonusRatio),
                    DECIMAL_NOMINATOR
                ),
                todaySupply
            );
        }

        uint256 _avgDays = averageDay;
        uint256 _avgInvestment = 0;

        if (auctionDay < 11 && auctionDay > 1) {
            _avgDays = safeSub(auctionDay, 1);
        }

        if (auctionDay > 1) {
            for (uint32 tempX = 1; tempX <= _avgDays; tempX++) {
                _avgInvestment = safeAdd(
                    _avgInvestment,
                    dayWiseContribution[safeSub(auctionDay, tempX)]
                );
            }

            _avgInvestment = safeDiv(
                safeMul(
                    safeDiv(_avgInvestment, _avgDays),
                    maxContributionAllowed
                ),
                100
            );
        }

        if (_avgInvestment > allowMaxContribution) {
            allowMaxContribution = _avgInvestment;
        }

        dayWiseSupplyCore[auctionDay] = todaySupply;
        dayWiseSupplyBonus[auctionDay] = bonusSupply;
        dayWiseSupply[auctionDay] = safeAdd(todaySupply, bonusSupply);

        uint256 stakingAmount = safeDiv(
            safeMul(dayWiseSupply[auctionDay], staking),
            100
        );
        uint256 fee = calculateSupplyPercent(
            safeAdd(stakingAmount, dayWiseSupply[auctionDay]),
            managementFee
        );

        IToken(mainTokenAddress).mintTokens(safeAdd(fee, stakingAmount));
        
        approveTransferFrom(
            IERC20Token(mainTokenAddress),
            escrowAddress,
            fee
        );
        
        IEscrow(escrowAddress).depositFee(fee);
        
        approveTransferFrom(
            IERC20Token(mainTokenAddress),
            auctionProtectionAddress,
            stakingAmount
        );
        
        IAuctionProtection(auctionProtectionAddress).stackFund(stakingAmount);
    
        uint256 _tokenPrice = safeDiv(
            safeMul(todayContribution, DECIMAL_NOMINATOR),
            dayWiseSupply[auctionDay]
        );

        dayWiseMarketPrice[auctionDay] = _mainTokenPrice;

        todaySupply = safeDiv(
            safeMul(todayContribution, DECIMAL_NOMINATOR),
            _mainTokenPrice
        );

        totalContribution = safeAdd(totalContribution, todayContribution);
        yesterdaySupply = dayWiseSupply[auctionDay];
        yesterdayContribution = todayContribution;
        auctionDay = safeAdd(auctionDay, 1);
        IAuctionLiquidity(liquidityAddress).auctionEnded();
        dayWiseDownSideProtectionRatio[auctionDay] = downSideProtectionRatio;
        LAST_AUCTION_START = safeAdd(LAST_AUCTION_START, INTERVAL);
        todayContribution = 0;
        emit AuctionEnded(
            auctionDay,
            todaySupply,
            yesterdaySupply,
            todayContribution,
            yesterdayContribution,
            totalContribution,
            allowMaxContribution,
            _tokenPrice,
            _mainTokenPrice
        );

        return true;
    }

    function disturbuteTokenInternal(uint256 dayId, address _which)
        internal
        returns (bool)
    {
        require(
            returnToken[dayId][_which] == false,
            "ERR_ALREADY_TOKEN_DISTBUTED"
        );


            uint256 dayWiseContributionByWallet
         = walletDayWiseContribution[dayId][_which];

        uint256 dayWiseContribution = dayWiseContribution[dayId];

        (
            uint256 returnAmount,
            uint256 _userAmount
        ) = calcuateAuctionTokenDistrubution(
            dayWiseContributionByWallet,
            dayWiseSupplyCore[dayId],
            dayWiseSupplyBonus[dayId],
            dayWiseContribution,
            dayWiseDownSideProtectionRatio[dayId]
        );

        uint256 _percent = _calculateBouns(dayId, _which);

        uint256 newReturnAmount = 0;

        uint256 fee = 0;

        if (_percent > 0) {
            newReturnAmount = safeDiv(safeMul(returnAmount, _percent), 100);
            fee = calculateSupplyPercent(newReturnAmount, managementFee);
        }

        newReturnAmount = safeAdd(returnAmount, newReturnAmount);
        IToken(mainTokenAddress).mintTokens(safeAdd(newReturnAmount, fee));

        // here the last auction is checked because the user can invest after auction starts
        IToken(mainTokenAddress).lockToken(_which, 0, LAST_AUCTION_START);

        approveTransferFrom(
            IERC20Token(mainTokenAddress),
            escrowAddress,
            fee
        );
        IEscrow(escrowAddress).depositFee(fee);
        
        ensureTransferFrom(
            IERC20Token(mainTokenAddress),
            address(this),
            _which,
            _userAmount
        );
        
        approveTransferFrom(
            IERC20Token(mainTokenAddress),
            auctionProtectionAddress,
            safeSub(newReturnAmount, _userAmount)
        );
    
        IAuctionProtection(auctionProtectionAddress).depositToken(dayId,_which,safeSub(newReturnAmount, _userAmount));
        
        returnToken[dayId][_which] = true;
        
        emit TokenDistrubuted(
            _which,
            dayId,
            newReturnAmount,
            safeSub(newReturnAmount, _userAmount),
            _userAmount
        );
        return true;
    }
    
    // anyone can call this method 
    function disturbuteTokens(uint256 dayId, address[] calldata _which)
        external
        returns (bool)
    {
        require(dayId < auctionDay, "ERR_AUCTION_DAY");
        for (uint256 tempX = 0; tempX < _which.length; tempX++) {
            if (returnToken[dayId][_which[tempX]] == false)
                disturbuteTokenInternal(dayId, _which[tempX]);
        }
        return true;
    }

    function disturbuteTokens(uint256 dayId) external returns (bool) {
        require(dayId < auctionDay, "ERR_AUCTION_DAY");
        return disturbuteTokenInternal(dayId, msg.sender);
    }
    
    

    //In case if there is other tokens into contract
    function returnFund(
        IERC20Token _token,
        uint256 _value,
        address payable _which
    ) external onlyAuthorized() returns (bool) {
        
        require(address(_token) != mainTokenAddress ,"ERR_CANT_TAKE_OUT_MAIN_TOKEN");
        ensureTransferFrom(_token, address(this), _which, _value);
        return true;
        
    }

    function() external payable {
         revert("ERR_CAN'T_FORCE_ETH");
    }
    
}
