/**
 *Submitted for verification at Etherscan.io on 2020-08-31
*/

// File: contracts/lib/os/ERC20.sol

// Brought from https://github.com/aragon/aragonOS/blob/v4.3.0/contracts/lib/token/ERC20.sol
// Adapted to use pragma ^0.5.8 and satisfy our linter rules

//pragma solidity ^0.5.8;
pragma solidity >=0.5 <0.7.17;


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 {
    function totalSupply() public view returns (uint256);

    function balanceOf(address _who) public view returns (uint256);

    function allowance(address _owner, address _spender) public view returns (uint256);

    function transfer(address _to, uint256 _value) public returns (bool);

    function approve(address _spender, uint256 _value) public returns (bool);

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool);

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value
    );

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

// File: contracts/lib/os/SafeMath.sol

// Brought from https://github.com/aragon/aragonOS/blob/v4.3.0/contracts/lib/math/SafeMath.sol
// Adapted to use pragma ^0.5.8 and satisfy our linter rules

//pragma solidity >=0.4.24 <0.6.0;
pragma solidity >=0.5 <0.7.17;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {
    string private constant ERROR_ADD_OVERFLOW = "MATH_ADD_OVERFLOW";
    string private constant ERROR_SUB_UNDERFLOW = "MATH_SUB_UNDERFLOW";
    string private constant ERROR_MUL_OVERFLOW = "MATH_MUL_OVERFLOW";
    string private constant ERROR_DIV_ZERO = "MATH_DIV_ZERO";

    /**
    * @dev Multiplies two numbers, reverts on overflow.
    */
    function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (_a == 0) {
            return 0;
        }

        uint256 c = _a * _b;
        require(c / _a == _b, ERROR_MUL_OVERFLOW);

        return c;
    }

    /**
    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
        require(_b > 0, ERROR_DIV_ZERO); // Solidity only automatically asserts when dividing by 0
        uint256 c = _a / _b;
        // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
        require(_b <= _a, ERROR_SUB_UNDERFLOW);
        uint256 c = _a - _b;

        return c;
    }

    /**
    * @dev Adds two numbers, reverts on overflow.
    */
    function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
        uint256 c = _a + _b;
        require(c >= _a, ERROR_ADD_OVERFLOW);

        return c;
    }

    /**
    * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, ERROR_DIV_ZERO);
        return a % b;
    }
}

// File: contracts/lib/os/SafeERC20.sol

// Brought from https://github.com/aragon/aragonOS/blob/v4.3.0/contracts/common/SafeERC20.sol
// Adapted to use pragma ^0.5.8 and satisfy our linter rules

//pragma solidity ^0.5.8;
pragma solidity >=0.5 <0.7.17;



library SafeERC20 {
    // Before 0.5, solidity has a mismatch between `address.transfer()` and `token.transfer()`:
    // https://github.com/ethereum/solidity/issues/3544
    bytes4 private constant TRANSFER_SELECTOR = 0xa9059cbb;

    /**
    * @dev Same as a standards-compliant ERC20.transfer() that never reverts (returns false).
    *      Note that this makes an external call to the token.
    */
    function safeTransfer(ERC20 _token, address _to, uint256 _amount) internal returns (bool) {
        bytes memory transferCallData = abi.encodeWithSelector(
            TRANSFER_SELECTOR,
            _to,
            _amount
        );
        return invokeAndCheckSuccess(address(_token), transferCallData);
    }

    /**
    * @dev Same as a standards-compliant ERC20.transferFrom() that never reverts (returns false).
    *      Note that this makes an external call to the token.
    */
    function safeTransferFrom(ERC20 _token, address _from, address _to, uint256 _amount) internal returns (bool) {
        bytes memory transferFromCallData = abi.encodeWithSelector(
            _token.transferFrom.selector,
            _from,
            _to,
            _amount
        );
        return invokeAndCheckSuccess(address(_token), transferFromCallData);
    }

    /**
    * @dev Same as a standards-compliant ERC20.approve() that never reverts (returns false).
    *      Note that this makes an external call to the token.
    */
    function safeApprove(ERC20 _token, address _spender, uint256 _amount) internal returns (bool) {
        bytes memory approveCallData = abi.encodeWithSelector(
            _token.approve.selector,
            _spender,
            _amount
        );
        return invokeAndCheckSuccess(address(_token), approveCallData);
    }

    function invokeAndCheckSuccess(address _addr, bytes memory _calldata) private returns (bool) {
        bool ret;
        assembly {
            let ptr := mload(0x40)    // free memory pointer

            let success := call(
                gas,                  // forward all gas
                _addr,                // address
                0,                    // no value
                add(_calldata, 0x20), // calldata start
                mload(_calldata),     // calldata length
                ptr,                  // write output over free memory
                0x20                  // uint256 return
            )

            if gt(success, 0) {
            // Check number of bytes returned from last function call
                switch returndatasize

                // No bytes returned: assume success
                case 0 {
                    ret := 1
                }

                // 32 bytes returned: check if non-zero
                case 0x20 {
                // Only return success if returned data was true
                // Already have output in ptr
                    ret := eq(mload(ptr), 1)
                }

                // Not sure what was returned: don't mark as success
                default { }
            }
        }
        return ret;
    }
}

// File: contracts/lib/os/IsContract.sol

// Brought from https://github.com/aragon/aragonOS/blob/v4.3.0/contracts/common/IsContract.sol
// Adapted to use pragma ^0.5.8 and satisfy our linter rules

//pragma solidity ^0.5.8;
pragma solidity >=0.5 <0.7.17;


contract IsContract {
    /*
    * NOTE: this should NEVER be used for authentication
    * (see pitfalls: https://github.com/fergarrui/ethereum-security/tree/master/contracts/extcodesize).
    *
    * This is only intended to be used as a sanity check that an address is actually a contract,
    * RATHER THAN an address not being a contract.
    */
    function isContract(address _target) internal view returns (bool) {
        if (_target == address(0)) {
            return false;
        }

        uint256 size;
        assembly { size := extcodesize(_target) }
        return size > 0;
    }
}

// File: contracts/lib/os/Uint256Helpers.sol

// Brought from https://github.com/aragon/aragonOS/blob/v4.3.0/contracts/common/Uint256Helpers.sol
// Adapted to use pragma ^0.5.8 and satisfy our linter rules

//pragma solidity ^0.5.8;
pragma solidity >=0.5 <0.7.17;


library Uint256Helpers {
    uint256 private constant MAX_UINT8 = uint8(-1);
    uint256 private constant MAX_UINT64 = uint64(-1);

    string private constant ERROR_UINT8_NUMBER_TOO_BIG = "UINT8_NUMBER_TOO_BIG";
    string private constant ERROR_UINT64_NUMBER_TOO_BIG = "UINT64_NUMBER_TOO_BIG";

    function toUint8(uint256 a) internal pure returns (uint8) {
        require(a <= MAX_UINT8, ERROR_UINT8_NUMBER_TOO_BIG);
        return uint8(a);
    }

    function toUint64(uint256 a) internal pure returns (uint64) {
        require(a <= MAX_UINT64, ERROR_UINT64_NUMBER_TOO_BIG);
        return uint64(a);
    }
}

// File: contracts/lib/os/TimeHelpers.sol

// Brought from https://github.com/aragon/aragonOS/blob/v4.3.0/contracts/common/TimeHelpers.sol
// Adapted to use pragma ^0.5.8 and satisfy our linter rules

//pragma solidity ^0.5.8;
pragma solidity >=0.5 <0.7.17;



contract TimeHelpers {
    using Uint256Helpers for uint256;

    /**
    * @dev Returns the current block number.
    *      Using a function rather than `block.number` allows us to easily mock the block number in
    *      tests.
    */
    function getBlockNumber() internal view returns (uint256) {
        return block.number;
    }

    /**
    * @dev Returns the current block number, converted to uint64.
    *      Using a function rather than `block.number` allows us to easily mock the block number in
    *      tests.
    */
    function getBlockNumber64() internal view returns (uint64) {
        return getBlockNumber().toUint64();
    }

    /**
    * @dev Returns the current timestamp.
    *      Using a function rather than `block.timestamp` allows us to easily mock it in
    *      tests.
    */
    function getTimestamp() internal view returns (uint256) {
        return block.timestamp; // solium-disable-line security/no-block-members
    }

    /**
    * @dev Returns the current timestamp, converted to uint64.
    *      Using a function rather than `block.timestamp` allows us to easily mock it in
    *      tests.
    */
    function getTimestamp64() internal view returns (uint64) {
        return getTimestamp().toUint64();
    }
}

// File: contracts/lib/os/UnstructuredStorage.sol

// Brought from https://github.com/aragon/aragonOS/blob/v4.3.0/contracts/common/UnstructuredStorage.sol
// Adapted to use pragma ^0.5.17 and satisfy our linter rules

//pragma solidity ^0.5.17;
pragma solidity >=0.5 <0.7.17;


library UnstructuredStorage {
    function getStorageBool(bytes32 position) internal view returns (bool data) {
        assembly { data := sload(position) }
    }

    function getStorageAddress(bytes32 position) internal view returns (address data) {
        assembly { data := sload(position) }
    }

    function getStorageBytes32(bytes32 position) internal view returns (bytes32 data) {
        assembly { data := sload(position) }
    }

    function getStorageUint256(bytes32 position) internal view returns (uint256 data) {
        assembly { data := sload(position) }
    }

    function setStorageBool(bytes32 position, bool data) internal {
        assembly { sstore(position, data) }
    }

    function setStorageAddress(bytes32 position, address data) internal {
        assembly { sstore(position, data) }
    }

    function setStorageBytes32(bytes32 position, bytes32 data) internal {
        assembly { sstore(position, data) }
    }

    function setStorageUint256(bytes32 position, uint256 data) internal {
        assembly { sstore(position, data) }
    }
}

// File: contracts/lib/os/Initializable.sol

// Brought from https://github.com/aragon/aragonOS/blob/v4.3.0/contracts/common/Initializable.sol
// Adapted to use pragma ^0.5.17 and satisfy our linter rules

//pragma solidity ^0.5.17;
pragma solidity >=0.5 <0.7.17;




contract Initializable is TimeHelpers {
    using UnstructuredStorage for bytes32;

    // keccak256("aragonOS.initializable.initializationBlock")
    bytes32 internal constant INITIALIZATION_BLOCK_POSITION = 0xebb05b386a8d34882b8711d156f463690983dc47815980fb82aeeff1aa43579e;

    string private constant ERROR_ALREADY_INITIALIZED = "INIT_ALREADY_INITIALIZED";
    string private constant ERROR_NOT_INITIALIZED = "INIT_NOT_INITIALIZED";

    modifier onlyInit {
        require(getInitializationBlock() == 0, ERROR_ALREADY_INITIALIZED);
        _;
    }

    modifier isInitialized {
        require(hasInitialized(), ERROR_NOT_INITIALIZED);
        _;
    }

    /**
    * @return Block number in which the contract was initialized
    */
    function getInitializationBlock() public view returns (uint256) {
        return INITIALIZATION_BLOCK_POSITION.getStorageUint256();
    }

    /**
    * @return Whether the contract has been initialized by the time of the current block
    */
    function hasInitialized() public view returns (bool) {
        uint256 initializationBlock = getInitializationBlock();
        return initializationBlock != 0 && getBlockNumber() >= initializationBlock;
    }

    /**
    * @dev Function to be called by top level contract after initialization has finished.
    */
    function initialized() internal onlyInit {
        INITIALIZATION_BLOCK_POSITION.setStorageUint256(getBlockNumber());
    }

    /**
    * @dev Function to be called by top level contract after initialization to enable the contract
    *      at a future block number rather than immediately.
    */
    function initializedAt(uint256 _blockNumber) internal onlyInit {
        INITIALIZATION_BLOCK_POSITION.setStorageUint256(_blockNumber);
    }
}

// File: contracts/lib/os/Petrifiable.sol

// Brought from https://github.com/aragon/aragonOS/blob/v4.3.0/contracts/common/Petrifiable.sol
// Adapted to use pragma ^0.5.17 and satisfy our linter rules

//pragma solidity ^0.5.17;
pragma solidity >=0.5 <0.7.17;



contract Petrifiable is Initializable {
    // Use block UINT256_MAX (which should be never) as the initializable date
    uint256 internal constant PETRIFIED_BLOCK = uint256(-1);

    function isPetrified() public view returns (bool) {
        return getInitializationBlock() == PETRIFIED_BLOCK;
    }

    /**
    * @dev Function to be called by top level contract to prevent being initialized.
    *      Useful for freezing base contracts when they're used behind proxies.
    */
    function petrify() internal onlyInit {
        initializedAt(PETRIFIED_BLOCK);
    }
}

// File: contracts/lib/os/Autopetrified.sol

// Brought from https://github.com/aragon/aragonOS/blob/v4.3.0/contracts/common/Autopetrified.sol
// Adapted to use pragma ^0.5.17 and satisfy our linter rules

//pragma solidity ^0.5.17;
pragma solidity >=0.5 <0.7.17;



contract Autopetrified is Petrifiable {
    constructor() public {
        // Immediately petrify base (non-proxy) instances of inherited contracts on deploy.
        // This renders them uninitializable (and unusable without a proxy).
        petrify();
    }
}

// File: contracts/lib/Checkpointing.sol

//pragma solidity ^0.5.17;
pragma solidity >=0.5 <0.7.17;


/**
* @title Checkpointing - Library to handle a historic set of numeric values
*/
library Checkpointing {
    uint256 private constant MAX_UINT192 = uint256(uint192(-1));

    string private constant ERROR_VALUE_TOO_BIG = "CHECKPOINT_VALUE_TOO_BIG";
    string private constant ERROR_CANNOT_ADD_PAST_VALUE = "CHECKPOINT_CANNOT_ADD_PAST_VALUE";

    /**
     * @dev To specify a value at a given point in time, we need to store two values:
     *      - `time`: unit-time value to denote the first time when a value was registered
     *      - `value`: a positive numeric value to registered at a given point in time
     *
     *      Note that `time` does not need to refer necessarily to a timestamp value, any time unit could be used
     *      for it like block numbers, terms, etc.
     */
    struct Checkpoint {
        uint64 time;
        uint192 value;
    }

    /**
     * @dev A history simply denotes a list of checkpoints
     */
    struct History {
        Checkpoint[] history;
    }

    /**
     * @dev Add a new value to a history for a given point in time. This function does not allow to add values previous
     *      to the latest registered value, if the value willing to add corresponds to the latest registered value, it
     *      will be updated.
     * @param self Checkpoints history to be altered
     * @param _time Point in time to register the given value
     * @param _value Numeric value to be registered at the given point in time
     */
    function add(History storage self, uint64 _time, uint256 _value) internal {
        require(_value <= MAX_UINT192, ERROR_VALUE_TOO_BIG);
        _add192(self, _time, uint192(_value));
    }

    /**
     * TODO
     */
    function lastUpdate(History storage self) internal view returns (uint256) {
        uint256 length = self.history.length;

        if (length > 0) {
            return uint256(self.history[length - 1].time);
        }

        return 0;
    }

    /**
     * @dev Fetch the latest registered value of history, it will return zero if there was no value registered
     * @param self Checkpoints history to be queried
     */
    function getLast(History storage self) internal view returns (uint256) {
        uint256 length = self.history.length;
        if (length > 0) {
            return uint256(self.history[length - 1].value);
        }

        return 0;
    }

    /**
     * @dev Fetch the most recent registered past value of a history based on a given point in time that is not known
     *      how recent it is beforehand. It will return zero if there is no registered value or if given time is
     *      previous to the first registered value.
     *      It uses a binary search.
     * @param self Checkpoints history to be queried
     * @param _time Point in time to query the most recent registered past value of
     */
    function get(History storage self, uint64 _time) internal view returns (uint256) {
        return _binarySearch(self, _time);
    }

    /**
     * @dev Private function to add a new value to a history for a given point in time. This function does not allow to
     *      add values previous to the latest registered value, if the value willing to add corresponds to the latest
     *      registered value, it will be updated.
     * @param self Checkpoints history to be altered
     * @param _time Point in time to register the given value
     * @param _value Numeric value to be registered at the given point in time
     */
    function _add192(History storage self, uint64 _time, uint192 _value) private {
        uint256 length = self.history.length;
        if (length == 0 || self.history[self.history.length - 1].time < _time) {
            // If there was no value registered or the given point in time is after the latest registered value,
            // we can insert it to the history directly.
            self.history.push(Checkpoint(_time, _value));
        } else {
            // If the point in time given for the new value is not after the latest registered value, we must ensure
            // we are only trying to update the latest value, otherwise we would be changing past data.
            Checkpoint storage currentCheckpoint = self.history[length - 1];
            require(_time == currentCheckpoint.time, ERROR_CANNOT_ADD_PAST_VALUE);
            currentCheckpoint.value = _value;
        }
    }

    /**
     * @dev Private function execute a binary search to find the most recent registered past value of a history based on
     *      a given point in time. It will return zero if there is no registered value or if given time is previous to
     *      the first registered value. Note that this function will be more suitable when don't know how recent the
     *      time used to index may be.
     * @param self Checkpoints history to be queried
     * @param _time Point in time to query the most recent registered past value of
     */
    function _binarySearch(History storage self, uint64 _time) private view returns (uint256) {
        // If there was no value registered for the given history return simply zero
        uint256 length = self.history.length;
        if (length == 0) {
            return 0;
        }

        // If the requested time is equal to or after the time of the latest registered value, return latest value
        uint256 lastIndex = length - 1;
        if (_time >= self.history[lastIndex].time) {
            return uint256(self.history[lastIndex].value);
        }

        // If the requested time is previous to the first registered value, return zero to denote missing checkpoint
        if (_time < self.history[0].time) {
            return 0;
        }

        // Execute a binary search between the checkpointed times of the history
        uint256 low = 0;
        uint256 high = lastIndex;

        while (high > low) {
            // No need for SafeMath: for this to overflow array size should be ~2^255
            uint256 mid = (high + low + 1) / 2;
            Checkpoint storage checkpoint = self.history[mid];
            uint64 midTime = checkpoint.time;

            if (_time > midTime) {
                low = mid;
            } else if (_time < midTime) {
                // No need for SafeMath: high > low >= 0 => high >= 1 => mid >= 1
                high = mid - 1;
            } else {
                return uint256(checkpoint.value);
            }
        }

        return uint256(self.history[low].value);
    }
}

// File: contracts/standards/ERC900.sol

//pragma solidity ^0.5.17;
pragma solidity >=0.5 <0.7.17;


// Interface for ERC900: https://eips.ethereum.org/EIPS/eip-900
interface ERC900 {
    event Staked(address indexed user, uint256 amount, uint256 total, bytes data);
    event Unstaked(address indexed user, uint256 amount, uint256 total, bytes data);

    /**
     * @dev Stake a certain amount of tokens
     * @param _amount Amount of tokens to be staked
     * @param _data Optional data that can be used to add signalling information in more complex staking applications
     */
    function stake(uint256 _amount, bytes calldata _data) external;

    /**
     * @dev Stake a certain amount of tokens in favor of someone
     * @param _user Address to stake an amount of tokens to
     * @param _amount Amount of tokens to be staked
     * @param _data Optional data that can be used to add signalling information in more complex staking applications
     */
    function stakeFor(address _user, uint256 _amount, bytes calldata _data) external;

    /**
     * @dev Unstake a certain amount of tokens
     * @param _amount Amount of tokens to be unstaked
     * @param _data Optional data that can be used to add signalling information in more complex staking applications
     */
    function unstake(uint256 _amount, bytes calldata _data) external;

    /**
     * @dev Tell the total amount of tokens staked for an address
     * @param _addr Address querying the total amount of tokens staked for
     * @return Total amount of tokens staked for an address
     */
    function totalStakedFor(address _addr) external view returns (uint256);

    /**
     * @dev Tell the total amount of tokens staked
     * @return Total amount of tokens staked
     */
    function totalStaked() external view returns (uint256);

    /**
     * @dev Tell the address of the token used for staking
     * @return Address of the token used for staking
     */
    function token() external view returns (address);

    /*
     * @dev Tell if the current registry supports historic information or not
     * @return True if the optional history functions are implemented, false otherwise
     */
    function supportsHistory() external pure returns (bool);
}

// File: contracts/locking/IStakingLocking.sol

//pragma solidity ^0.5.17;
pragma solidity >=0.5 <0.7.17;


interface IStakingLocking {
    event NewLockManager(address indexed account, address indexed lockManager, bytes data);
    event Unlocked(address indexed account, address indexed lockManager, uint256 amount);
    event LockAmountChanged(address indexed account, address indexed lockManager, uint256 amount, bool increase);
    event LockAllowanceChanged(address indexed account, address indexed lockManager, uint256 allowance, bool increase);
    event LockManagerRemoved(address indexed account, address lockManager);
    event LockManagerTransferred(address indexed account, address indexed oldLockManager, address newLockManager);
    event StakeTransferred(address indexed from, address to, uint256 amount);

    function allowManager(address _lockManager, uint256 _allowance, bytes calldata _data) external;
    function allowManagerAndLock(uint256 _amount, address _lockManager, uint256 _allowance, bytes calldata _data) external;
    function unlockAndRemoveManager(address _account, address _lockManager) external;
    function increaseLockAllowance(address _lockManager, uint256 _allowance) external;
    function decreaseLockAllowance(address _account, address _lockManager, uint256 _allowance) external;
    function lock(address _account, address _lockManager, uint256 _amount) external;
    function unlock(address _account, address _lockManager, uint256 _amount) external;
    function setLockManager(address _account, address _newLockManager) external;
    function transfer(address _to, uint256 _amount) external;
    function transferAndUnstake(address _to, uint256 _amount) external;
    function slash(address _account, address _to, uint256 _amount) external;
    function slashAndUnstake(address _account, address _to, uint256 _amount) external;

    function getLock(address _account, address _lockManager) external view returns (uint256 _amount, uint256 _allowance);
    function unlockedBalanceOf(address _account) external view returns (uint256);
    function lockedBalanceOf(address _user) external view returns (uint256);
    function getBalancesOf(address _user) external view returns (uint256 staked, uint256 locked);
    function canUnlock(address _sender, address _account, address _lockManager, uint256 _amount) external view returns (bool);
}

// File: contracts/locking/ILockManager.sol

//pragma solidity ^0.5.17;
pragma solidity >=0.5 <0.7.17;


interface ILockManager {
    /**
     * @notice Check if `_user`'s by `_lockManager` can be unlocked
     * @param _user Owner of lock
     * @param _amount Amount of locked tokens to unlock
     * @return Whether given lock of given owner can be unlocked by given sender
     */
    function canUnlock(address _user, uint256 _amount) external view returns (bool);
}

// File: contracts/Staking.sol

//pragma solidity 0.5.17;
pragma solidity >=0.5 <0.7.17;










contract Staking is Autopetrified, ERC900, IStakingLocking, IsContract {
    using SafeMath for uint256;
    using Checkpointing for Checkpointing.History;
    using SafeERC20 for ERC20;

    uint256 private constant MAX_UINT64 = uint256(uint64(-1));

    string private constant ERROR_TOKEN_NOT_CONTRACT = "STAKING_TOKEN_NOT_CONTRACT";
    string private constant ERROR_AMOUNT_ZERO = "STAKING_AMOUNT_ZERO";
    string private constant ERROR_TOKEN_TRANSFER = "STAKING_TOKEN_TRANSFER_FAIL";
    string private constant ERROR_TOKEN_DEPOSIT = "STAKING_TOKEN_DEPOSIT_FAIL";
    string private constant ERROR_TOKEN_NOT_SENDER = "STAKING_TOKEN_NOT_SENDER";
    string private constant ERROR_WRONG_TOKEN = "STAKING_WRONG_TOKEN";
    string private constant ERROR_NOT_ENOUGH_BALANCE = "STAKING_NOT_ENOUGH_BALANCE";
    string private constant ERROR_NOT_ENOUGH_ALLOWANCE = "STAKING_NOT_ENOUGH_ALLOWANCE";
    string private constant ERROR_SENDER_NOT_ALLOWED = "STAKING_SENDER_NOT_ALLOWED";
    string private constant ERROR_ALLOWANCE_ZERO = "STAKING_ALLOWANCE_ZERO";
    string private constant ERROR_LOCK_ALREADY_EXISTS = "STAKING_LOCK_ALREADY_EXISTS";
    string private constant ERROR_LOCK_DOES_NOT_EXIST = "STAKING_LOCK_DOES_NOT_EXIST";
    string private constant ERROR_NOT_ENOUGH_LOCK = "STAKING_NOT_ENOUGH_LOCK";
    string private constant ERROR_CANNOT_UNLOCK = "STAKING_CANNOT_UNLOCK";
    string private constant ERROR_CANNOT_CHANGE_ALLOWANCE = "STAKING_CANNOT_CHANGE_ALLOWANCE";
    string private constant ERROR_LOCKMANAGER_CALL_FAIL = "STAKING_LOCKMANAGER_CALL_FAIL";
    string private constant ERROR_BLOCKNUMBER_TOO_BIG = "STAKING_BLOCKNUMBER_TOO_BIG";

    struct Lock {
        uint256 amount;
        uint256 allowance;  // must be greater than zero to consider the lock active, and always greater than or equal to amount
    }

    struct Account {
        mapping (address => Lock) locks; // from manager to lock
        uint256 totalLocked;
        Checkpointing.History stakedHistory;
    }

    ERC20 internal stakingToken;
    mapping (address => Account) internal accounts;
    Checkpointing.History internal totalStakedHistory;

    /**
     * @notice Initialize Staking app with token `_stakingToken`
     * @param _stakingToken ERC20 token used for staking
     */
    function initialize(ERC20 _stakingToken) external {
        require(isContract(address(_stakingToken)), ERROR_TOKEN_NOT_CONTRACT);
        initialized();
        stakingToken = _stakingToken;
    }

    /**
     * @notice Stakes `@tokenAmount(self.token(): address, _amount)`, transferring them from `msg.sender`
     * @param _amount Number of tokens staked
     * @param _data Used in Staked event, to add signalling information in more complex staking applications
     */
    function stake(uint256 _amount, bytes calldata _data) external isInitialized {
        _stakeFor(msg.sender, msg.sender, _amount, _data);
    }

    /**
     * @notice Stakes `@tokenAmount(self.token(): address, _amount)`, transferring them from `msg.sender`, and assigns them to `_user`
     * @param _user The receiving accounts for the tokens staked
     * @param _amount Number of tokens staked
     * @param _data Used in Staked event, to add signalling information in more complex staking applications
     */
    function stakeFor(address _user, uint256 _amount, bytes calldata _data) external isInitialized {
        _stakeFor(msg.sender, _user, _amount, _data);
    }

    /**
     * @notice Unstakes `@tokenAmount(self.token(): address, _amount)`, returning them to the user
     * @param _amount Number of tokens to unstake
     * @param _data Used in Unstaked event, to add signalling information in more complex staking applications
     */
    function unstake(uint256 _amount, bytes calldata _data) external isInitialized {
        // unstaking 0 tokens is not allowed
        require(_amount > 0, ERROR_AMOUNT_ZERO);

        _unstake(msg.sender, _amount, _data);
    }

    /**
     * @notice Allow `_lockManager` to lock up to `@tokenAmount(self.token(): address, _allowance)` of `msg.sender`
     *         It creates a new lock, so the lock for this manager cannot exist before.
     * @param _lockManager The manager entity for this particular lock
     * @param _allowance Amount of tokens that the manager can lock
     * @param _data Data to parametrize logic for the lock to be enforced by the manager
     */
    function allowManager(address _lockManager, uint256 _allowance, bytes calldata _data) external isInitialized {
        _allowManager(_lockManager, _allowance, _data);
    }

    /**
     * @notice Lock `@tokenAmount(self.token(): address, _amount)` and assign `_lockManager` as manager with `@tokenAmount(self.token(): address, _allowance)` allowance and `_data` as data, so they can not be unstaked
     * @param _amount The amount of tokens to be locked
     * @param _lockManager The manager entity for this particular lock. This entity will have full control over the lock, in particular will be able to unlock it
     * @param _allowance Amount of tokens that the manager can lock
     * @param _data Data to parametrize logic for the lock to be enforced by the manager
     */
    function allowManagerAndLock(uint256 _amount, address _lockManager, uint256 _allowance, bytes calldata _data) external isInitialized {
        _allowManager(_lockManager, _allowance, _data);

        _lockUnsafe(msg.sender, _lockManager, _amount);
    }

    /**
     * @notice Transfer `@tokenAmount(self.token(): address, _amount)` to `_to`’s staked balance
     * @param _to Recipient of the tokens
     * @param _amount Number of tokens to be transferred
     */
    function transfer(address _to, uint256 _amount) external isInitialized {
        _transfer(msg.sender, _to, _amount);
    }

    /**
     * @notice Transfer `@tokenAmount(self.token(): address, _amount)` to `_to`’s external balance (i.e. unstaked)
     * @param _to Recipient of the tokens
     * @param _amount Number of tokens to be transferred
     */
    function transferAndUnstake(address _to, uint256 _amount) external isInitialized {
        _transfer(msg.sender, _to, _amount);
        _unstake(_to, _amount, new bytes(0));
    }

    /**
     * @notice Transfer `@tokenAmount(self.token(): address, _amount)` from `_from`'s lock by `msg.sender` to `_to`
     * @param _from Owner of locked tokens
     * @param _to Recipient of the tokens
     * @param _amount Number of tokens to be transferred
     */
    function slash(
        address _from,
        address _to,
        uint256 _amount
    )
        external
        isInitialized
    {
        _unlockUnsafe(_from, msg.sender, _amount);
        _transfer(_from, _to, _amount);
    }

    /**
     * @notice Transfer `@tokenAmount(self.token(): address, _amount)` from `_from`'s lock by `msg.sender` to `_to` (unstaked)
     * @param _from Owner of locked tokens
     * @param _to Recipient of the tokens
     * @param _amount Number of tokens to be transferred
     */
    function slashAndUnstake(
        address _from,
        address _to,
        uint256 _amount
    )
        external
        isInitialized
    {
        _unlockUnsafe(_from, msg.sender, _amount);
        _transfer(_from, _to, _amount);
        _unstake(_to, _amount, new bytes(0));
    }

    /**
     * @notice Transfer `@tokenAmount(self.token(): address, _slashAmount)` from `_from`'s lock by `msg.sender` to `_to`, and decrease `@tokenAmount(self.token(): address, _unlockAmount)` from that lock
     * @param _from Owner of locked tokens
     * @param _to Recipient of the tokens
     * @param _unlockAmount Number of tokens to be unlocked
     * @param _slashAmount Number of tokens to be transferred
     */
    function slashAndUnlock(
        address _from,
        address _to,
        uint256 _unlockAmount,
        uint256 _slashAmount
    )
        external
        isInitialized
    {
        // No need to check that _slashAmount is positive, as _transfer will fail
        // No need to check that have enough locked funds, as _unlockUnsafe will fail
        require(_unlockAmount > 0, ERROR_AMOUNT_ZERO);

        _unlockUnsafe(_from, msg.sender, _unlockAmount.add(_slashAmount));
        _transfer(_from, _to, _slashAmount);
    }

    /**
     * @notice Increase allowance by `@tokenAmount(self.token(): address, _allowance)` of lock manager `_lockManager` for user `msg.sender`
     * @param _lockManager The manager entity for this particular lock
     * @param _allowance Amount of allowed tokens increase
     */
    function increaseLockAllowance(address _lockManager, uint256 _allowance) external isInitialized {
        Lock storage lock_ = accounts[msg.sender].locks[_lockManager];
        require(lock_.allowance > 0, ERROR_LOCK_DOES_NOT_EXIST);

        _increaseLockAllowance(_lockManager, lock_, _allowance);
    }

    /**
     * @notice Decrease allowance by `@tokenAmount(self.token(): address, _allowance)` of lock manager `_lockManager` for user `_user`
     * @param _user Owner of locked tokens
     * @param _lockManager The manager entity for this particular lock
     * @param _allowance Amount of allowed tokens decrease
     */
    function decreaseLockAllowance(address _user, address _lockManager, uint256 _allowance) external isInitialized {
        // only owner and manager can decrease allowance
        require(msg.sender == _user || msg.sender == _lockManager, ERROR_CANNOT_CHANGE_ALLOWANCE);
        require(_allowance > 0, ERROR_AMOUNT_ZERO);

        Lock storage lock_ = accounts[_user].locks[_lockManager];
        uint256 newAllowance = lock_.allowance.sub(_allowance);
        require(newAllowance >= lock_.amount, ERROR_NOT_ENOUGH_ALLOWANCE);
        // unlockAndRemoveManager must be used for this:
        require(newAllowance > 0, ERROR_ALLOWANCE_ZERO);

        lock_.allowance = newAllowance;

        emit LockAllowanceChanged(_user, _lockManager, _allowance, false);
    }

    /**
     * @notice Increase locked amount by `@tokenAmount(self.token(): address, _amount)` for user `_user` by lock manager `_lockManager`
     * @param _user Owner of locked tokens
     * @param _lockManager The manager entity for this particular lock
     * @param _amount Amount of locked tokens increase
     */
    function lock(address _user, address _lockManager, uint256 _amount) external isInitialized {
        // we are locking funds from owner account, so only owner or manager are allowed
        require(msg.sender == _user || msg.sender == _lockManager, ERROR_SENDER_NOT_ALLOWED);

        _lockUnsafe(_user, _lockManager, _amount);
    }

    /**
     * @notice Decrease locked amount by `@tokenAmount(self.token(): address, _amount)` for user `_user` by lock manager `_lockManager`
     * @param _user Owner of locked tokens
     * @param _lockManager The manager entity for this particular lock
     * @param _amount Amount of locked tokens decrease
     */
    function unlock(address _user, address _lockManager, uint256 _amount) external isInitialized {
        require(_amount > 0, ERROR_AMOUNT_ZERO);

        // only manager and owner (if manager allows) can unlock
        require(_canUnlockUnsafe(msg.sender, _user, _lockManager, _amount), ERROR_CANNOT_UNLOCK);

        _unlockUnsafe(_user, _lockManager, _amount);
    }

    /**
     * @notice Unlock `_user`'s lock by `_lockManager` so locked tokens can be unstaked again
     * @param _user Owner of locked tokens
     * @param _lockManager Manager of the lock for the given account
     */
    function unlockAndRemoveManager(address _user, address _lockManager) external isInitialized {
        // only manager and owner (if manager allows) can unlock
        require(_canUnlockUnsafe(msg.sender, _user, _lockManager, 0), ERROR_CANNOT_UNLOCK);

        Account storage account = accounts[_user];
        Lock storage lock_ = account.locks[_lockManager];

        uint256 amount = lock_.amount;
        // update total
        account.totalLocked = account.totalLocked.sub(amount);

        emit LockAmountChanged(_user, _lockManager, amount, false);
        emit LockManagerRemoved(_user, _lockManager);

        delete account.locks[_lockManager];
    }

    /**
     * @notice Change the manager of `_user`'s lock from `msg.sender` to `_newLockManager`
     * @param _user Owner of lock
     * @param _newLockManager New lock manager
     */
    function setLockManager(address _user, address _newLockManager) external isInitialized {
        Lock storage lock_ = accounts[_user].locks[msg.sender];
        require(lock_.allowance > 0, ERROR_LOCK_DOES_NOT_EXIST);

        accounts[_user].locks[_newLockManager] = lock_;

        delete accounts[_user].locks[msg.sender];

        emit LockManagerTransferred(_user, msg.sender, _newLockManager);
    }

    /**
     * @dev MiniMeToken ApproveAndCallFallBack compliance
     * @param _from Account approving tokens
     * @param _amount Amount of `_token` tokens being approved
     * @param _token MiniMeToken that is being approved and that the call comes from
     * @param _data Used in Staked event, to add signalling information in more complex staking applications
     */
    function receiveApproval(address _from, uint256 _amount, address _token, bytes calldata _data) external isInitialized {
        require(_token == msg.sender, ERROR_TOKEN_NOT_SENDER);
        require(_token == address(stakingToken), ERROR_WRONG_TOKEN);

        _stakeFor(_from, _from, _amount, _data);
    }

    /**
     * @notice Check whether it supports history of stakes
     * @return Always true
     */
    function supportsHistory() external pure returns (bool) {
        return true;
    }

    /**
     * @notice Get the token used by the contract for staking and locking
     * @return The token used by the contract for staking and locking
     */
    function token() external view isInitialized returns (address) {
        return address(stakingToken);
    }

    /**
     * @notice Get last time `_user` modified its staked balance
     * @param _user Account requesting for
     * @return Last block number when account's balance was modified
     */
    function lastStakedFor(address _user) external view isInitialized returns (uint256) {
        return accounts[_user].stakedHistory.lastUpdate();
    }

    /**
     * @notice Get total amount of locked tokens for `_user`
     * @param _user Owner of locks
     * @return Total amount of locked tokens for the requested account
     */
    function lockedBalanceOf(address _user) external view isInitialized returns (uint256) {
        return _lockedBalanceOf(_user);
    }

    /**
     * @notice Get details of `_user`'s lock by `_lockManager`
     * @param _user Owner of lock
     * @param _lockManager Manager of the lock for the given account
     * @return Amount of locked tokens
     * @return Amount of tokens that lock manager is allowed to lock
     */
    function getLock(address _user, address _lockManager)
        external
        view
        isInitialized
        returns (
            uint256 _amount,
            uint256 _allowance
        )
    {
        Lock storage lock_ = accounts[_user].locks[_lockManager];
        _amount = lock_.amount;
        _allowance = lock_.allowance;
    }

    /**
     * @notice Get staked and locked balances of `_user`
     * @param _user Account being requested
     * @return Amount of staked tokens
     * @return Amount of total locked tokens
     */
    function getBalancesOf(address _user) external view isInitialized returns (uint256 staked, uint256 locked) {
        staked = _totalStakedFor(_user);
        locked = _lockedBalanceOf(_user);
    }

    /**
     * @notice Get the amount of tokens staked by `_user`
     * @param _user The owner of the tokens
     * @return The amount of tokens staked by the given account
     */
    function totalStakedFor(address _user) external view isInitialized returns (uint256) {
        return _totalStakedFor(_user);
    }

    /**
     * @notice Get the total amount of tokens staked by all users
     * @return The total amount of tokens staked by all users
     */
    function totalStaked() external view isInitialized returns (uint256) {
        return _totalStaked();
    }

    /**
     * @notice Get the total amount of tokens staked by `_user` at block number `_blockNumber`
     * @param _user Account requesting for
     * @param _blockNumber Block number at which we are requesting
     * @return The amount of tokens staked by the account at the given block number
     */
    function totalStakedForAt(address _user, uint256 _blockNumber) external view isInitialized returns (uint256) {
        require(_blockNumber <= MAX_UINT64, ERROR_BLOCKNUMBER_TOO_BIG);

        return accounts[_user].stakedHistory.get(uint64(_blockNumber));
    }

    /**
     * @notice Get the total amount of tokens staked by all users at block number `_blockNumber`
     * @param _blockNumber Block number at which we are requesting
     * @return The amount of tokens staked at the given block number
     */
    function totalStakedAt(uint256 _blockNumber) external view isInitialized returns (uint256) {
        require(_blockNumber <= MAX_UINT64, ERROR_BLOCKNUMBER_TOO_BIG);

        return totalStakedHistory.get(uint64(_blockNumber));
    }

    /**
     * @notice Get the staked but unlocked amount of tokens by `_user`
     * @param _user Owner of the staked but unlocked balance
     * @return Amount of tokens staked but not locked by given account
     */
    function unlockedBalanceOf(address _user) external view isInitialized returns (uint256) {
        return _unlockedBalanceOf(_user);
    }

    /**
     * @notice Check if `_sender` can unlock `_user`'s `@tokenAmount(self.token(): address, _amount)` locked by `_lockManager`
     * @param _sender Account that would try to unlock tokens
     * @param _user Owner of lock
     * @param _lockManager Manager of the lock for the given owner
     * @param _amount Amount of tokens to be potentially unlocked. If zero, it means the whole locked amount
     * @return Whether given lock of given owner can be unlocked by given sender
     */
    function canUnlock(address _sender, address _user, address _lockManager, uint256 _amount) external view isInitialized returns (bool) {
        return _canUnlockUnsafe(_sender, _user, _lockManager, _amount);
    }

    function _stakeFor(address _from, address _user, uint256 _amount, bytes memory _data) internal {
        // staking 0 tokens is invalid
        require(_amount > 0, ERROR_AMOUNT_ZERO);

        // checkpoint updated staking balance
        uint256 newStake = _modifyStakeBalance(_user, _amount, true);

        // checkpoint total supply
        _modifyTotalStaked(_amount, true);

        // pull tokens into Staking contract
        require(stakingToken.safeTransferFrom(_from, address(this), _amount), ERROR_TOKEN_DEPOSIT);

        emit Staked(_user, _amount, newStake, _data);
    }

    function _unstake(address _from, uint256 _amount, bytes memory _data) internal {
        // checkpoint updated staking balance
        uint256 newStake = _modifyStakeBalance(_from, _amount, false);

        // checkpoint total supply
        _modifyTotalStaked(_amount, false);

        // transfer tokens
        require(stakingToken.safeTransfer(_from, _amount), ERROR_TOKEN_TRANSFER);

        emit Unstaked(_from, _amount, newStake, _data);
    }

    function _modifyStakeBalance(address _user, uint256 _by, bool _increase) internal returns (uint256) {
        uint256 currentStake = _totalStakedFor(_user);

        uint256 newStake;
        if (_increase) {
            newStake = currentStake.add(_by);
        } else {
            require(_by <= _unlockedBalanceOf(_user), ERROR_NOT_ENOUGH_BALANCE);
            newStake = currentStake.sub(_by);
        }

        // add new value to account history
        accounts[_user].stakedHistory.add(getBlockNumber64(), newStake);

        return newStake;
    }

    function _modifyTotalStaked(uint256 _by, bool _increase) internal {
        uint256 currentStake = _totalStaked();

        uint256 newStake;
        if (_increase) {
            newStake = currentStake.add(_by);
        } else {
            newStake = currentStake.sub(_by);
        }

        // add new value to total history
        totalStakedHistory.add(getBlockNumber64(), newStake);
    }

    function _allowManager(address _lockManager, uint256 _allowance, bytes memory _data) internal {
        Lock storage lock_ = accounts[msg.sender].locks[_lockManager];
        // check if lock exists
        require(lock_.allowance == 0, ERROR_LOCK_ALREADY_EXISTS);

        emit NewLockManager(msg.sender, _lockManager, _data);

        _increaseLockAllowance(_lockManager, lock_, _allowance);
    }

    function _increaseLockAllowance(address _lockManager, Lock storage _lock, uint256 _allowance) internal {
        require(_allowance > 0, ERROR_AMOUNT_ZERO);

        _lock.allowance = _lock.allowance.add(_allowance);

        emit LockAllowanceChanged(msg.sender, _lockManager, _allowance, true);
    }

    /**
     * @dev Assumes that sender is either owner or lock manager
     */
    function _lockUnsafe(address _user, address _lockManager, uint256 _amount) internal {
        require(_amount > 0, ERROR_AMOUNT_ZERO);

        // check enough unlocked tokens are available
        require(_amount <= _unlockedBalanceOf(_user), ERROR_NOT_ENOUGH_BALANCE);

        Account storage account = accounts[_user];
        Lock storage lock_ = account.locks[_lockManager];

        uint256 newAmount = lock_.amount.add(_amount);
        // check allowance is enough, it also means that lock exists, as newAmount is greater than zero
        require(newAmount <= lock_.allowance, ERROR_NOT_ENOUGH_ALLOWANCE);

        lock_.amount = newAmount;

        // update total
        account.totalLocked = account.totalLocked.add(_amount);

        emit LockAmountChanged(_user, _lockManager, _amount, true);
    }

    /**
     * @dev Assumes `canUnlock` passes
     */
    function _unlockUnsafe(address _user, address _lockManager, uint256 _amount) internal {
        Account storage account = accounts[_user];
        Lock storage lock_ = account.locks[_lockManager];

        uint256 lockAmount = lock_.amount;
        require(lockAmount >= _amount, ERROR_NOT_ENOUGH_LOCK);

        // update lock amount
        // No need for SafeMath: checked just above
        lock_.amount = lockAmount - _amount;

        // update total
        account.totalLocked = account.totalLocked.sub(_amount);

        emit LockAmountChanged(_user, _lockManager, _amount, false);
    }

    function _transfer(address _from, address _to, uint256 _amount) internal {
        // transferring 0 staked tokens is invalid
        require(_amount > 0, ERROR_AMOUNT_ZERO);

        // update stakes
        _modifyStakeBalance(_from, _amount, false);
        _modifyStakeBalance(_to, _amount, true);

        emit StakeTransferred(_from, _to, _amount);
    }

    /**
     * @notice Get the amount of tokens staked by `_user`
     * @param _user The owner of the tokens
     * @return The amount of tokens staked by the given account
     */
    function _totalStakedFor(address _user) internal view returns (uint256) {
        // we assume it's not possible to stake in the future
        return accounts[_user].stakedHistory.getLast();
    }

    /**
     * @notice Get the total amount of tokens staked by all users
     * @return The total amount of tokens staked by all users
     */
    function _totalStaked() internal view returns (uint256) {
        // we assume it's not possible to stake in the future
        return totalStakedHistory.getLast();
    }

    /**
     * @notice Get the staked but unlocked amount of tokens by `_user`
     * @param _user Owner of the staked but unlocked balance
     * @return Amount of tokens staked but not locked by given account
     */
    function _unlockedBalanceOf(address _user) internal view returns (uint256) {
        return _totalStakedFor(_user).sub(_lockedBalanceOf(_user));
    }

    function _lockedBalanceOf(address _user) internal view returns (uint256) {
        return accounts[_user].totalLocked;
    }

    /**
     * @notice Check if `_sender` can unlock `_user`'s `@tokenAmount(self.token(): address, _amount)` locked by `_lockManager`
     * @dev If calling this from a state modifying function trying to unlock tokens, make sure first parameter is `msg.sender`
     * @param _sender Account that would try to unlock tokens
     * @param _user Owner of lock
     * @param _lockManager Manager of the lock for the given owner
     * @param _amount Amount of locked tokens to unlock. If zero, the full locked amount
     * @return Whether given lock of given owner can be unlocked by given sender
     */
    function _canUnlockUnsafe(address _sender, address _user, address _lockManager, uint256 _amount) internal view returns (bool) {
        Lock storage lock_ = accounts[_user].locks[_lockManager];
        require(lock_.allowance > 0, ERROR_LOCK_DOES_NOT_EXIST);
        require(lock_.amount >= _amount, ERROR_NOT_ENOUGH_LOCK);

        uint256 amount = _amount == 0 ? lock_.amount : _amount;

        // If the sender is the lock manager, unlocking is allowed
        if (_sender == _lockManager) {
            return true;
        }

        // If the sender is neither the lock manager nor the owner, unlocking is not allowed
        if (_sender != _user) {
            return false;
        }

        // The sender must therefore be the owner of the tokens
        // Allow unlocking if the amount of locked tokens has already been decreased to 0
        if (amount == 0) {
            return true;
        }

        // Otherwise, check whether the lock manager allows unlocking
        return ILockManager(_lockManager).canUnlock(_user, amount);
    }

    function _toBytes4(bytes memory _data) internal pure returns (bytes4 result) {
        if (_data.length < 4) {
            return bytes4(0);
        }

        assembly { result := mload(add(_data, 0x20)) }
    }
}

// File: contracts/lib/os/ERCProxy.sol

// Brought from https://github.com/aragon/aragonOS/blob/v4.3.0/contracts/lib/misc/ERCProxy.sol
// Adapted to use pragma ^0.5.17 and satisfy our linter rules

//pragma solidity ^0.5.17;
pragma solidity >=0.5 <0.7.17;


contract ERCProxy {
    uint256 internal constant FORWARDING = 1;
    uint256 internal constant UPGRADEABLE = 2;

    function proxyType() public pure returns (uint256 proxyTypeId);
    function implementation() public view returns (address codeAddr);
}

// File: contracts/lib/os/DelegateProxy.sol

// Brought from https://github.com/aragon/aragonOS/blob/v4.3.0/contracts/common/Autopetrified.sol
// Adapted to use pragma ^0.5.17 and satisfy our linter rules

//pragma solidity 0.5.17;
pragma solidity >=0.5 <0.7.17;




contract DelegateProxy is ERCProxy, IsContract {
    uint256 internal constant FWD_GAS_LIMIT = 10000;

    /**
    * @dev Performs a delegatecall and returns whatever the delegatecall returned (entire context execution will return!)
    * @param _dst Destination address to perform the delegatecall
    * @param _calldata Calldata for the delegatecall
    */
    function delegatedFwd(address _dst, bytes memory _calldata) internal {
        require(isContract(_dst));
        uint256 fwdGasLimit = FWD_GAS_LIMIT;

        assembly {
            let result := delegatecall(sub(gas, fwdGasLimit), _dst, add(_calldata, 0x20), mload(_calldata), 0, 0)
            let size := returndatasize
            let ptr := mload(0x40)
            returndatacopy(ptr, 0, size)

            // revert instead of invalid() bc if the underlying call failed with invalid() it already wasted gas.
            // if the call returned error data, forward it
            switch result case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
    }
}

// File: contracts/proxies/ThinProxy.sol

//pragma solidity ^0.5.17;
pragma solidity >=0.5 <0.7.17;




contract ThinProxy is DelegateProxy {
    using UnstructuredStorage for bytes32;

    constructor(address _implementation) public {
        _implementationSlot().setStorageAddress(_implementation);
    }

    function () external {
        delegatedFwd(implementation(), msg.data);
    }

    function proxyType() public pure returns (uint256) {
        return FORWARDING;
    }

    function implementation() public view returns (address) {
        return _implementationSlot().getStorageAddress();
    }

    function _implementationSlot() internal pure returns (bytes32);
}

// File: contracts/proxies/StakingProxy.sol

//pragma solidity ^0.5.17;
pragma solidity >=0.5 <0.7.17;





contract StakingProxy is ThinProxy {
    // keccak256("aragon.network.staking")
    bytes32 internal constant IMPLEMENTATION_SLOT = 0xbd536e2e005accda865e2f0d1827f83ec8824f3ea04ecd6131b7c10058635814;

    constructor(Staking _implementation, ERC20 _token) ThinProxy(address(_implementation)) public {
        bytes4 selector = _implementation.initialize.selector;
        bytes memory initializeData = abi.encodeWithSelector(selector, _token);
        (bool success,) = address(_implementation).delegatecall(initializeData);

        if (!success) {
            assembly {
                let output := mload(0x40)
                mstore(0x40, add(output, returndatasize))
                returndatacopy(output, 0, returndatasize)
                revert(output, returndatasize)
            }
        }
    }

    function _implementationSlot() internal pure returns (bytes32) {
        return IMPLEMENTATION_SLOT;
    }
}

// File: contracts/StakingFactory.sol

//pragma solidity ^0.5.17;
pragma solidity >=0.5 <0.7.17;





contract StakingFactory {
    Staking public baseImplementation;
    mapping (address => address) internal instances;

    event NewStaking(address indexed instance, address token);

    constructor() public {
        baseImplementation = new Staking();
    }

    function existsInstance(ERC20 token) external view returns (bool) {
        return _getInstance(token) != address(0);
    }

    function getInstance(ERC20 token) external view returns (Staking) {
        return Staking(_getInstance(token));
    }

    function getOrCreateInstance(ERC20 token) external returns (Staking) {
        address instance = _getInstance(token);
        return instance != address(0) ? Staking(instance) : _createInstance(token);
    }

    function _getInstance(ERC20 token) internal view returns (address) {
        return instances[address(token)];
    }

    function _createInstance(ERC20 token) internal returns (Staking) {
        StakingProxy instance = new StakingProxy(baseImplementation, token);
        address tokenAddress = address(token);
        address instanceAddress = address(instance);
        instances[tokenAddress] = instanceAddress;
        emit NewStaking(instanceAddress, tokenAddress);
        return Staking(instanceAddress);
    }
}
