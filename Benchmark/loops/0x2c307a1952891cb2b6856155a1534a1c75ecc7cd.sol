/**

 *Submitted for verification at Etherscan.io on 2020-06-13

*/



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

	function sub(uint256 a, uint256 b, string memory errorMessage)

		internal

		pure

		returns (uint256)

	{

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

	function div(uint256 a, uint256 b, string memory errorMessage)

		internal

		pure

		returns (uint256)

	{

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

	function mod(uint256 a, uint256 b, string memory errorMessage)

		internal

		pure

		returns (uint256)

	{

		require(b != 0, errorMessage);

		return a % b;

	}

}





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

	function transfer(address recipient, uint256 amount)

		external

		returns (bool);



	/**

	 * @dev Returns the remaining number of tokens that `spender` will be

	 * allowed to spend on behalf of `owner` through {transferFrom}. This is

	 * zero by default.

	 *

	 * This value changes when {approve} or {transferFrom} are called.

	 */

	function allowance(address owner, address spender)

		external

		view

		returns (uint256);



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

	function transferFrom(address sender, address recipient, uint256 amount)

		external

		returns (bool);



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

	event Approval(

		address indexed owner,

		address indexed spender,

		uint256 value

	);

}





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



	function safeTransfer(IERC20 token, address to, uint256 value) internal {

		callOptionalReturn(

			token,

			abi.encodeWithSelector(token.transfer.selector, to, value)

		);

	}



	function safeTransferFrom(

		IERC20 token,

		address from,

		address to,

		uint256 value

	) internal {

		callOptionalReturn(

			token,

			abi.encodeWithSelector(token.transferFrom.selector, from, to, value)

		);

	}



	function safeApprove(IERC20 token, address spender, uint256 value)

		internal

	{

		// safeApprove should only be called when setting an initial allowance,

		// or when resetting it to zero. To increase and decrease it, use

		// 'safeIncreaseAllowance' and 'safeDecreaseAllowance'

		// solhint-disable-next-line max-line-length

		require(

			(value == 0) || (token.allowance(address(this), spender) == 0),

			"SafeERC20: approve from non-zero to non-zero allowance"

		);

		callOptionalReturn(

			token,

			abi.encodeWithSelector(token.approve.selector, spender, value)

		);

	}



	function safeIncreaseAllowance(IERC20 token, address spender, uint256 value)

		internal

	{

		uint256 newAllowance = token.allowance(address(this), spender).add(

			value

		);

		callOptionalReturn(

			token,

			abi.encodeWithSelector(

				token.approve.selector,

				spender,

				newAllowance

			)

		);

	}



	function safeDecreaseAllowance(IERC20 token, address spender, uint256 value)

		internal

	{

		uint256 newAllowance = token.allowance(address(this), spender).sub(

			value

		);

		callOptionalReturn(

			token,

			abi.encodeWithSelector(

				token.approve.selector,

				spender,

				newAllowance

			)

		);

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

		// TODO: implement later

		// require(address(token).isContract(), "SafeERC20: call to non-contract");



		// solhint-disable-next-line avoid-low-level-calls

		(bool success, bytes memory returndata) = address(token).call(data);

		require(success, "SafeERC20: low-level call failed");



		if (returndata.length > 0) {

			// Return data is optional

			// solhint-disable-next-line max-line-length

			require(

				abi.decode(returndata, (bool)),

				"SafeERC20: ERC20 operation did not succeed"

			);

		}

	}

}





/**

 * @title Roles

 * @dev Library for managing addresses assigned to a Role.

 */

library Roles {

	struct Role {

		mapping(address => bool) bearer;

	}



	/**

	 * @dev Give an account access to this role.

	 */

	function add(Role storage _role, address _account) internal {

		require(!has(_role, _account), "Roles: account already has role");

		_role.bearer[_account] = true;

	}



	/**

	 * @dev Remove an account's access to this role.

	 */

	function remove(Role storage _role, address _account) internal {

		require(has(_role, _account), "Roles: account does not have role");

		_role.bearer[_account] = false;

	}



	/**

	 * @dev Check if an account has this role.

	 * @return bool

	 */

	function has(Role storage _role, address _account)

		internal

		view

		returns (bool)

	{

		require(_account != address(0), "Roles: account is the zero address");

		return _role.bearer[_account];

	}

}





/**

 * @dev Contract module which provides a basic access control mechanism, where

 * there is an account (an owner) that can be granted exclusive access to

 * specific functions.

 *

 * This module is used through inheritance. It will make available the modifier

 * `onlyOwner`, which can be applied to your functions to restrict their use to

 * the owner.

 */

contract Ownable {

	address private _owner;



	event OwnershipTransferred(

		address indexed previousOwner,

		address indexed newOwner

	);



	/**

	 * @dev Initializes the contract setting the deployer as the initial owner.

	 */

	constructor() internal {

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

		require(

			newOwner != address(0),

			"Ownable: new owner is the zero address"

		);

		emit OwnershipTransferred(_owner, newOwner);

		_owner = newOwner;

	}

}





contract Operator is Ownable {

	using Roles for Roles.Role;



	Roles.Role private _operators;



	address[] private _operatorsListed;



	mapping(address => uint256) _operatorIndexs;



	event OperatorAdded(address indexed account);

	event OperatorRemoved(address indexed account);



	modifier onlyOperator() {

		require(

			isOperator(msg.sender),

			"caller does not have the Operator role"

		);

		_;

	}



	constructor() public {

		_addOperator(msg.sender);

	}



	function getAllOperators() public view returns(address[] memory operators) {

		operators = new address[](_operatorsListed.length);

		uint256 counter = 0;

		for (uint256 i = 0; i < _operatorsListed.length; i++) {

			if (isOperator(_operatorsListed[i])) {

				operators[counter] = _operatorsListed[i];

				counter++;

			}

		}

	  return operators;

	}



	function isOperator(address _account) public view returns (bool) {

		return _operators.has(_account);

	}



	function addOperator(address _account) public onlyOwner {

		_addOperator(_account);

	}



	function batchAddOperators(address[] memory _accounts) public onlyOwner {

		uint256 arrayLength = _accounts.length;

		for (uint256 i = 0; i < arrayLength; i++) {

			_addOperator(_accounts[i]);

		}

	}



	function removeOperator(address _account) public onlyOwner {

		_removeOperator(_account);

	}



	function batchRemoveOperators(address[] memory _accounts)

		public

		onlyOwner

	{

		uint256 arrayLength = _accounts.length;

		for (uint256 i = 0; i < arrayLength; i++) {

			_removeOperator(_accounts[i]);

		}

	}



	function renounceOperator() public {

		_removeOperator(msg.sender);

	}



	function _addOperator(address _account) internal {

		_operators.add(_account);

		if (_operatorIndexs[_account] == 0) {

		  _operatorsListed.push(_account);

		  _operatorIndexs[_account] = _operatorsListed.length;

		}

		emit OperatorAdded(_account);

	}



	function _removeOperator(address _account) internal {

		_operators.remove(_account);

		emit OperatorRemoved(_account);

	}

}





/**

 * @dev Contract module which allows children to implement an emergency stop

 * mechanism that can be triggered by an authorized account.

 *

 * This module is used through inheritance. It will make available the

 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to

 * the functions of your contract. Note that they will not be pausable by

 * simply including this module, only once the modifiers are put in place.

 */

contract Pausable is Ownable {

	/**

	 * @dev Emitted when the pause is triggered by a pauser (`account`).

	 */

	event Paused(address account);



	/**

	 * @dev Emitted when the pause is lifted by a pauser (`account`).

	 */

	event Unpaused(address account);



	bool private _paused;



	/**

	 * @dev Initializes the contract in unpaused state. Assigns the Pauser role

	 * to the deployer.

	 */

	constructor() internal {

		_paused = false;

	}



	/**

	 * @dev Returns true if the contract is paused, and false otherwise.

	 */

	function paused() public view returns (bool) {

		return _paused;

	}



	/**

	 * @dev Modifier to make a function callable only when the contract is not paused.

	 */

	modifier whenNotPaused() {

		require(!_paused, "Pausable: paused");

		_;

	}



	/**

	 * @dev Modifier to make a function callable only when the contract is paused.

	 */

	modifier whenPaused() {

		require(_paused, "Pausable: not paused");

		_;

	}



	/**

	 * @dev Called by a pauser to pause, triggers stopped state.

	 */

	function pause() public onlyOwner whenNotPaused {

		_paused = true;

		emit Paused(msg.sender);

	}



	/**

	 * @dev Called by a pauser to unpause, returns to normal state.

	 */

	function unpause() public onlyOwner whenPaused {

		_paused = false;

		emit Unpaused(msg.sender);

	}

}





interface IAdvanceCrowdsale {

  function updatePurchasingState(address beneficiary, uint256 tokenAmount) external returns(bool);

}







contract TimeLockFactory is Operator, Pausable {

	using SafeMath for uint256;

	using SafeERC20 for IERC20;



	// ERC20 basic token contract being held

	IERC20 private _token;



	// time when the token was deployed to the network

	uint256 private _globalReleaseTime;



	// storage list of the beneficiary addresses

	address[] private _lockupBeneficiaries;



	// storage list of bundle identifies

	uint256[] private _bundleIdentifies;



	// storage list of lockup phases

	LockupPhase[] private _lockupPhases;



	// finalized state

	bool private _finalized;



	// smart contract version

	string public constant version = "1.0";



	uint256 public constant TOTAL_PERCENTAGE = 1000; // mean 10x percent 1000 = 100%



	// storage lockup phase detail

	struct LockupPhase {

		uint256 id;

		uint256 percentage;

		uint256 extraTime;

		uint256 unlockedCount;

		bool hasWithdrawal;

	}



	// storage lockup bundle detail

	struct LockupBundle {

		uint256 id;

		address beneficiary;

		uint256 amount;

		mapping(uint256 => bool) isPhaseWithdrawns;

	}



	// storage bundle id of beneficiary address

	mapping(address => uint256[]) private _lockupIdsOfBeneficiary;



	// storage lockup bundle by bundle id

	mapping(uint256 => LockupBundle) private _lockupBundles;



	// storage phase index

	mapping(uint256 => uint256) private _phaseIndexs;



	// storage process state of transaction id

	mapping(string => uint256) private _processedTxids;



	event TokenLocked(address _beneficiary, uint256 _amount);



	event TimeLockFactoryFinalized();



	modifier whenNotFinalized() {

		require(!_finalized, "TimeLockFactory: finalized");

		_;

	}



	constructor(IERC20 token) public {

		_token = token;

	}



	/**

	 * @return the token being held.

	 */

	function token() public view returns (IERC20) {

		return _token;

	}



	/**

	 * @return the global release time.

	 */

	function globalReleaseTime() public view returns (uint256) {

		return _globalReleaseTime;

	}



	/**

	 * @return true if the crowdsale is finalized, false otherwise.

	 */

	function finalized() public view returns (bool) {

		return _finalized;

	}



	/**

	 * @return the total of the beneficiary addresses

	 */

	function getTotalBeneficiaries() public view returns (uint256) {

		return _lockupBeneficiaries.length;

	}



	/**

	 * @return the total of the bundle identifies

	 */

	function getTotalBundleIdentifies() public view returns (uint256) {

		return _bundleIdentifies.length;

	}



	/**

	 * @param _beneficiary beneficiary address

	 * @return the total of the bundle identifies if beneficiary address

	 */

	function getTotalBundleIdentifiesOf(address _beneficiary) public view returns (uint256) {

		return _lockupIdsOfBeneficiary[_beneficiary].length;

	}



	/**

	 * @param _startIndex start index

	 * @param _endIndex end index

	 * @param _revert sort array asc or desc

	 * @return the list of the beneficiary addresses

	 */

	function paginationBeneficiaries(uint256 _startIndex, uint256 _endIndex, bool _revert) public view returns (address[] memory) {

		uint256 startIndex = _startIndex;

		uint256 endIndex = _endIndex;

		if (startIndex >= _lockupBeneficiaries.length) {

			return new address[](0);

		}

		if (endIndex > _lockupBeneficiaries.length) {

			endIndex = _lockupBeneficiaries.length;

		}

		// make memory array

		address[] memory beneficiaries = new address[](endIndex.sub(startIndex));

		if (_revert) {

			for (uint256 i = endIndex; i > startIndex; i--) {

				beneficiaries[endIndex.sub(i)] = _lockupBeneficiaries[i.sub(1)];

			}

			return beneficiaries;

		}

		for (uint256 i = startIndex; i < endIndex; i++) {

			beneficiaries[i.sub(startIndex)] = _lockupBeneficiaries[i];

		}

		return beneficiaries;

	}



	/**

	 * @param _startIndex start index

	 * @param _endIndex end index

	 * @param _revert sort array asc or desc

	 * @return the list of the bundle identifies

	 */

	function paginationBundleIdentifies(uint256 _startIndex, uint256 _endIndex, bool _revert) public view returns (uint256[] memory) {

		uint256 startIndex = _startIndex;

		uint256 endIndex = _endIndex;

		if (startIndex >= _bundleIdentifies.length) {

			return new uint256[](0);

		}

		if (endIndex > _bundleIdentifies.length) {

			endIndex = _bundleIdentifies.length;

		}



		// make memory array

		uint256[] memory identifies = new uint256[](endIndex.sub(startIndex));

		if (_revert) {

			for (uint256 i = endIndex; i > startIndex; i--) {

				identifies[endIndex.sub(i)] = _bundleIdentifies[i.sub(1)];

			}

			return identifies;

		}

		for (uint256 i = startIndex; i < endIndex; i++) {

			identifies[i.sub(startIndex)] = _bundleIdentifies[i];

		}

		return identifies;

	}



	/**

	 * @param _beneficiary beneficiary address

	 * @param _startIndex start index

	 * @param _endIndex end index

	 * @param _revert sort array asc or desc

	 * @return the list of the bundle identifies of beneficiary address

	 */

	function paginationBundleIdentifiesOf(address _beneficiary, uint256 _startIndex, uint256 _endIndex, bool _revert) public view returns (uint256[] memory) {

		uint256 startIndex = _startIndex;

		uint256 endIndex = _endIndex;

		if (startIndex >= _lockupIdsOfBeneficiary[_beneficiary].length) {

			return new uint256[](0);

		}

		if (endIndex >= _lockupIdsOfBeneficiary[_beneficiary].length) {

			endIndex = _lockupIdsOfBeneficiary[_beneficiary].length;

		}

		// make memory array

		uint256[] memory identifies = new uint256[](endIndex.sub(startIndex));

		if (_revert) {

			for (uint256 i = endIndex; i > startIndex; i--) {

				identifies[endIndex.sub(i)] = _lockupIdsOfBeneficiary[_beneficiary][i.sub(1)];

			}

			return identifies;

		}

		for (uint256 i = startIndex; i < endIndex; i++) {

			identifies[i.sub(startIndex)] = _lockupIdsOfBeneficiary[_beneficiary][i];

		}

		return identifies;

	}



	/**

	 * @param _id bundle id

	 * @return the bundle detail

	 */

	function getBundleDetailById(uint256 _id) public view returns (uint256 id, address beneficiary, uint256 amount, uint256[] memory phaseIdentifies, bool[] memory isPhaseWithdrawns) {

		LockupBundle storage bundle = _lockupBundles[_id];

		id = bundle.id;

		beneficiary = bundle.beneficiary;

		amount = bundle.amount;

		phaseIdentifies = new uint256[](_lockupPhases.length);

		isPhaseWithdrawns = new bool[](_lockupPhases.length);

		for (uint256 i = 0; i < _lockupPhases.length; i++) {

			phaseIdentifies[i] = _lockupPhases[i].id;

			isPhaseWithdrawns[i] = bundle.isPhaseWithdrawns[_lockupPhases[i].id];

		}

	}



	/**

	 * @return the all phases detail

	 */

	function getLockupPhases() public view returns (uint256[] memory ids, uint256[] memory percentages, uint256[] memory extraTimes, bool[] memory hasWithdrawals, bool[] memory canWithdrawals) {

		ids = new uint256[](_lockupPhases.length);

		percentages = new uint256[](_lockupPhases.length);

		extraTimes = new uint256[](_lockupPhases.length);

		hasWithdrawals = new bool[](_lockupPhases.length);

		canWithdrawals = new bool[](_lockupPhases.length);



		for (uint256 i = 0; i < _lockupPhases.length; i++) {

			LockupPhase memory phase = _lockupPhases[i];

			ids[i] = phase.id;

			percentages[i] = phase.percentage;

			extraTimes[i] = phase.extraTime;

			hasWithdrawals[i] = phase.hasWithdrawal;

			canWithdrawals[i] = checkPhaseCanWithdrawal(phase.id);

		}

	}



	/**

	 * @param _id phase id

	 * @return the phase detail

	 */

	function getLockupPhaseDetail(uint256 _id) public view returns (uint256 id, uint256 percentage, uint256 extraTime, bool hasWithdrawal, bool canWithdrawal) {

		if (_phaseIndexs[_id] > 0) {

			LockupPhase memory phase = _lockupPhases[_phaseIndexs[_id].sub(1)];

			id = phase.id;

			percentage = phase.percentage;

			extraTime = phase.extraTime;

			hasWithdrawal = phase.hasWithdrawal;

			canWithdrawal = checkPhaseCanWithdrawal(_id);

		}

	}



	/**

	 * @param _id phase id

	 * @return the withdrawal state of phase

	 */

	function checkPhaseCanWithdrawal(uint256 _id) public view returns (bool) {

		if (_phaseIndexs[_id] == 0) {

			return false;

		}

		LockupPhase memory phase = _lockupPhases[_phaseIndexs[_id].sub(1)];

		return !phase.hasWithdrawal && _globalReleaseTime.add(phase.extraTime) <= block.timestamp;

	}



	/**

	 * @param _id phase id

	 * @return the withdrawal state of phase

	 */

	function checkPhaseHasWithdrawal(uint256 _id) internal view returns (bool) {

		if (_phaseIndexs[_id] == 0) {

			return false;

		}

		LockupPhase memory phase = _lockupPhases[_phaseIndexs[_id].sub(1)];

		return phase.hasWithdrawal;

	}



	/**

	 * @param _txid transaction hash

	 * @return the process state of transaction id

	 */

	function hasProcessedTxid(string memory _txid) public view returns (bool) {

		return _processedTxids[_txid] != 0;

	}



	/**

	 * Lockup Phases Start

	 * ===============================================================================

	 */



	function setLockupPhases(uint256[] memory _ids, uint256[] memory _percentages, uint256[] memory _extraTimes) public whenNotPaused whenNotFinalized {

		require(isOwner() || isOperator(msg.sender), "TimeLockFactory: caller is not the owner or operator");

		require(_ids.length == _percentages.length && _ids.length == _extraTimes.length, "TimeLockFactory:: Cannot match inputs");

		_preValidateLockupPhases(_percentages);

		for (uint256 i = 0; i < _ids.length; i++) {

			if (!checkPhaseHasWithdrawal(_ids[i])) {

				_setLockupPhase(_ids[i], _percentages[i], _extraTimes[i]);

			}

		}

	}



	function _setLockupPhase(uint256 _id, uint256 _percentage, uint256 _extraTime) internal {

		require(_id > 0, "TimeLockFactory: Phase ID is zero");

		require(_percentage > 0, "TimeLockFactory: Percentage is zero");

		require(_extraTime > 0, "TimeLockFactory: ExtraTime is zero");

		// require(_globalReleaseTime.add(_extraTime) > block.timestamp, "TimeLockFactory: Unlock time is before current");



		LockupPhase memory phase = LockupPhase(_id, _percentage, _extraTime, 0, false);

		_lockupPhases.push(phase);

		_phaseIndexs[_id] = _lockupPhases.length;

	}



	function _preValidateLockupPhases(uint256[] memory _percentages) internal {

		uint256 totalPercentage = 0;

		for (uint256 i = 0; i < _percentages.length; i++) {

			totalPercentage = totalPercentage.add(_percentages[i]);

		}

		require(totalPercentage == TOTAL_PERCENTAGE, "TimeLockFactory: Total percentage is not valid");

		// init tmp phase

		LockupPhase[] memory _tempPhases = new LockupPhase[](_lockupPhases.length);

		for (uint256 i = 0; i < _lockupPhases.length; i++) {

			_tempPhases[i] = _lockupPhases[i];

		}

		// delete all current phases has not withdrawal

		_lockupPhases.length = 0;

		// add phase has withdrawal

		for (uint256 i = 0; i < _tempPhases.length; i++) {

			if (_tempPhases[i].hasWithdrawal) {

				_lockupPhases.push(_tempPhases[i]);

				_phaseIndexs[_tempPhases[i].id] = _lockupPhases.length;

			} else {

				_phaseIndexs[_tempPhases[i].id] = 0;

			}

		}

	}



	/**

	 * Lockup Phases End

	 * ===============================================================================

	 */



	/**

	 * Lockup Bundles Start

	 * ===============================================================================

	 */



	function lock(uint256 _id, address _beneficiary, uint256 _amount, address _saleAddress) public whenNotPaused whenNotFinalized {

		require(isOwner() || isOperator(msg.sender), "TimeLockFactory: caller is not the owner or operator");

		_lock(_id, _beneficiary, _amount, _saleAddress);

	}



	function lock(uint256 _id, address _beneficiary, uint256 _amount, address _saleAddress, string memory _txid) public whenNotPaused whenNotFinalized {

		require(isOwner() || isOperator(msg.sender), "TimeLockFactory: caller is not the owner or operator");

		require(_processedTxids[_txid] == 0, "TimeLockFactory: Txid is processed or empty");

		_lock(_id, _beneficiary, _amount, _saleAddress);

		_processedTxids[_txid] = _id;

	}



	function _lock(uint256 _id, address _beneficiary, uint256 _amount, address _saleAddress) internal {

		_preValidateLockup(_id, _beneficiary, _amount);



		_processLockup(_id, _beneficiary, _amount);



		emit TokenLocked(_beneficiary, _amount);



		_postUnlockIfAvailable(_id, _beneficiary, _amount, _saleAddress);

	}



	function hasEnoughTokenBeforeLockup(uint256 _amount) public view returns (bool hasEnough, uint256 requiredAmount) {

		uint256 unlockedPercentage = 0;

		for (uint256 i = 0; i < _lockupPhases.length; i++) {

			LockupPhase memory phase = _lockupPhases[i];

			if (phase.hasWithdrawal) {

				unlockedPercentage = unlockedPercentage.add(phase.percentage);

			}

		}



		uint256 unlockedAmount = _amount.mul(unlockedPercentage).div(TOTAL_PERCENTAGE);

		if (_token.balanceOf(address(this)) >= unlockedAmount) {

			return (true, 0);

		}

		return (false, unlockedAmount);

	}



	function _preValidateLockup(uint256 _id, address _beneficiary, uint256 _amount) internal view {

		require(_id > 0, "TimeLockFactory: Bundle ID is zero");

		require(_beneficiary != address(0), "TimeLockFactory: Beneficiary is zero address");

		require(_amount > 0, "TimeLockFactory: Amount is zero");



		LockupBundle memory _existedBundle = _lockupBundles[_id];

		require(_existedBundle.id == 0, "TimeLockFactory: Bundle ID has already existed");

		(bool hasEnough, ) = hasEnoughTokenBeforeLockup(_amount);

		require(hasEnough, "TimeLockFactory: Balance not enough");

	}



	function _processLockup(uint256 _id, address _beneficiary, uint256 _amount) internal {

		LockupBundle memory bundle = LockupBundle(_id, _beneficiary, _amount);

		_lockupBundles[_id] = bundle;

		if (_lockupIdsOfBeneficiary[_beneficiary].length == 0) {

			_lockupBeneficiaries.push(_beneficiary);

		}

		_bundleIdentifies.push(_id);

		_lockupIdsOfBeneficiary[_beneficiary].push(_id);

	}



	function _postUnlockIfAvailable(uint256 _id, address _beneficiary, uint256 _amount, address _saleAddress) internal {

		IAdvanceCrowdsale(_saleAddress).updatePurchasingState(_beneficiary, _amount);



		uint256 unlockedPercentage = 0;

		for (uint256 i = 0; i < _lockupPhases.length; i++) {

			LockupPhase memory phase = _lockupPhases[i];

			if (phase.hasWithdrawal) {

				unlockedPercentage = unlockedPercentage.add(phase.percentage);

				_lockupBundles[_id].isPhaseWithdrawns[phase.id] = true;

			} else {

				_lockupBundles[_id].isPhaseWithdrawns[phase.id] = false;

			}

		}



		uint256 unlockedAmount = _amount.mul(unlockedPercentage).div(TOTAL_PERCENTAGE);

		if (unlockedAmount > 0) {

			_token.safeTransfer(_beneficiary, unlockedAmount);

		}

	}



	function unlocks(uint256 _phaseId, uint256 _limit) public whenNotPaused whenNotFinalized {

		require(isOwner() || isOperator(msg.sender), "TimeLockFactory: caller is not the owner or operator");

		require(_phaseId > 0, "TimeLockFactory: Phase ID is zero");

		require(_limit > 0, "TimeLockFactory: Must set maximum bundles per unlock");

		require(_phaseIndexs[_phaseId] > 0, "TimeLockFactory: Phase ID not existed");



		_preUnlockPhase(_phaseId, _limit);



		_processUnlocks(_phaseId, _limit);

	}



	function hasEnoughTokenBeforeUnlock(uint256 _phaseId, uint256 _limit) public view returns (bool hasEnough, uint256 requiredAmount) {

		if (_phaseIndexs[_phaseId] == 0) {

			return (false, 0);

		}



		uint256 totalUnlockAmount = 0;

		uint256 _limitCounter = 0;

		LockupPhase storage phase = _lockupPhases[_phaseIndexs[_phaseId].sub(1)];

		for (uint256 i = phase.unlockedCount; i < _bundleIdentifies.length; i++) {

			LockupBundle storage bundle = _lockupBundles[_bundleIdentifies[i]];

			// skip if bundle has withdrawal

			if (bundle.isPhaseWithdrawns[_phaseId]) {

				continue;

			}

			// calculate amount

			uint256 unlockAmount = bundle.amount.mul(phase.percentage).div(TOTAL_PERCENTAGE);

			totalUnlockAmount = totalUnlockAmount.add(unlockAmount);

			// increase counter

			_limitCounter = _limitCounter.add(1);

			if (_limitCounter == _limit) {

				break;

			}

		}



		if (_token.balanceOf(address(this)) >= totalUnlockAmount) {

			return (true, 0);

		}

		return (false, totalUnlockAmount);

	}



	function _preUnlockPhase(uint256 _phaseId, uint256 _limit) internal view {

		LockupPhase storage phase = _lockupPhases[_phaseIndexs[_phaseId].sub(1)];

		require(phase.id > 0, "TimeLockFactory: Phase does not exist");

		require(!phase.hasWithdrawal, "TimeLockFactory: Phase was unlocked");

		require(_globalReleaseTime.add(phase.extraTime) <= block.timestamp, "TimeLockFactory: Phase is locking");

		(bool hasEnough, ) = hasEnoughTokenBeforeUnlock(_phaseId, _limit);

		require(hasEnough, "TimeLockFactory: Balance not enough");

	}



	function _processUnlocks(uint256 _phaseId, uint256 _limit) internal {

		uint256 _limitCounter = 0;

		LockupPhase storage phase = _lockupPhases[_phaseIndexs[_phaseId].sub(1)];

		for (uint256 i = phase.unlockedCount; i < _bundleIdentifies.length; i++) {

			LockupBundle storage bundle = _lockupBundles[_bundleIdentifies[i]];

			// skip if bundle has withdrawal

			if (bundle.isPhaseWithdrawns[_phaseId]) {

				continue;

			}

			// transfer token

			uint256 unlockAmount = bundle.amount.mul(phase.percentage).div(TOTAL_PERCENTAGE);

			_token.safeTransfer(bundle.beneficiary, unlockAmount);

			bundle.isPhaseWithdrawns[_phaseId] = true;

			// increase counter

			phase.unlockedCount = phase.unlockedCount.add(1);

			_limitCounter = _limitCounter.add(1);

			// break if counter equal limit

			if (_limitCounter == _limit) {

				break;

			}

		}

		if (phase.unlockedCount >= _bundleIdentifies.length) {

			phase.hasWithdrawal = true;

		}

	}



	/**

	 * Lockup Bundle End

	 * ===============================================================================

	 */



	/**

	 * @dev Set global release time of the token

	 * @param _globalTime the global timee to release token

	 */

	function setGlobalReleaseTime(uint256 _globalTime) public onlyOwner whenNotFinalized {

		_globalReleaseTime = _globalTime;

	}



	/**

	 * @dev Use to withdrawal token to owner

	 * @param _amount the withdrawal amount

	 */

	function withdrawal(uint256 _amount) public onlyOwner whenNotFinalized {

		require(_amount > 0, "TimeLockFactory: Amount is 0");

		require(_token.balanceOf(address(this)) >= _amount, "TimeLockFactory: Balance not enough");

		_token.safeTransfer(msg.sender, _amount);

	}



	/**

	 * @dev Must be called after current phase ends, to do some extra finalization

	 * work. Calls the contract's finalization function.

	 */

	function finalize() public onlyOwner whenNotFinalized {

		_finalized = true;

		_finalization();

		emit TimeLockFactoryFinalized();

	}



	function _finalization() internal {

		uint256 amount = _token.balanceOf(address(this));

		if (amount != 0) {

			_token.safeTransfer(msg.sender, amount);

		}

	}

}
