/**
 *Submitted for verification at Etherscan.io on 2020-09-19
*/

//pragma solidity 0.5.12;
pragma solidity >=0.5 <0.7.17;


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be aplied to your functions to restrict their use to
 * the owner.
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
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
        return msg.sender == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * > Note: Renouncing ownership will leave the contract without an owner,
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

interface IERC677MultiBridgeToken {
    function transfer(address _to, uint256 _value) external returns (bool);
    function transferDistribution(address _to, uint256 _value) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);
    function balanceOf(address _account) external view returns (uint256);
}

interface IMultipleDistribution {
    function initialize(address _tokenAddress) external;
    function poolStake() external view returns (uint256);
}

interface IDistribution {
    function supply() external view returns(uint256);
    function poolAddress(uint8) external view returns(address);
}

/// @dev Distributes STAKE tokens for Private Offering and Advisors Reward.
contract MultipleDistribution is Ownable, IMultipleDistribution {
    using SafeMath for uint256;
    using Address for address;

    /// @dev Emits when `initialize` method has been called.
    /// @param token The address of ERC677MultiBridgeToken contract.
    /// @param caller The address of the caller.
    event Initialized(address token, address caller);

    /// @dev Emits when the `Distribution` address has been set.
    /// @param distribution `Distribution` contract address.
    /// @param caller The address of the caller.
    event DistributionAddressSet(address distribution, address caller);

    /// @dev Emits when `withdraw` method has been called.
    /// @param recipient Recipient address.
    /// @param value Transferred value.
    event Withdrawn(address recipient, uint256 value);

    /// @dev Emits when `burn` method has been called.
    /// @param value Burnt value.
    event Burnt(uint256 value);

    /// @dev Emits when `addParticipants` method has been called.
    /// @param participants Participants addresses.
    /// @param stakes Participants stakes.
    /// @param caller The address of the caller.
    event ParticipantsAdded(address[] participants, uint256[] stakes, address caller);

    /// @dev Emits when `editParticipant` method has been called.
    /// @param participant Participant address.
    /// @param oldStake Old participant stake.
    /// @param newStake New participant stake.
    /// @param caller The address of the caller.
    event ParticipantEdited(address participant, uint256 oldStake, uint256 newStake, address caller);

    /// @dev Emits when `removeParticipant` method has been called.
    /// @param participant Participant address.
    /// @param stake Participant stake.
    /// @param caller The address of the caller.
    event ParticipantRemoved(address participant, uint256 stake, address caller);

    /// @dev Emits when `finalizeParticipants` method has been called.
    /// @param numberOfParticipants Number of participants.
    /// @param caller The address of the caller.
    event ParticipantsFinalized(uint256 numberOfParticipants, address caller);

    uint256 public TOTAL_STAKE;
    uint8 public POOL_NUMBER;

    /// @dev The instance of ERC677MultiBridgeToken contract.
    IERC677MultiBridgeToken public token;

    /// @dev Distribution contract address.
    address public distributionAddress;

    /// @dev Participants addresses.
    address[] public participants;

    /// @dev Stake for a specified participant.
    mapping (address => uint256) public participantStake;

    /// @dev Amount of tokens that have already been withdrawn by a specified participant.
    mapping (address => uint256) public paidAmount;

    /// @dev Contains max balance (sum of all installments).
    uint256 public maxBalance = 0;

    /// @dev Boolean variable that indicates whether the contract was initialized.
    bool public isInitialized = false;

    /// @dev Boolean variable that indicates whether the participant set was finalized.
    bool public isFinalized = false;

    /// @dev Contains current sum of stakes.
    uint256 public sumOfStakes = 0;

    /// @dev Checks that the contract is initialized.
    modifier initialized() {
        require(isInitialized, "not initialized");
        _;
    }

    /// @dev Checks that the participant set is not finalized.
    modifier notFinalized() {
        require(!isFinalized, "already finalized");
        _;
    }

    constructor(uint8 _pool) public {
        require(_pool == 3 || _pool == 4, "wrong pool number");
        POOL_NUMBER = _pool;

        if (POOL_NUMBER == 3) {
            TOTAL_STAKE = 1970951 ether; // Private Offering supply. `ether` is used as the token has 18 decimals
        } else {
            TOTAL_STAKE = 651000 ether; // Advisors Reward supply. `ether` is used as the token has 18 decimals
        }
    }

    /// @dev Adds participants. This function doesn't limit max gas consumption,
    /// so adding too many participants can cause it to reach the out-of-gas error.
    /// @param _participants The addresses of new participants.
    /// @param _stakes The amounts of the tokens that belong to each participant.
    function addParticipants(
        address[] calldata _participants,
        uint256[] calldata _stakes
    ) external onlyOwner notFinalized {
        require(_participants.length == _stakes.length, "different arrays sizes");
        for (uint256 i = 0; i < _participants.length; i++) {
            require(_participants[i] != address(0), "invalid address");
            require(_stakes[i] > 0, "the participant stake must be more than 0");
            require(participantStake[_participants[i]] == 0, "participant already added");
            participants.push(_participants[i]);
            participantStake[_participants[i]] = _stakes[i];
            sumOfStakes = sumOfStakes.add(_stakes[i]);
        }
        require(sumOfStakes <= TOTAL_STAKE, "wrong sum of values");
        emit ParticipantsAdded(_participants, _stakes, msg.sender);
    }

    /// @dev Edits participant stake.
    /// @param _participant Participant address.
    /// @param _newStake New stake of the participant.
    function editParticipant(
        address _participant,
        uint256 _newStake
    ) external onlyOwner notFinalized {
        require(_participant != address(0), "invalid address");

        uint256 oldStake = participantStake[_participant];
        require(oldStake > 0, "the participant doesn't exist");
        require(_newStake > 0, "the participant stake must be more than 0");

        sumOfStakes = sumOfStakes.sub(oldStake).add(_newStake);
        require(sumOfStakes <= TOTAL_STAKE, "wrong sum of values");
        participantStake[_participant] = _newStake;

        emit ParticipantEdited(_participant, oldStake, _newStake, msg.sender);
    }

    /// @dev Removes participant. This function doesn't limit max gas consumption,
    /// so having too many participants can cause it to reach the out-of-gas error.
    /// @param _participant Participant address.
    function removeParticipant(
        address _participant
    ) external onlyOwner notFinalized {
        require(_participant != address(0), "invalid address");

        uint256 stake = participantStake[_participant];
        require(stake > 0, "the participant doesn't exist");

        uint256 index = 0;
        uint256 participantsLength = participants.length;
        for (uint256 i = 0; i < participantsLength; i++) {
            if (participants[i] == _participant) {
                index = i;
                break;
            }
        }
        require(participants[index] == _participant, "the participant not found");
        sumOfStakes = sumOfStakes.sub(stake);
        participantStake[_participant] = 0;

        address lastParticipant = participants[participants.length.sub(1)];
        participants[index] = lastParticipant;
        participants.length = participants.length.sub(1);

        emit ParticipantRemoved(_participant, stake, msg.sender);
    }

    /// @dev Calculates unused stake and disables the following additions/edits.
    function finalizeParticipants() external onlyOwner notFinalized {
        uint256 unusedStake = TOTAL_STAKE.sub(sumOfStakes);
        if (unusedStake > 0) {
            participants.push(address(0));
            participantStake[address(0)] = unusedStake;
        }
        isFinalized = true;
        emit ParticipantsFinalized(participants.length, msg.sender);
    }

    /// @dev Initializes the contract after the token is created.
    /// @param _tokenAddress The address of the STAKE token contract.
    function initialize(
        address _tokenAddress
    ) external {
        require(msg.sender == distributionAddress, "wrong sender");
        require(!isInitialized, "already initialized");
        require(isFinalized, "not finalized");
        require(_tokenAddress != address(0));
        token = IERC677MultiBridgeToken(_tokenAddress);
        isInitialized = true;
        emit Initialized(_tokenAddress, msg.sender);
    }

    /// @dev The removed implementation of the ownership renouncing.
    function renounceOwnership() public onlyOwner {
        revert("not implemented");
    }

    /// @dev Sets the `Distribution` contract address.
    /// @param _distributionAddress The `Distribution` contract address.
    function setDistributionAddress(address _distributionAddress) external onlyOwner {
        require(distributionAddress == address(0), "already set");
        require(
            address(this) == IDistribution(_distributionAddress).poolAddress(POOL_NUMBER),
            "wrong address"
        );
        distributionAddress = _distributionAddress;
        emit DistributionAddressSet(distributionAddress, msg.sender);
    }

    /// @dev Transfers a share to participant.
    /// Can only be called by Private Offering or Advisors Reward participant
    /// to withdraw their currently available share.
    function withdraw() external {
        uint256 amount = _withdraw(msg.sender);
        emit Withdrawn(msg.sender, amount);
    }

    /// @dev Transfers unclaimed part to address(0).
    function burn() external onlyOwner {
        uint256 amount = _withdraw(address(0));
        emit Burnt(amount);
    }

    /// @dev Updates an internal value of the balance to use it for correct
    /// share calculation (see the `_withdraw` function) and prevents transferring
    /// tokens to this contract not from the `Distribution` contract.
    /// @param _from The address from which the tokens are transferred.
    /// @param _value The amount of transferred tokens.
    function onTokenTransfer(
        address _from,
        uint256 _value,
        bytes calldata
    ) external returns (bool) {
        require(msg.sender == address(token), "the caller can only be the token contract");
        require(_from == distributionAddress, "the _from value can only be the distribution contract");
        maxBalance = maxBalance.add(_value);
        return true;
    }

    /// @dev Returns a total amount of tokens.
    function poolStake() external view returns (uint256) {
        return TOTAL_STAKE;
    }

    /// @dev Returns an array of participants.
    function getParticipants() external view returns (address[] memory) {
        return participants;
    }

    /// @dev Transfers a share to participant or unclaimed part to address(0).
    /// Used by the `withdraw` and `burn` functions.
    /// @param _recipient The address of a participant or address(0).
    function _withdraw(address _recipient) internal initialized returns(uint256) {
        uint256 stake = participantStake[_recipient];
        require(stake > 0, "you are not a participant");

        uint256 maxShare = maxBalance.mul(stake).div(TOTAL_STAKE);
        uint256 currentShare = maxShare.sub(paidAmount[_recipient]);
        require(currentShare > 0, "no tokens available to withdraw");

        paidAmount[_recipient] = paidAmount[_recipient].add(currentShare);
        token.transferDistribution(_recipient, currentShare);

        return currentShare;
    }
}
