/**
 *Submitted for verification at Etherscan.io on 2020-12-16
*/

// File: @openzeppelin\upgrades\contracts\Initializable.sol

//pragma solidity >=0.4.24 <0.7.0;
pragma solidity >=0.5 <0.7.17;


/**
 * @title Initializable
 *
 * @dev Helper contract to support initializer functions. To use it, replace
 * the constructor with a function that has the `initializer` modifier.
 * WARNING: Unlike constructors, initializer functions must be manually
 * invoked. This applies both to deploying an Initializable contract, as well
 * as extending an Initializable contract via inheritance.
 * WARNING: When used with inheritance, manual care must be taken to not invoke
 * a parent initializer twice, or ensure that all initializers are idempotent,
 * because this is not dealt with automatically as with constructors.
 */
contract Initializable {

  /**
   * @dev Indicates that the contract has been initialized.
   */
  bool private initialized;

  /**
   * @dev Indicates that the contract is in the process of being initialized.
   */
  bool private initializing;

  /**
   * @dev Modifier to use in the initializer function of a contract.
   */
  modifier initializer() {
    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  /// @dev Returns true if and only if the function is running in the constructor
  function isConstructor() private view returns (bool) {
    // extcodesize checks the size of the code stored in an address, and
    // address returns the current address. Since the code is still not
    // deployed when running a constructor, any checks on its code size will
    // yield zero, making it an effective way to detect if a contract is
    // under construction or not.
    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  // Reserved storage space to allow for layout changes in the future.
  uint256[50] private ______gap;
}

// File: contracts\interfaces\IERC20.sol

//pragma solidity ^0.5.0;
pragma solidity >=0.5 <0.7.17;

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
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

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
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: contracts\token\ERC20\ERC20Detailed.sol

//pragma solidity ^0.5.0;
pragma solidity >=0.5 <0.7.17;




/**
 * @dev Optional functions from the ERC20 standard.
 */
contract ERC20Detailed is Initializable, IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for `name`, `symbol`, and `decimals`. All three of
     * these values are immutable: they can only be set once during
     * construction.
     */
    function initialize(string memory name, string memory symbol, uint8 decimals) public initializer {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }

    uint256[50] private ______gap;
}

// File: contracts\nonupgradable\Ownable.sol

//pragma solidity ^0.5.16;
pragma solidity >=0.5 <0.7.17;

contract Ownable {
    address payable public owner;
    address payable internal newOwnerCandidate;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Permission denied");
        _;
    }

    function changeOwner(address payable newOwner) public onlyOwner {
        newOwnerCandidate = newOwner;
    }

    function acceptOwner() public {
        require(msg.sender == newOwnerCandidate, "Permission denied");
        owner = newOwnerCandidate;
    }
}

// File: contracts\interfaces\IToken.sol

//pragma solidity ^0.5.16;
pragma solidity >=0.5 <0.7.17;

interface IToken {
    function decimals() external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function approve(address spender, uint value) external;
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
    function deposit() external payable;
    function mint(address, uint256) external;
    function withdraw(uint amount) external;
    function totalSupply() view external returns (uint256);
    function burnFrom(address account, uint256 amount) external;
    function symbol() external view returns (string memory);
}

// File: contracts\utils\SafeMath.sol

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

// File: contracts\token\ERC20\ERC20.sol

//pragma solidity ^0.5.0;
pragma solidity >=0.5 <0.7.17;





/**
 * @dev Implementation of the {IERC20} interface.
 */
contract ERC20 is Initializable, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) internal _balances;

    mapping (address => mapping (address => uint256)) internal _allowances;

    uint256 internal _totalSupply;

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`.`amount` is then deducted
     * from the caller's allowance.
     *
     * See {_burn} and {_approve}.
     */
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount, "ERC20: burn amount exceeds allowance"));
    }

    uint256[50] private ______gap;
}

// File: contracts\interfaces\IPriceOracle.sol

//pragma solidity ^0.5.17;
pragma solidity >=0.5 <0.7.17;

interface IPriceOracle {
    function price(string calldata symbol) external view returns (uint);
}

// File: contracts\utils\DSMath.sol

//pragma solidity ^0.5.0;
pragma solidity >=0.5 <0.7.17;

contract DSMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x);
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x);
    }
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }

//    function min(uint x, uint y) internal pure returns (uint z) {
//        return x <= y ? x : y;
//    }
//    function max(uint x, uint y) internal pure returns (uint z) {
//        return x >= y ? x : y;
//    }
//    function imin(int x, int y) internal pure returns (int z) {
//        return x <= y ? x : y;
//    }
//    function imax(int x, int y) internal pure returns (int z) {
//        return x >= y ? x : y;
//    }

    uint constant WAD = 10 ** 18;
//    uint constant RAY = 10 ** 27;

    function wmul(uint x, uint y, uint base) internal pure returns (uint z) {
        z = add(mul(x, y), base / 2) / base;
    }

    function wmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), WAD / 2) / WAD;
    }
//    function rmul(uint x, uint y) internal pure returns (uint z) {
//        z = add(mul(x, y), RAY / 2) / RAY;
//    }
    function wdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, WAD), y / 2) / y;
    }
//    function rdiv(uint x, uint y) internal pure returns (uint z) {
//        z = add(mul(x, RAY), y / 2) / y;
//    }

}

// File: contracts\utils\Address.sol

//pragma solidity ^0.5.5;
pragma solidity >=0.5 <0.7.17;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * This test is non-exhaustive, and there may be false-negatives: during the
     * execution of a contract's constructor, its address will be reported as
     * not containing a contract.
     *
     * IMPORTANT: It is unsafe to assume that an address for which this
     * function returns false is an externally-owned account (EOA) and not a
     * contract.
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies in extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }

    /**
     * @dev Converts an `address` into `address payable`. Note that this is
     * simply a type cast: the actual underlying value is not changed.
     *
     * _Available since v2.4.0._
     */
    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     *
     * _Available since v2.4.0._
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-call-value
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

// File: contracts\utils\SafeERC20.sol

//pragma solidity ^0.5.16;
pragma solidity >=0.5 <0.7.17;

// import "@openzeppelin/contracts-ethereum-package/contracts/math/SafeMath.sol";

// import "@openzeppelin/contracts-ethereum-package/contracts/utils/Address.sol";



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

    function safeTransfer(IToken token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IToken token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IToken token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IToken token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IToken token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function callOptionalReturn(IToken token, bytes memory data) private {
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

// File: contracts\utils\UniversalERC20.sol

//pragma solidity ^0.5.16;
pragma solidity >=0.5 <0.7.17;

// import "@openzeppelin/contracts-ethereum-package/contracts/math/SafeMath.sol";
// import "./SafeMath.sol";



library UniversalERC20 {

    using SafeMath for uint256;
    using SafeERC20 for IToken;

    IToken private constant ZERO_ADDRESS = IToken(0x0000000000000000000000000000000000000000);
    IToken private constant ETH_ADDRESS = IToken(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);

    function universalTransfer(IToken token, address to, uint256 amount) internal {
        universalTransfer(token, to, amount, false);
    }

    function universalSymbol(IToken token) internal view returns (string memory) {
        if (token == ETH_ADDRESS) return "ETH";
        return token.symbol();
    }

    function universalDecimals(IToken token) internal view returns (uint) {
        if (token == ETH_ADDRESS) return 18;
        return token.decimals();
    }

    function universalTransfer(IToken token, address to, uint256 amount, bool mayFail) internal returns(bool) {
        if (amount == 0) {
            return true;
        }

        if (token == ZERO_ADDRESS || token == ETH_ADDRESS) {
            if (mayFail) {
                return address(uint160(to)).send(amount);
            } else {
                address(uint160(to)).transfer(amount);
                return true;
            }
        } else {
            token.safeTransfer(to, amount);
            return true;
        }
    }

    function universalApprove(IToken token, address to, uint256 amount) internal {
        if (token != ZERO_ADDRESS && token != ETH_ADDRESS) {
            token.safeApprove(to, amount);
        }
    }

    function universalTransferFrom(IToken token, address from, address to, uint256 amount) internal {
        if (amount == 0) {
            return;
        }

        if (token == ZERO_ADDRESS || token == ETH_ADDRESS) {
            require(from == msg.sender && msg.value >= amount, "msg.value is zero");
            if (to != address(this)) {
                address(uint160(to)).transfer(amount);
            }
            if (msg.value > amount) {
                msg.sender.transfer(uint256(msg.value).sub(amount));
            }
        } else {
            token.safeTransferFrom(from, to, amount);
        }
    }

    function universalBalanceOf(IToken token, address who) internal view returns (uint256) {
        if (token == ZERO_ADDRESS || token == ETH_ADDRESS) {
            return who.balance;
        } else {
            return token.balanceOf(who);
        }
    }
}

// File: contracts\deposits_v3\Indefieco.sol

//pragma solidity ^0.5.16;
pragma solidity >=0.5 <0.7.17;









interface TokenizedStrategy {
    function deposit(uint256 amountDAI, uint256 amountUSDC, address flashloanFromAddress) external payable;
    function burnTokens(uint256 amountDAI, uint256 amountUSDC, uint256 amountETH, address flashLoanFromAddress) external;
    function userClaimProfit(uint64 max) external;
    function burnTokens(uint256 amount, bool withFlashloan) external; // function from old TokenizedStrategy, work just for DAI
}

interface IDfFinanceDeposits {
    enum FlashloanProvider {
        DYDX,
        AAVE,
        ADDRESS
    }

    function deposit(
        address dfWallet,
        uint256 amountDAI,
        uint256 amountUSDC,
        uint256 amountWBTC,
        uint256 flashloanDAI,
        uint256 flashloanUSDC,
        FlashloanProvider flashloanType,
        address flashloanFromAddress
    ) external payable returns (address);
}

interface IComptroller {
    function oracle() external view returns (IPriceOracle);
    function getAccountLiquidity(address) external view returns (uint, uint, uint);
}

contract InDefiEcoPreMining is
    Initializable,
    Ownable,
    ERC20Detailed,
    ERC20,
    DSMath
{
    using UniversalERC20 for IToken;

//    address public constant ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE; // Kovan
//    address public constant DAI_ADDRESS = 0x4F96Fe3b7A6Cf9725f59d353F723c1bDb64CA6Aa; // Kovan
//    address public constant USDC_ADDRESS = 0xb7a4F3E9097C08dA09517b5aB877F7a917224ede; // Kovan
//    address public constant WBTC_ADDRESS = 0xd3A691C852CDB01E281545A27064741F0B7f6825; // Kovan
//    address public constant COMPTROLLER = 0x5eAe89DC1C671724A672ff0630122ee834098657; // Kovan

    address public constant ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address public constant DAI_ADDRESS = 0x6B175474E89094C44Da98b954EedeAC495271d0F; // Mainnet
    address public constant USDC_ADDRESS = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48; // Mainnet
    address public constant WBTC_ADDRESS = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599; // Mainnet
    address public constant COMPTROLLER = 0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B; // Mainnet

    TokenizedStrategy public constant dfTokenizedStrategy = TokenizedStrategy(0xb942ca22e0eb0f2524F53f999aE33fD3B2D58E3E); // Mainnet
    address public constant dfDeposits = 0xFff9D7b0B6312ead0a1A993BF32f373449006F2F; // Mainnet

    function initialize() public initializer {
        owner = 0xdAE0aca4B9B38199408ffaB32562Bf7B3B0495fE;
        ERC20Detailed.initialize('XInDefiEco', 'XIDF', 18);
        maxDateDeposits = 1609016400;
        dateFundsUnlocked = maxDateDeposits + 90 days;
        maxDelayUntilClaimTokens = 3 days;
        enableToken(DAI_ADDRESS);
        enableToken(ETH_ADDRESS);
        enableToken(WBTC_ADDRESS);
        enableToken(USDC_ADDRESS);
    }

    // TODO: remove in production
//    function setDebugDates(uint256 _new_maxDateDeposits, uint256 _new_dateFundsUnlocked) public onlyOwner {
//        maxDateDeposits = _new_maxDateDeposits;
//        dateFundsUnlocked = _new_dateFundsUnlocked;
//    }

    mapping(address => bool) tokens;

    struct Deposit  {
        uint256 amount;
        uint256 avgPrice;
        uint256 tokensToMint;
        uint128 lastDeposit;
    }
    mapping(address => mapping(address => Deposit)) userDeposits;

    uint256 public maxDateDeposits;
    uint256 public dateFundsUnlocked;
    uint256 public maxDelayUntilClaimTokens;
    address flashloanFromAddress;
    uint256 public constant totalMaxTokens = 20000000 * 1e18; // 20 mil
    uint256 public totalCurrentTokens;

    // emergency tokens withdrawal status
    mapping(address => bool) public isEmergencyWithdrawalActive;

    event EmergencyWithdrawalActivated(address indexed token);

    function getInfo(address userAddress, address tokenAddress) view public returns ( uint256 amount, uint256 avgPrice,uint256 tokensToMint, uint256 price, uint256 balance, uint128 lastDeposit) {
        IPriceOracle compOracle = IComptroller(COMPTROLLER).oracle();
        price = compOracle.price(IToken(tokenAddress).universalSymbol());
        balance = IToken(tokenAddress).universalBalanceOf(address(this));

        Deposit memory d = userDeposits[userAddress][tokenAddress];
        amount = d.amount;
        avgPrice = d.avgPrice;
        tokensToMint = d.tokensToMint;
        lastDeposit = d.lastDeposit;
    }

    function enableToken(address tokenAddress) public onlyOwner {
        tokens[tokenAddress] = true; // can't remove tokens, just add
    }

    // Emergency Withdrawal logic
    function activateEmergencyWithdrawal(address token) public onlyOwner {
        isEmergencyWithdrawalActive[token] = true;
        emit EmergencyWithdrawalActivated(token);
    }

    function fundsToTokensUsePrice(IToken token, uint256 price, uint256 amount) view public returns (uint256 ret) {
        // oracle price always in $ (6 decimals)
        uint256 decimals = token.universalDecimals();
        ret = mul(price, amount) / 1e6;
        if (decimals < 18) ret = mul(ret, 10 ** (18 - decimals));
    }

    function deposit(IToken token, uint256 amount) payable public returns (uint256) {
        require(now < maxDateDeposits);
        require(tokens[address(token)]);
        IPriceOracle compOracle = IComptroller(COMPTROLLER).oracle();
        uint256 _price = compOracle.price(token.universalSymbol());
        require(_price > 0);

        token.universalTransferFrom(msg.sender, address(this), amount);

        uint256 tokensToMint = fundsToTokensUsePrice(token, _price, amount);
        totalCurrentTokens = add(totalCurrentTokens, tokensToMint);
        require(totalCurrentTokens <= totalMaxTokens);

        Deposit storage depo = userDeposits[msg.sender][address(token)];
        uint256 totalAmount = depo.amount;
        uint256 newAvgPrice = add(totalAmount * depo.avgPrice, _price * amount) / (totalAmount + amount);
        depo.amount = totalAmount + amount;
        depo.avgPrice = newAvgPrice;
        depo.tokensToMint = add(depo.tokensToMint, tokensToMint);
        depo.lastDeposit = uint128(now);

        return tokensToMint;
    }

    function releaseTokens(address userAddress, address[] memory tokenList) public returns (uint256 tokensToMint) {
        if (userAddress == address(0)) userAddress = msg.sender;
        uint256 len = tokenList.length;

        uint256 _maxDelayUntilClaimTokens = maxDelayUntilClaimTokens;

        for(uint256 i = 0; i < len;i++) {
            Deposit storage depo = userDeposits[userAddress][tokenList[i]];
            if (now > depo.lastDeposit + _maxDelayUntilClaimTokens) {
                uint256 _tMint = depo.tokensToMint;
                if (_tMint > 0) {
                    tokensToMint = add(tokensToMint, _tMint);
                    depo.tokensToMint = 0;
                }
            }
        }
        if (tokensToMint > 0) {
            _mint(userAddress, tokensToMint);
        }
    }

    function emergencyWithdraw(address token) public {
        require(tokens[token] && isEmergencyWithdrawalActive[token]); // token enabled

        Deposit storage depo = userDeposits[msg.sender][token];

        uint256 amount = depo.amount;

        // update storage user's deposit
        depo.amount = 0;
        depo.avgPrice = 0;
        depo.tokensToMint = 0;
        depo.lastDeposit = 0;

        withdrawToken(IToken(token), amount, msg.sender);
    }

    function withdraw(address token, uint256 amount) public returns (uint256 tokensToBurn) {
        require(tokens[token]); // token enabled

        Deposit storage depo = userDeposits[msg.sender][token];
        require(depo.tokensToMint == 0);
        // до dateFundsUnlocked необходимо вернуть токены для возврата средств
        if (now < dateFundsUnlocked) {
            tokensToBurn = fundsToTokensUsePrice(IToken(token), depo.avgPrice, amount);
            _burn(msg.sender, tokensToBurn);
        }

        depo.amount = sub(depo.amount, amount);

        withdrawToken(IToken(token), amount, msg.sender);

        return tokensToBurn;
    }

    function approveTokens(address[] memory listTokens) public onlyOwner {
        for(uint256 i = 0; i < listTokens.length; i++) {
            IToken token = IToken(listTokens[i]);
            if (token.allowance(address(this), address(dfTokenizedStrategy)) != uint256(-1)) {
                token.universalApprove(address(dfTokenizedStrategy), uint256(-1));
            }
            if (token.allowance(address(this), address(dfDeposits)) != uint256(-1)) {
                token.universalApprove(address(dfDeposits), uint256(-1));
            }
        }
    }

    function externalCallToTokenizedStrategy(address payable target, bytes memory data, uint256 ethAmount) public onlyOwner returns(bytes32 response) {
        // external calls allowed only for 2 contracts
        require(target == dfDeposits || target == address(dfTokenizedStrategy));
        assembly {
            let succeeded := call(sub(gas, 5000), target, ethAmount, add(data, 0x20), mload(data), 0, 32)
            response := mload(0)
            switch iszero(succeeded)
            case 1 {
                revert(0, 0)
            }
        }
    }

    function depositWBTC(address dfWallet, uint256 amountWBTC) public onlyOwner {
        require(dfWallet != address(0));

        IToken(WBTC_ADDRESS).universalTransfer(dfWallet, amountWBTC);

        IDfFinanceDeposits(dfDeposits).deposit(
            dfWallet,
            0,      // amountDAI
            0,      // amountUSDC
            amountWBTC,
            0,      // flashloanDAI
            0,      // flashloanUSDC
            IDfFinanceDeposits.FlashloanProvider.DYDX,  // default
            address(0)  // flashloanFromAddress – default
        );
    }

    function withdrawToken(IToken token, uint256 amount, address receiver) internal {
        if (receiver != address(this)) {
            if (token.universalBalanceOf(address(this)) >= amount) {
                token.universalTransfer(receiver, amount);
                return;
            }
        }

        if (address(token) == DAI_ADDRESS) {
//            dfTokenizedStrategy.burnTokens(amount, 0, 0, flashloanFromAddress);
            dfTokenizedStrategy.burnTokens(amount, true);
        } else if (address(token) == ETH_ADDRESS) {
            dfTokenizedStrategy.burnTokens(0, 0, amount, flashloanFromAddress);
        } else if (address(token) == USDC_ADDRESS) {
            dfTokenizedStrategy.burnTokens(0, amount, 0, flashloanFromAddress);
        } else {
            require(false);
        }

        if (receiver != address(this)) token.universalTransfer(receiver, amount);
    }

    // allow to claim profit from tokenized startegy (in new version)
    function defiController() view external returns(address) {
        return owner;
    }

    function() external payable {}
}
