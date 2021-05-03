/**
 *Submitted for verification at Etherscan.io on 2020-09-11
*/

// File: openzeppelin-solidity/contracts/GSN/Context.sol

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

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

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

// File: contracts/Layer2I.sol

pragma solidity >=0.5 <0.7.17;

interface Layer2I {
  function operator() external view returns (address);
  function isLayer2() external view returns (bool);
  function currentFork() external view returns (uint);
  function lastEpoch(uint forkNumber) external view returns (uint);
  function changeOperator(address _operator) external;
}

// File: contracts/stake/interfaces/SeigManagerI.sol

pragma solidity >=0.5 <0.7.17;


interface SeigManagerI {
  function registry() external view returns (address);
  function depositManager() external view returns (address);
  function ton() external view returns (address);
  function wton() external view returns (address);
  function powerton() external view returns (address);
  function tot() external view returns (address);
  function coinages(address layer2) external view returns (address);
  function commissionRates(address layer2) external view returns (uint256);

  function lastCommitBlock(address layer2) external view returns (uint256);
  function seigPerBlock() external view returns (uint256);
  function lastSeigBlock() external view returns (uint256);
  function pausedBlock() external view returns (uint256);
  function unpausedBlock() external view returns (uint256);
  function DEFAULT_FACTOR() external view returns (uint256);

  function deployCoinage(address layer2) external returns (bool);
  function setCommissionRate(address layer2, uint256 commission, bool isCommissionRateNegative) external returns (bool);

  function uncomittedStakeOf(address layer2, address account) external view returns (uint256);
  function stakeOf(address layer2, address account) external view returns (uint256);
  function additionalTotBurnAmount(address layer2, address account, uint256 amount) external view returns (uint256 totAmount);

  function onTransfer(address sender, address recipient, uint256 amount) external returns (bool);
  function updateSeigniorage() external returns (bool);
  function onDeposit(address layer2, address account, uint256 amount) external returns (bool);
  function onWithdraw(address layer2, address account, uint256 amount) external returns (bool);

}

// File: contracts/stake/interfaces/Layer2RegistryI.sol

pragma solidity >=0.5 <0.7.17;


interface Layer2RegistryI {
  function layer2s(address layer2) external view returns (bool);

  function register(address layer2) external returns (bool);
  function numLayer2s() external view returns (uint256);
  function layer2ByIndex(uint256 index) external view returns (address);

  function deployCoinage(address layer2, address seigManager) external returns (bool);
  function registerAndDeployCoinage(address layer2, address seigManager) external returns (bool);
  function unregister(address layer2) external returns (bool);
}

// File: contracts/stake/Layer2Registry.sol

pragma solidity >=0.5 <0.7.17;






// TODO: transfer coinages ownership to seig manager
contract Layer2Registry is Layer2RegistryI, Ownable {
  // check whether the address is layer2 contract or not
  mapping (address => bool) internal _layer2s;

  // array-like storages
  // NOTE: unregistered layer2s could exists in that array. so, should check by layer2s(address)
  uint256 internal _numLayer2s;
  mapping (uint256 => address) internal _layer2ByIndex;

  modifier onlyOwnerOrOperator(address layer2) {
    require(isOwner() || Layer2I(layer2).operator() == msg.sender, "sender is neither operator nor operator");
    _;
  }

  function layer2s(address layer2) external view returns (bool) {
    return _layer2s[layer2];
  }

  function numLayer2s() external view returns (uint256) {
    return _numLayer2s;
  }

  function layer2ByIndex(uint256 index) external view returns (address) {
    return _layer2ByIndex[index];
  }

  function register(address layer2)
    external
    onlyOwnerOrOperator(layer2)
    returns (bool)
  {
    return _register(layer2);
  }

  function _register(address layer2) internal returns (bool) {
    require(!_layer2s[layer2]);
    require(Layer2I(layer2).isLayer2());

    _layer2s[layer2] = true;
    _layer2ByIndex[_numLayer2s] = layer2;
    _numLayer2s += 1;

    return true;
  }

  function deployCoinage(
    address layer2,
    address seigManager
  )
    external
    onlyOwnerOrOperator(layer2)
    returns (bool)
  {
    return _deployCoinage(layer2, seigManager);
  }

  function _deployCoinage(
    address layer2,
    address seigManager
  )
   internal
   returns (bool)
  {
    return SeigManagerI(seigManager).deployCoinage(layer2);
  }

  function registerAndDeployCoinage(
    address layer2,
    address seigManager
  )
    external
    onlyOwnerOrOperator(layer2)
    returns (bool)
  {
    require(_register(layer2));
    require(_deployCoinage(layer2, seigManager));
    return true;
  }

  function registerAndDeployCoinageAndSetCommissionRate(
    address layer2,
    address seigManager,
    uint256 commissionRate,
    bool isCommissionRateNegative
  )
    external
    onlyOwnerOrOperator(layer2)
    returns (bool)
  {
    require(_register(layer2));
    require(_deployCoinage(layer2, seigManager));
    require(_setCommissionRate(layer2, seigManager, commissionRate, isCommissionRateNegative));
    return true;
  }

  function _setCommissionRate(
    address layer2,
    address seigManager,
    uint256 commissionRate,
    bool isCommissionRateNegative
  )
    internal
    returns (bool)
  {
    return SeigManagerI(seigManager).setCommissionRate(layer2, commissionRate, isCommissionRateNegative);
  }

  function unregister(address layer2) external onlyOwner returns (bool) {
    require(_layer2s[layer2]);

    _layer2s[layer2] = false;
  }

}