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

// File: contracts/WhiteList/WhiteListStorage.sol

//pragma solidity ^0.5.9;
pragma solidity >=0.5 <0.7.17;


contract WhiteListStorage {
    
    IAuctionRegistery public contractsRegistry;
    
    address payable public auctionAddress; 
    
    
    struct UserDetails {
        uint256 flags; // bitmap, where each bit correspondent to some properties (additional flags can be added in future).
        uint256 maxWallets;
        address[] wallets;
    }

    // Whitelist rules
    struct ReceivingRule {
        uint256 mask; // bit-mask to select bits which will be checked by this rule
        uint256 condition; // bit-sets which indicate the require bit status.
        // for example, if rule require that the 1 and 4 bits should be '1' and 2 bit should be '0', then mask = 0x16 (10110 binary) and condition = 0x12 (10010 binary). I.e. '1' is set for bit which should be '1' and '0' - for bit which should be '0'
    }

    // Restriction rules
    struct TransferringRule {
        uint256 from_mask; // bit-mask to select bits which will be checked by this rule
        uint256 from_condition; // bit-sets which indicate the require bit status.
        uint256 to_mask; // bit-mask to select bits which will be checked by this rule
        uint256 to_condition; // bit-sets which indicate the require bit status.
        // if rule 'from' return 'true' and rule 'to' is true - the transfer disallowed.
        // if rule 'from' return 'false' then don't check rule 'to'.
    }

    mapping(address => address) public address_belongs;
    mapping(address => UserDetails) public user_details;

    //Made this decision so that we can reuse the code

    //0:main
    //1:etn
    //2:stock
    mapping(uint8 => ReceivingRule) public tokenToReceivingRule;
    mapping(uint8 => TransferringRule[]) public tokenToTransferringRuleArray;

    //timestamp when hold back days are over
    mapping(uint8 => uint256) public tokenToHoldBackDaysTimeStamp;
    //timestamp when token matures
    mapping(uint8 => uint256) public tokenToMaturityDaysTimeStamp;
    
    
    uint256 public constant KYC = 1 << 0; //0x01
    uint256 public constant AML = 1 << 1; //0x02
    uint256 public constant ACCREDIATED_INVESTOR = 1 << 2;
    uint256 public constant QUALIFIED_INVESTOR = 1 << 3;
    uint256 public constant RETAIL_INVESTOR = 1 << 4;
    uint256 public constant DECENTRALIZE_EXCHANGE = 1 << 5; // wallet of decentralize exchanges
    uint256 public constant CENTRALIZE_EXCHANGE = 1 << 6; // wallet of centralize exchanges
    uint256 public constant IS_ALLOWED_ETN = 1 << 7;
    uint256 public constant IS_ALLOWED_STOCK = 1 << 8;
    uint256 public constant FROM_USA = 1 << 9;
    uint256 public constant FROM_CHINA = 1 << 10;
    uint256 public constant FROM_EU = 1 << 11;
    uint256 public constant IS_BYPASSED = 1 << 12;
    uint256 public constant BANCOR_ADDRESS = 1 << 13;
    uint256 public constant IS_ALLOWED_AUCTION = 1 << 14;
    
    event AccountWhiteListed(address indexed which, uint256 flags);
    event WalletAdded(address indexed from, address indexed which);
    event WalletRemoved(address indexed from, address indexed which);
    event FlagsChanged(address indexed which, uint256 flags);

    
    
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

// File: contracts/WhiteList/WhiteList.sol

//pragma solidity ^0.5.9;
pragma solidity >=0.5 <0.7.17;






interface WhiteListInitializeInterface {
    function initialize(
        address _primaryOwner,
        address _systemAddress,
        address _authorityAddress,
        uint256 _mainHoldBackDays,
        uint256 _etnHoldBackDays,
        uint256 _stockHoldBackDays,
        uint256 _mainMaturityDays,
        uint256 _etnMaturityDays,
        uint256 _stockMaturityDays,
        address _registryaddress
    ) external;
}

contract RegisteryWhiteList is ProxyOwnable,WhiteListStorage,AuctionRegisteryContracts {
    

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
        auctionAddress = getAddressOf(AUCTION);
    }

     function updateAddresses() external returns (bool) {
        _updateAddresses();
        return true;
    }
}


contract WhiteList is
    Upgradeable,
    ProxyOwnable,
    RegisteryWhiteList,
    SafeMath,
    WhiteListInitializeInterface
{
    
    /**@dev converts _days into unix timestamp _days from now*/
    function convertDaysToTimeStamp(uint256 _days)
        internal
        view
        returns (uint256)
    {
        //no need to check if days are set to zero see _isTransferAllowed L#327
        if (_days == 0) return 0;
        uint256 duration = safeMul(86400, _days);
        return safeAdd(now, duration);
    }

    /**@dev since its a proxy contract this is what will work as a constructor*/
    function initialize(
        address _primaryOwner,
        address _systemAddress,
        address _authorityAddress,
        uint256 _mainHoldBackDays,
        uint256 _etnHoldBackDays,
        uint256 _stockHoldBackDays,
        uint256 _mainMaturityDays,
        uint256 _etnMaturityDays,
        uint256 _stockMaturityDays,
        address _registryaddress
    ) public {
        super.initialize();

        initializeOwner(_primaryOwner, _systemAddress, _authorityAddress);
        contractsRegistry = IAuctionRegistery(_registryaddress);
        
        tokenToMaturityDaysTimeStamp[0] = convertDaysToTimeStamp(
            _mainMaturityDays
        );
        tokenToMaturityDaysTimeStamp[1] = convertDaysToTimeStamp(
            _etnMaturityDays
        );
        tokenToMaturityDaysTimeStamp[2] = convertDaysToTimeStamp(
            _stockMaturityDays
        );

        tokenToHoldBackDaysTimeStamp[0] = convertDaysToTimeStamp(
            _mainHoldBackDays
        );
        tokenToHoldBackDaysTimeStamp[1] = convertDaysToTimeStamp(
            _etnHoldBackDays
        );
        tokenToHoldBackDaysTimeStamp[2] = convertDaysToTimeStamp(
            _stockHoldBackDays
        );
        
    }

    /**@dev whitelists an address*/
    function whiteListAccount(
        address _which,
        uint256 _flags,
        uint256 _maxWallets
    ) internal returns (bool) {
        UserDetails storage details = user_details[_which];
        details.flags = _flags;
        details.maxWallets = _maxWallets;
        address_belongs[_which] = _which;
        emit AccountWhiteListed(_which, _flags);
        return true;
    }

    /**@dev checks if address is bancor's*/
    function _isBancorAddress(address _which) internal view returns (bool) {
        address primaryAddress = address_belongs[_which];
        uint256 flags = user_details[primaryAddress].flags;
        return _checkRule(flags, BANCOR_ADDRESS, BANCOR_ADDRESS);
    }

    /**@dev checks if address is bypassed*/
    function _isAddressByPassed(address _which) internal view returns (bool) {
        address primaryAddress = address_belongs[_which];
        uint256 flags = user_details[primaryAddress].flags;
        return _checkRule(flags, IS_BYPASSED, IS_BYPASSED);
    }

    /**@dev checks if address is bypassed*/
    function isAddressByPassed(address _which) external view returns (bool) {
        return _isAddressByPassed(_which);
    }

    /**@dev returns if address is whitelisted*/
    function _isWhiteListed(address _which) internal view returns (bool) {
        if (address_belongs[_which] == address(0)) return false;
        return true;
    }

    /**@dev returns if address is whitelisted*/
    function isWhiteListed(address _which) external view returns (bool) {
        return _isWhiteListed(_which);
    }

    /**@dev checks if address is allowed in auction or not */
    function isAllowedInAuction(address _which) external view returns (bool) {
        address primaryAddress = address_belongs[_which];
        uint256 flags = user_details[primaryAddress].flags;
        return _checkRule(flags, IS_ALLOWED_AUCTION, IS_ALLOWED_AUCTION);
    }

    

    /**@dev checks if address is allowed in auction or not */
    function checkRule(address _which, uint256 _condition)
        external
        view
        returns (bool)
    {
        address primaryAddress = address_belongs[_which];
        uint256 flags = user_details[primaryAddress].flags;
        return _checkRule(flags, _condition, _condition);
    }

    /**@dev whitelists an address*/
    function addNewWallet(
        address _which,
        uint256 _flags,
        uint256 _maxWallets
    ) public onlySystem() notZeroAddress(_which) returns (bool) {
        require(!_isWhiteListed(_which), "ERR_ACTION_NOT_ALLOWED");
        return whiteListAccount(_which, _flags, _maxWallets);
    }
    
    
    /**@dev whitelists an address*/
    function isExchangeAddress(address _which) public view returns (bool) {
        address primaryAddress = address_belongs[_which];
        uint256 flags = user_details[primaryAddress].flags;
        return _checkRule(flags,CENTRALIZE_EXCHANGE, CENTRALIZE_EXCHANGE);
    }
    

    /**@dev updates the maximum wallets allowed for a primary whitelisted address*/
    function updateMaxWallet(address _which, uint256 _maxWallets)
        public
        onlyOwner
        returns (bool)
    {
        require(_isWhiteListed(_which), ERR_AUTHORIZED_ADDRESS_ONLY);
        UserDetails storage details = user_details[_which];
        details.maxWallets = _maxWallets;
        return true;
    }

    function _addMoreWallets(address _from,address _which) internal returns(bool){
        
        require(
            address_belongs[_which] == address(0),
            ERR_AUTHORIZED_ADDRESS_ONLY
        );
        address sender = _from;
        address primaryAddress = address_belongs[sender];
        require(
            _isWhiteListed(primaryAddress) && sender == primaryAddress,
            ERR_AUTHORIZED_ADDRESS_ONLY
        );

        UserDetails storage details = user_details[primaryAddress];
        require(
            details.maxWallets > details.wallets.length,
            "ERR_MAXIMUM_WALLET_LIMIT"
        );

        address_belongs[_which] = primaryAddress;
        details.wallets.push(_which);
        emit WalletAdded(primaryAddress, _which);
        return true;
        
    }

    /**@dev allows primary whitelisted address to add wallet address controlled by them(reverts if maximum wallets is reached)*/
    
    function addMoreWallets(address _which)
        public
        notZeroAddress(_which)
        returns (bool)
    {
        return _addMoreWallets(msg.sender,_which);
    }
    
    
    
    function addWalletBehalfExchange(address _mainWallet,address _subWallet)
        public
        notZeroAddress(_subWallet)
        returns (bool)
    {   
        require(auctionAddress == msg.sender,"ERR_ONLY_AUCTION_ADDRESS_ALLOWED");
        return _addMoreWallets(_mainWallet,_subWallet);
    }


    /**@dev allows system to chage flags associated with an address*/
    function changeFlags(address _which, uint256 _flags)
        public
        onlySystem()
        notZeroAddress(_which)
        returns (bool)
    {
        require(_isWhiteListed(_which), "ERR_ACTION_NOT_ALLOWED");
        address primaryAddress = address_belongs[_which];
        user_details[primaryAddress].flags = _flags;
        emit FlagsChanged(_which, _flags);
        return true;
    }

    /**@dev checks condition
    @param _flags on which conditions are being checked on
    @param _mask the bits we care about in a conditions
    @param _condition the pattern of bits which should be exactly same in _flags to be true*/
    function _checkRule(
        uint256 _flags,
        uint256 _mask,
        uint256 _condition
    ) internal pure returns (bool) {
        uint256 flags = _flags & _mask;
        flags = flags ^ _condition;
        if (flags == 0) return true;
        return false;
    }

    /**@dev adds ReceivingRule of the token*/
    function _addReceivingRule(
        uint256 _mask,
        uint256 _condition,
        uint8 _token
    ) internal {
        tokenToReceivingRule[_token] = ReceivingRule(_mask, _condition);
    }

    /**@dev adds transferring rule
    if from has from_conditions bits set(i.e. is from usa) and to has to_condition bits set(i.e. is from china) then we don't allow*/
    function _addTransferringRule(
        uint256 from_mask,
        uint256 from_condition,
        uint256 to_mask,
        uint256 to_condition,
        uint8 token
    ) internal {
        tokenToTransferringRuleArray[token].push(
            TransferringRule(from_mask, from_condition, to_mask, to_condition)
        );
    }

    function _removeTransferingRule(uint256 _index, uint8 _token) internal {

            TransferringRule[] storage transferringRules
         = tokenToTransferringRuleArray[_token];

        require(_index < transferringRules.length, "CHECK_ARRAY_INDEX");

        transferringRules[_index] = transferringRules[safeSub(
            transferringRules.length,
            1
        )]; //replace with last element
        delete (transferringRules[safeSub(transferringRules.length, 1)]); //delete the last element
        transferringRules.length = safeSub(transferringRules.length, 1);
    }

    /**@dev Check, if receiver is whitelisted (has all necessary flags). Require to pass all rules in the set*/
    function _isReceiveAllowed(address user, uint8 token)
        internal
        view
        returns (bool)
    {
        address investor = address_belongs[user];
        require(investor != address(0), "ERR_TRANSFER_CHECK_WHITELIST");
        uint256 flags = user_details[investor].flags;
        bool result;
        result = _checkRule(
            flags,
            tokenToReceivingRule[token].mask,
            tokenToReceivingRule[token].condition
        );
        if (!result) return false; // if rule don't passed - receiving token disallowed.
        return true;
    }

    /**@dev checks if transfer is allowed with according transferringRules of a token*/
    function _isTransferAllowed(
        address _msgSender,
        address _from,
        address _to,
        uint8 token
    ) internal view returns (bool) {
        address to = address_belongs[_to];
        address msgSender = address_belongs[_msgSender];
        bool result;

        //If transfer is happening to a bypassed address then check nothing
        if (_isAddressByPassed(to)) {
            return true;
        }
        //If a byPassed Address calls a transfer or transferFrom function then just check if _to is whitelisted and return
        if (_isAddressByPassed(msgSender)) {
            result = _isWhiteListed(to);
            return result;
        }
        //Added to make sure that bancor addresses transfer to bypassed addresses only
        //if a bancor address calls a transfer or transferFrom function then return true only if to is Bypassed a

        if (_isBancorAddress(msgSender)) {
            if (_isBancorAddress(to))
                return _isBancorAddress(_from) || _isAddressByPassed(_from);
            else if (_isAddressByPassed(to)) return true;
            else return false;
        } else if (_isBancorAddress(to)) return false;

        result = _isReceiveAllowed(_to, token); // Check receiver at first
        if (!result) return false; // if receiver disallowed the transfer disallowed too.
        address from = address_belongs[_from];
        require(from != address(0), "ERR_TRANSFER_CHECK_WHITELIST");
        uint256 from_flags = user_details[from].flags;
        uint256 to_flags = user_details[to].flags;
        //makes sure that token is not mature
        if (tokenToMaturityDaysTimeStamp[token] != 0)
            require(
                now < tokenToMaturityDaysTimeStamp[token],
                "ERR_TOKEN_MATURED"
            );
        //makes sure that holdback days are over
        if (tokenToHoldBackDaysTimeStamp[token] != 0)
            require(
                now >= tokenToHoldBackDaysTimeStamp[token],
                "ERR_TOKEN_HOLDBACK_NOT_OVER"
            );

        for (
            uint256 i = 0;
            i < tokenToTransferringRuleArray[token].length;
            i++
        ) {
            // check the sender for restriction.
            result = _checkRule(
                from_flags,
                tokenToTransferringRuleArray[token][i].from_mask,
                tokenToTransferringRuleArray[token][i].from_condition
            );
            // check receiver only in case when sender has restriction.
            if (result) {
                result = _checkRule(
                    to_flags,
                    tokenToTransferringRuleArray[token][i].to_mask,
                    tokenToTransferringRuleArray[token][i].to_condition
                );
                if (result) return false; // if receiver is restricted, the transfer disallowed.
            }
        }
        return true;
    }

    /**@dev adds ReceivingRule for main token*/
    function addMainRecivingRule(uint256 mask, uint256 condition)
        public
        onlyOwner()
    {
        _addReceivingRule(mask, condition, 0);
    }

    /**@dev removes a specific rule from transferringRules for main token*/
    function removeMainTransferingRules(uint256 _index) public onlyOwner() {
        _removeTransferingRule(_index, 0);
    }

    /**@dev add transferringRule for main token*/
    function addMainTransferringRule(
        uint256 from_mask,
        uint256 from_condition,
        uint256 to_mask,
        uint256 to_condition
    ) public onlyOwner() {
        _addTransferringRule(
            from_mask,
            from_condition,
            to_mask,
            to_condition,
            0
        );
    }

    /**@dev checks if address is allowed to recieve main token*/
    function main_isReceiveAllowed(address user) public view returns (bool) {
        return _isReceiveAllowed(user, 0);
    }

    /**@dev check if transferring is allowed for main*/
    function main_isTransferAllowed(
        address _msgSender,
        address _from,
        address _to
    ) public view returns (bool) {
        return _isTransferAllowed(_msgSender, _from, _to, 0);
    }

    /**@dev check if transferring is allowed for etn*/
    function etn_isTransferAllowed(
        address _msgSender,
        address _from,
        address _to
    ) public view returns (bool) {
        return _isTransferAllowed(_msgSender, _from, _to, 1);
    }

    /**@dev checks if address is allowed to recieve etn token*/
    function etn_isReceiveAllowed(address user) public view returns (bool) {
        return _isReceiveAllowed(user, 1);
    }

    /**@dev adds ReceivingRule for etn token*/
    function addEtnTransferringRule(
        uint256 from_mask,
        uint256 from_condition,
        uint256 to_mask,
        uint256 to_condition
    ) public onlyOwner() {
        _addTransferringRule(
            from_mask,
            from_condition,
            to_mask,
            to_condition,
            1
        );
    }

    /**@dev removes a specific rule from transferringRules for etn token*/
    function removeEtnTransferingRules(uint256 _index) public onlyOwner() {
        _removeTransferingRule(_index, 1);
    }

    /**@dev adds ReceivingRule for etn token*/
    function addEtnRecivingRule(uint256 mask, uint256 condition)
        public
        onlyOwner()
    {
        _addReceivingRule(mask, condition, 1);
    }

    /**@dev check if transferring is allowed for stock*/
    function stock_isTransferAllowed(
        address _msgSender,
        address _from,
        address _to
    ) public view returns (bool) {
        return _isTransferAllowed(_msgSender, _from, _to, 2);
    }

    /**@dev checks if address is allowed to recieve stock token*/
    function stock_isReceiveAllowed(address user) public view returns (bool) {
        return _isReceiveAllowed(user, 2);
    }

    /**@dev add transferringRule for stock token*/
    function addStockTransferringRule(
        uint256 from_mask,
        uint256 from_condition,
        uint256 to_mask,
        uint256 to_condition
    ) public onlyOwner() {
        _addTransferringRule(
            from_mask,
            from_condition,
            to_mask,
            to_condition,
            2
        );
    }

    //@dev removes a specific rule from transferringRules for stock token*/
    function removeStockTransferingRules(uint256 _index) public onlyOwner() {
        _removeTransferingRule(_index, 2);
    }

    /**@dev adds ReceivingRule for stock token*/
    function addStockRecivingRule(uint256 mask, uint256 condition)
        public
        onlyOwner()
    {
        _addReceivingRule(mask, condition, 2);
    }

    /**@dev returns wallets associated with _whom */
    function getUserWallets(address _which)
        public
        view
        returns (address[] memory)
    {
        address primaryAddress = address_belongs[_which];
        UserDetails storage details = user_details[primaryAddress];
        return details.wallets;
    }

    function updateHoldBackDays(uint8 _token, uint256 _holdBackDay)
        public
        onlyAuthorized()
        returns (bool)
    {
        tokenToHoldBackDaysTimeStamp[_token] = convertDaysToTimeStamp(
            _holdBackDay
        );
        return true;
    }

    function updateMaturityDays(uint8 _token, uint256 _maturityDays)
        public
        onlyAuthorized()
        returns (bool)
    {
        tokenToMaturityDaysTimeStamp[_token] = convertDaysToTimeStamp(
            _maturityDays
        );
        return true;
    }
}
