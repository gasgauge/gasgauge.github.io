/**
 *Submitted for verification at Etherscan.io on 2020-09-15
*/

// File: contracts/Proxy/IRegistry.sol

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

// File: contracts/common/Constant.sol

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

// File: contracts/common/Ownable.sol

pragma solidity >=0.5 <0.7.17;


contract Ownable is Constant {
    address public primaryOwner = address(0);

    address public authorityAddress = address(0);

    address public systemAddress = address(0);

    address public newAuthorityAddress = address(0);

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
    constructor(address _systemAddress, address _authorityAddress)
        public
        notZeroAddress(_systemAddress)
    {
        require(msg.sender != _systemAddress, ERR_SAME_ADDRESS);

        require(_systemAddress != _authorityAddress, ERR_SAME_ADDRESS);

        require(msg.sender != _authorityAddress, ERR_SAME_ADDRESS);

        primaryOwner = msg.sender;

        systemAddress = _systemAddress;

        authorityAddress = _authorityAddress;
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
     * @dev change primary ownership
     * @param _which The address to which is new owner address
     */
    function changePrimaryOwner(address _which)
        public
        onlyAuthorized()
        notZeroAddress(_which)
        returns (bool)
    {
        require(
            _which != systemAddress &&
                _which != authorityAddress &&
                _which != primaryOwner,
            ERR_SAME_ADDRESS
        );

        emit OwnershipTransferred("PRIMARY_OWNER", primaryOwner, _which);

        primaryOwner = _which;

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
                _which != authorityAddress &&
                _which != primaryOwner,
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

// File: contracts/Proxy/Proxy.sol

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

// File: contracts/Proxy/UpgradeabilityProxy.sol

pragma solidity >=0.5 <0.7.17;



/**
 * @title UpgradeabilityProxy
 * @dev This contract represents a proxy where the implementation address to which it will delegate can be upgraded
 */
contract UpgradeabilityProxy is  UpgradeabilityStorage {
    /**
     * @dev Constructor function
     */
    constructor(uint256 _version) public {
        registry = IRegistry(msg.sender);
        upgradeTo(_version);
    }

    /**
     * @dev Upgrades the implementation to the requested version
     * @param _version representing the version name of the new implementation to be set
     */
    function upgradeTo(uint256 _version) public {
        require(msg.sender == address(registry),"ERR_ONLY_REGISTRERY_CAN_CALL");
        _implementation = registry.getVersion(_version);
    }
}

// File: contracts/InterFaces/IERC20Token.sol

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

// File: contracts/Auction/AuctionProxy.sol

pragma solidity >=0.5 <0.7.17;





interface AuctionProxyInitializeInterface {
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

/**
 * @title Registry
 * @dev This contract works as a registry of versions, it holds the implementations for the registered versions.
 */
contract AuctionProxyRegistry is Ownable, IRegistry {
    // Mapping of versions to implementations of different functions
    mapping(uint256 => address) internal versions;

    uint256 public currentVersion;

    address payable public proxyAddress;

    //@dev constructor
    //@param _systemAddress address of the system Owner
    constructor(address _systemAddress, address _multisigAddress)
        public
        Ownable(_systemAddress, _multisigAddress)
    {}

    /**
     * @dev Registers a new version with its implementation address
     * @param version representing the version name of the new implementation to be registered
     * @param implementation representing the address of the new implementation to be registered
     */
    function addVersion(uint256 version, address implementation)
        public
        onlyOneOfOnwer()
        notZeroAddress(implementation)
    {
        require(
            versions[version] == address(0),
            "This version has implementation attached"
        );
        versions[version] = implementation;
        emit VersionAdded(version, implementation);
    }

    /**
     * @dev Tells the address of the implementation for a given version
     * @param version to query the implementation of
     * @return address of the implementation registered for the given version
     */
    function getVersion(uint256 version) public view returns (address) {
        return versions[version];
    }

    /**
     * @dev Creates an upgradeable proxy
     * @param version representing the first version to be set for the proxy
     * @return address of the new proxy created
     */
    function createProxy(
        uint256 version,
        uint256 _startTime,
        uint256 _minAuctionTime,
        uint256 _interval,
        uint256 _mainTokenCheckDay,
        address _primaryOwner,
        address _systemAddress,
        address _multisigAddress,
        address _registryaddress
    ) external onlyOneOfOnwer() returns (address) {
        require(proxyAddress == address(0), "ERR_PROXY_ALREADY_CREATED");

        UpgradeabilityProxy proxy = new UpgradeabilityProxy(version);

        AuctionProxyInitializeInterface(address(proxy)).initialize(
            _startTime,
            _minAuctionTime,
            _interval,
            _mainTokenCheckDay,
            _primaryOwner,
            _systemAddress,
            _multisigAddress,
            _registryaddress
        );

        currentVersion = version;
        proxyAddress = address(proxy);
        emit ProxyCreated(address(proxy));
        return address(proxy);
    }

    /**
     * @dev Upgrades the implementation to the requested version
     * @param version representing the version name of the new implementation to be set
     */

    function upgradeTo(uint256 version) public onlyAuthorized() returns (bool) {
        currentVersion = version;
        UpgradeabilityProxy(proxyAddress).upgradeTo(version);
        return true;
    }
}
