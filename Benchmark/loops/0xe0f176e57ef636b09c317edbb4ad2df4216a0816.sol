/**
 *Submitted for verification at Etherscan.io on 2019-08-05
*/

// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol

//pragma solidity ^0.5.9;
pragma solidity >=0.5 <0.7.17;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see `ERC20Detailed`.
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
     * Emits a `Transfer` event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through `transferFrom`. This is
     * zero by default.
     *
     * This value changes when `approve` or `transferFrom` are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
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
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a `Transfer` event.
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
     * a call to `approve`. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: openzeppelin-solidity/contracts/math/SafeMath.sol


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
        require(b <= a, "SafeMath: subtraction overflow");
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
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
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
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
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
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

// File: openzeppelin-solidity/contracts/utils/Address.sol


/**
 * @dev Collection of functions related to the address type,
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * This test is non-exhaustive, and there may be false-negatives: during the
     * execution of a contract's constructor, its address will be reported as
     * not containing a contract.
     *
     * > It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies in extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}

// File: openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol


/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves.

        // A Solidity high level call has three parts:
        //  1. The target address is checked to verify it contains contract code
        //  2. The call itself is made, and success asserted
        //  3. The return value is decoded, which in turn checks the size of the returned data.
        // solhint-disable-next-line max-line-length
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// File: contracts/openzeppelin/TokenTimelock.sol


/**
 * @title TokenTimelock
 * @dev TokenTimelock is a token holder contract that will allow a
 * beneficiary to extract the tokens after a given release time.
 */
contract TokenTimelock {
    using SafeERC20 for IERC20;

    // ERC20 basic token contract being held
    IERC20 private _token;

    // beneficiary of tokens after they are released
    address private _beneficiary;

    // timestamp when token release is enabled
    uint256 private _releaseTime;

    constructor (IERC20 token, address beneficiary, uint256 releaseTime) public {
        // solhint-disable-next-line not-rely-on-time
        require(releaseTime > block.timestamp, "TokenTimelock: release time is before current time");
        _token = token;
        _beneficiary = beneficiary;
        _releaseTime = releaseTime;
    }

    /**
     * @return the token being held.
     */
    function token() public view returns (IERC20) {
        return _token;
    }

    /**
     * @return the beneficiary of the tokens.
     */
    function beneficiary() public view returns (address) {
        return _beneficiary;
    }

    /**
     * @return the time when the tokens are released.
     */
    function releaseTime() public view returns (uint256) {
        return _releaseTime;
    }

    /**
     * @notice Transfers tokens held by timelock to beneficiary.
     */
    function release() public {
        // solhint-disable-next-line not-rely-on-time
        require(block.timestamp >= _releaseTime, "TokenTimelock: current time is before release time");

        uint256 amount = _token.balanceOf(address(this));
        require(amount > 0, "TokenTimelock: no tokens to release");

        _token.safeTransfer(_beneficiary, amount);
    }

     /**
     * @return change the beneficiary of tokens
     */

    function _changeBeneficiary(address _newBeneficiary) internal {
        _beneficiary = _newBeneficiary;
    }
}

// File: contracts/helpers/BeneficiaryOperations.sol

/*
  License: MIT
  Copyright Bitclave, 2018
  It's modified contract BeneficiaryOperations from https://github.com/bitclave/BeneficiaryOperations
*/


contract BeneficiaryOperations {

    using SafeMath for uint256;

    using SafeMath for uint8;
    // VARIABLES

    uint256 public beneficiariesGeneration;
    uint256 public howManyBeneficiariesDecide;
    address[] public beneficiaries;
    bytes32[] public allOperations;
    address internal insideCallSender;
    uint256 internal insideCallCount;
    

    // Reverse lookup tables for beneficiaries and allOperations
    mapping(address => uint8) public beneficiariesIndices; // Starts from 1, size 255
    mapping(bytes32 => uint) public allOperationsIndicies;
    

    // beneficiaries voting mask per operations
    mapping(bytes32 => uint256) public votesMaskByOperation;
    mapping(bytes32 => uint256) public votesCountByOperation;

    //operation -> beneficiaryIndex
    mapping(bytes32 => uint8) internal  operationsByBeneficiaryIndex;
    mapping(uint8 => uint8) internal operationsCountByBeneficiaryIndex;
    // EVENTS

    event BeneficiaryshipTransferred(address[] previousbeneficiaries, uint howManyBeneficiariesDecide, address[] newBeneficiaries, uint newHowManybeneficiarysDecide);
    event OperationCreated(bytes32 operation, uint howMany, uint beneficiariesCount, address proposer);
    event OperationUpvoted(bytes32 operation, uint votes, uint howMany, uint beneficiariesCount, address upvoter);
    event OperationPerformed(bytes32 operation, uint howMany, uint beneficiariesCount, address performer);
    event OperationDownvoted(bytes32 operation, uint votes, uint beneficiariesCount,  address downvoter);
    event OperationCancelled(bytes32 operation, address lastCanceller);
    
    // ACCESSORS

    function isExistBeneficiary(address wallet) public view returns(bool) {
        return beneficiariesIndices[wallet] > 0;
    }


    function beneficiariesCount() public view returns(uint) {
        return beneficiaries.length;
    }

    function allOperationsCount() public view returns(uint) {
        return allOperations.length;
    }

    /*
      Internal functions
    */

    function _operationLimitByBeneficiaryIndex(uint8 beneficiaryIndex) internal view returns(bool) {
        return (operationsCountByBeneficiaryIndex[beneficiaryIndex] <= 3);
    }
    
    function _cancelAllPending() internal {
        for (uint i = 0; i < allOperations.length; i++) {
            delete(allOperationsIndicies[allOperations[i]]);
            delete(votesMaskByOperation[allOperations[i]]);
            delete(votesCountByOperation[allOperations[i]]);
            //delete operation->beneficiaryIndex
            delete(operationsByBeneficiaryIndex[allOperations[i]]);
        }

        allOperations.length = 0;
        //delete operations count for beneficiary
        for (uint8 j = 0; j < beneficiaries.length; j++) {
            operationsCountByBeneficiaryIndex[j] = 0;
        }
    }


    // MODIFIERS

    /**
    * @dev Allows to perform method by any of the beneficiaries
    */
    modifier onlyAnyBeneficiary {
        if (checkHowManyBeneficiaries(1)) {
            bool update = (insideCallSender == address(0));
            if (update) {
                insideCallSender = msg.sender;
                insideCallCount = 1;
            }
            _;
            if (update) {
                insideCallSender = address(0);
                insideCallCount = 0;
            }
        }
    }

    /**
    * @dev Allows to perform method only after many beneficiaries call it with the same arguments
    */
    modifier onlyManyBeneficiaries {
        if (checkHowManyBeneficiaries(howManyBeneficiariesDecide)) {
            bool update = (insideCallSender == address(0));
            if (update) {
                insideCallSender = msg.sender;
                insideCallCount = howManyBeneficiariesDecide;
            }
            _;
            if (update) {
                insideCallSender = address(0);
                insideCallCount = 0;
            }
        }
    }

    /**
    * @dev Allows to perform method only after all beneficiaries call it with the same arguments
    */
    modifier onlyAllBeneficiaries {
        if (checkHowManyBeneficiaries(beneficiaries.length)) {
            bool update = (insideCallSender == address(0));
            if (update) {
                insideCallSender = msg.sender;
                insideCallCount = beneficiaries.length;
            }
            _;
            if (update) {
                insideCallSender = address(0);
                insideCallCount = 0;
            }
        }
    }

    /**
    * @dev Allows to perform method only after some beneficiaries call it with the same arguments
    */
    modifier onlySomeBeneficiaries(uint howMany) {
        require(howMany > 0, "onlySomeBeneficiaries: howMany argument is zero");
        require(howMany <= beneficiaries.length, "onlySomeBeneficiaries: howMany argument exceeds the number of Beneficiaries");
        
        if (checkHowManyBeneficiaries(howMany)) {
            bool update = (insideCallSender == address(0));
            if (update) {
                insideCallSender = msg.sender;
                insideCallCount = howMany;
            }
            _;
            if (update) {
                insideCallSender = address(0);
                insideCallCount = 0;
            }
        }
    }

    // CONSTRUCTOR

    constructor() public {
        beneficiaries.push(msg.sender);
        beneficiariesIndices[msg.sender] = 1;
        howManyBeneficiariesDecide = 1;
    }

    // INTERNAL METHODS

    /**
     * @dev onlyManybeneficiaries modifier helper
     */
    function checkHowManyBeneficiaries(uint howMany) internal returns(bool) {
        if (insideCallSender == msg.sender) {
            require(howMany <= insideCallCount, "checkHowManyBeneficiaries: nested beneficiaries modifier check require more beneficiarys");
            return true;
        }
        
        
        require((isExistBeneficiary(msg.sender) && (beneficiariesIndices[msg.sender] <= beneficiaries.length)), "checkHowManyBeneficiaries: msg.sender is not an beneficiary");

        uint beneficiaryIndex = beneficiariesIndices[msg.sender].sub(1);
        
        bytes32 operation = keccak256(abi.encodePacked(msg.data, beneficiariesGeneration));

        require((votesMaskByOperation[operation] & (2 ** beneficiaryIndex)) == 0, "checkHowManyBeneficiaries: beneficiary already voted for the operation");
        //check limit for operation
        require(_operationLimitByBeneficiaryIndex(uint8(beneficiaryIndex)), "checkHowManyBeneficiaries: operation limit is reached for this beneficiary");

        votesMaskByOperation[operation] |= (2 ** beneficiaryIndex);
        uint operationVotesCount = votesCountByOperation[operation].add(1);
        votesCountByOperation[operation] = operationVotesCount;

        if (operationVotesCount == 1) {
            allOperationsIndicies[operation] = allOperations.length;
            
            operationsByBeneficiaryIndex[operation] = uint8(beneficiaryIndex);
            
            operationsCountByBeneficiaryIndex[uint8(beneficiaryIndex)] = uint8(operationsCountByBeneficiaryIndex[uint8(beneficiaryIndex)].add(1));
            
            allOperations.push(operation);
            
            
            emit OperationCreated(operation, howMany, beneficiaries.length, msg.sender);
        }
        emit OperationUpvoted(operation, operationVotesCount, howMany, beneficiaries.length, msg.sender);

        // If enough beneficiaries confirmed the same operation
        if (votesCountByOperation[operation] == howMany) {
            deleteOperation(operation);
            emit OperationPerformed(operation, howMany, beneficiaries.length, msg.sender);
            return true;
        }

        return false;
    }

    /**
    * @dev Used to delete cancelled or performed operation
    * @param operation defines which operation to delete
    */
    function deleteOperation(bytes32 operation) internal {
        uint index = allOperationsIndicies[operation];
        if (index < allOperations.length - 1) { // Not last
            allOperations[index] = allOperations[allOperations.length.sub(1)];
            allOperationsIndicies[allOperations[index]] = index;
        }
        allOperations.length = allOperations.length.sub(1);

        uint8 beneficiaryIndex = uint8(operationsByBeneficiaryIndex[operation]);
        operationsCountByBeneficiaryIndex[beneficiaryIndex] = uint8(operationsCountByBeneficiaryIndex[beneficiaryIndex].sub(1));

        delete votesMaskByOperation[operation];
        delete votesCountByOperation[operation];
        delete allOperationsIndicies[operation];
        delete operationsByBeneficiaryIndex[operation];
    }

    // PUBLIC METHODS

    /**
    * @dev Allows beneficiaries to change their mind by cancelling votesMaskByOperation operations
    * @param operation defines which operation to delete
    */
    function cancelPending(bytes32 operation) public onlyAnyBeneficiary {

        require((isExistBeneficiary(msg.sender) && (beneficiariesIndices[msg.sender] <= beneficiaries.length)), "checkHowManyBeneficiaries: msg.sender is not an beneficiary");

        uint beneficiaryIndex = beneficiariesIndices[msg.sender].sub(1);
        require((votesMaskByOperation[operation] & (2 ** beneficiaryIndex)) != 0, "cancelPending: operation not found for this user");
        votesMaskByOperation[operation] &= ~(2 ** beneficiaryIndex);
        uint operationVotesCount = votesCountByOperation[operation].sub(1);
        votesCountByOperation[operation] = operationVotesCount;
        emit OperationDownvoted(operation, operationVotesCount, beneficiaries.length, msg.sender);
        if (operationVotesCount == 0) {
            deleteOperation(operation);
            emit OperationCancelled(operation, msg.sender);
        }
    }

    /**
    * @dev Allows beneficiaries to change their mind by cancelling all operations
    */

    function cancelAllPending() public onlyManyBeneficiaries {
       _cancelAllPending();
    }



    /**Переписать*/

    /**
    * @dev Allows beneficiaries to change beneficiariesship
    * @param newBeneficiaries defines array of addresses of new beneficiaries
    */
    function transferBeneficiaryShip(address[] memory newBeneficiaries) public {
        transferBeneficiaryShipWithHowMany(newBeneficiaries, newBeneficiaries.length);
    }

    /**
    * @dev Allows beneficiaries to change beneficiaryShip
    * @param newBeneficiaries defines array of addresses of new beneficiaries
    * @param newHowManyBeneficiariesDecide defines how many beneficiaries can decide
    */
    function transferBeneficiaryShipWithHowMany(address[] memory newBeneficiaries, uint256 newHowManyBeneficiariesDecide) public onlyManyBeneficiaries {
        require(newBeneficiaries.length > 0, "transferBeneficiaryShipWithHowMany: beneficiaries array is empty");
        require(newBeneficiaries.length < 256, "transferBeneficiaryshipWithHowMany: beneficiaries count is greater then 255");
        require(newHowManyBeneficiariesDecide > 0, "transferBeneficiaryshipWithHowMany: newHowManybeneficiarysDecide equal to 0");
        require(newHowManyBeneficiariesDecide <= newBeneficiaries.length, "transferBeneficiaryShipWithHowMany: newHowManybeneficiarysDecide exceeds the number of beneficiarys");

        // Reset beneficiaries reverse lookup table
        for (uint j = 0; j < beneficiaries.length; j++) {
            delete beneficiariesIndices[beneficiaries[j]];
        }
        for (uint i = 0; i < newBeneficiaries.length; i++) {
            require(newBeneficiaries[i] != address(0), "transferBeneficiaryShipWithHowMany: beneficiaries array contains zero");
            require(beneficiariesIndices[newBeneficiaries[i]] == 0, "transferBeneficiaryShipWithHowMany: beneficiaries array contains duplicates");
            beneficiariesIndices[newBeneficiaries[i]] = uint8(i.add(1));
        }
        
        emit BeneficiaryshipTransferred(beneficiaries, howManyBeneficiariesDecide, newBeneficiaries, newHowManyBeneficiariesDecide);
        beneficiaries = newBeneficiaries;
        howManyBeneficiariesDecide = newHowManyBeneficiariesDecide;

        _cancelAllPending();
       
        beneficiariesGeneration++;
    }
}

// File: contracts/logics/AkropolisTimeLock.sol


//Beneficieries template


contract AkropolisTimeLock is TokenTimelock, BeneficiaryOperations {

        address private _pendingBeneficiary;


        event LogBeneficiaryTransferProposed(address _beneficiary);
        event LogBeneficiaryTransfered(address _beneficiary);

        /**
        * @notice Constructor.
        * @param _token  Address of AKRO token
        * @param _releaseTime Timestamp date
        */

        constructor (IERC20 _token, uint256 _releaseTime) public
            TokenTimelock(_token, msg.sender, _releaseTime) {
        }  

        // MODIFIERS
        /**
        * @dev Allows to perform method by existing beneficiary
        */
        modifier onlyExistingBeneficiary(address _beneficiary) {
            require(isExistBeneficiary(_beneficiary), "address is not in beneficiary array");
             _;
        }

        /**
        * @dev Allows to perform method by pending beneficiary
        */
        modifier onlyPendingBeneficiary {
            require(msg.sender  == _pendingBeneficiary, "Unpermitted operation.");
            _;
        }

        function pendingBeneficiary() public view returns (address) {
            return _pendingBeneficiary;
        }

        /**
            * @dev Allows beneficiaries to change beneficiaryShip and set first beneficiary as default
            * @param _newBeneficiaries defines array of addresses of new beneficiaries
            * @param _newHowManyBeneficiariesDecide defines how many beneficiaries can decide
        */
        function transferBeneficiaryShipWithHowMany(address[] memory _newBeneficiaries, uint256 _newHowManyBeneficiariesDecide) public {
            super.transferBeneficiaryShipWithHowMany(_newBeneficiaries, _newHowManyBeneficiariesDecide);
            _setPendingBeneficiary(beneficiaries[0]);
        }

         /**
            * @dev Allows beneficiaries to change beneficiaryShip and set first beneficiary as default
            * @param _newBeneficiaries defines array of addresses of new beneficiaries
        */

        function transferBeneficiaryShip(address[] memory _newBeneficiaries) public {
            super.transferBeneficiaryShip(_newBeneficiaries);
            _setPendingBeneficiary(beneficiaries[0]);
        }

        /**
            * @dev Allows beneficiaries to change beneficiary as default
            * @param _newBeneficiary defines address of new beneficiary
        */
        function changeBeneficiary(address _newBeneficiary) public onlyManyBeneficiaries {
            _setPendingBeneficiary(_newBeneficiary);
        }

        /**
            * @dev Claim Beneficiary
        */
        function claimBeneficiary() public onlyPendingBeneficiary {
            _changeBeneficiary(_pendingBeneficiary);
            emit LogBeneficiaryTransfered(_pendingBeneficiary);
            _pendingBeneficiary = address(0);
        }

        /*
        * Internal Functions
        *
        */
        /**
            * @dev Set pending Beneficiary address
            * @param _newBeneficiary defines address of new beneficiary
        */
        function _setPendingBeneficiary(address _newBeneficiary) internal onlyExistingBeneficiary(_newBeneficiary) {
            _pendingBeneficiary = _newBeneficiary;
            emit LogBeneficiaryTransferProposed(_newBeneficiary);
        }
}
