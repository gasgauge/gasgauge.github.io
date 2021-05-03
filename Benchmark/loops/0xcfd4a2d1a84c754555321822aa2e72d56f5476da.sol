/**
 *Submitted for verification at Etherscan.io on 2020-09-15
*/

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

// File: contracts/InterFaces/IAuction.sol

//pragma solidity ^0.5.9;
pragma solidity >=0.5 <0.7.17;

interface IAuction {
    
    function dayWiseMarketPrice(uint256 dayId) external view returns(uint256);
    
    function dayWiseContribution(uint256 dayId) external view returns(uint256);
    
    function auctionDay() external returns(uint256);
        
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

// File: contracts/contributionTrigger/ContributionTrigger.sol

//pragma solidity ^0.5.9;
pragma solidity >=0.5 <0.7.17;











interface ContributionTriggerInitializeInterface {
    function initialize(
        address _primaryOwner,
        address _systemAddress,
        address _multisigAdress,
        address _registryaddress
    ) external;
}

contract RegisteryContributionTrigger is ProxyOwnable, AuctionRegisteryContracts {
    IAuctionRegistery public contractsRegistry;
    address payable public liquidityAddress;

    event FundDeposited(address _token, address _from, uint256 _amount);

    function initilizeRegistry(
        address _primaryOwner,
        address _systemAddress,
        address _multisigAdress,
        address _registryaddress
    ) internal {
        initializeOwner(_primaryOwner, _systemAddress, _multisigAdress);
        contractsRegistry = IAuctionRegistery(_registryaddress);
        _updateAddresses();
    }

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
        liquidityAddress = getAddressOf(LIQUIDITY);
    }

    function updateAddresses() external returns (bool) {
        _updateAddresses();
        return true;
    }
}

contract ContributionTrigger is
    Upgradeable,
    RegisteryContributionTrigger,
    TokenTransfer,
    ContributionTriggerInitializeInterface
{
    function initialize(
        address _primaryOwner,
        address _systemAddress,
        address _multisigAdress,
        address _registryaddress
    ) external {
        super.initialize();
        initilizeRegistry(
            _primaryOwner,
            _systemAddress,
            _multisigAdress,
            _registryaddress
        );
    }

    function contributeTowardLiquidity(uint256 _amount)
        external
        returns (uint256)
    {
        require(msg.sender == liquidityAddress, "ERR_ONLY_Liquidity_ALLOWED");

        if (_amount > address(this).balance) {
            uint256 _newamount = address(this).balance;
            msg.sender.transfer(_newamount);
            return _newamount;
        }
        msg.sender.transfer(_amount);
        return _amount;
    }

    // relay token and bnt token
    function transferTokenLiquidity(
        IERC20Token _token,
        address _reciver,
        uint256 _amount
    ) external returns (bool) {
        require(msg.sender == liquidityAddress, "ERR_ONLY_Liquidity_ALLOWED");
        ensureTransferFrom(_token, address(this), _reciver, _amount);
        return true;
    }

    function depositeToken(
        IERC20Token _token,
        address _from,
        uint256 _amount
    ) external returns (bool) {
        ensureTransferFrom(_token, _from, address(this), _amount);
        emit FundDeposited(address(_token), _from, _amount);
        return true;
    }

    function() external payable {}
}
