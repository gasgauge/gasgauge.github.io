/**
 *Submitted for verification at Etherscan.io on 2020-12-16
*/

// File: @openzeppelin/contracts/GSN/Context.sol
// SPDX-License-Identifier: MIT
//pragma solidity >=0.6.0 <0.8.0;
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
    function _msgSender() internal view  returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view  returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

//pragma solidity >=0.6.0 <0.8.0;
pragma solidity >=0.5 <0.7.17;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
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

// File: @openzeppelin/contracts/math/SafeMath.sol

//pragma solidity >=0.6.0 <0.8.0;
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
     *
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
     *
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
     *
     * - Subtraction cannot overflow.
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
     *
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
     *
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
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
     *
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
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// File: @openzeppelin/contracts/token/ERC20/ERC20.sol

//pragma solidity >=0.6.0 <0.8.0;
pragma solidity >=0.5 <0.7.17;




/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
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
     * Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} is
     * called.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view  returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view  returns (uint256) {
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
    function transfer(address recipient, uint256 amount) public   returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view   returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public   returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public   returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
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
    function increaseAllowance(address spender, uint256 addedValue) public  returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
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
    function decreaseAllowance(address spender, uint256 subtractedValue) public  returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
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
    function _transfer(address sender, address recipient, uint256 amount) internal  {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal  {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

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
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal  {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal  {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Sets {decimals} to a value other than the default one of 18.
     *
     * WARNING: This function should only be called from the constructor. Most
     * applications that interact with token contracts will not expect
     * {decimals} to ever change, and may work incorrectly if it does.
     */
    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal  { }
}

// File: @openzeppelin/contracts/access/Ownable.sol

//pragma solidity >=0.6.0 <0.8.0;
pragma solidity >=0.5 <0.7.17;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
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
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public  onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public  onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: contracts/NovaToken2.sol
//pragma solidity ^0.7.0;
pragma solidity >=0.5 <0.7.17;



contract NovaToken2 is ERC20("NOVA", "NOVA"), Ownable {
    /// @notice Creates `_amount` token to `_to`. Must only be called by the owner (MasterUniverse).
    function mint(address _to, uint256 _amount) public onlyOwner {
        _mint(_to, _amount);
    }
}

// File: contracts/NovaMigrationV2.sol
//pragma solidity ^0.7.0;
pragma solidity >=0.5 <0.7.17;
pragma experimental ABIEncoderV2;




contract NovaMigrationV2 {
    using SafeMath for uint256;
    mapping (address => uint256) rewards;
    ERC20 public novaV1;
    NovaToken2 public novaV2;

    constructor(
        ERC20 _novaV1,
        NovaToken2 _novaV2
    ) public {
        novaV1 = _novaV1;
        novaV2 = _novaV2;

        // INIT REWARDS
        rewards[0x4F66536B90dd852fc9B6Fa587b5325994f7087e3] = 45;
        rewards[0xC9705c60f6bBbef941b8a6A67606908E188D45f9] = 156;
        rewards[0x0702c3D8Fba3a889f178a108DA5aF3C714C228a3] = 10;
        rewards[0x83EfA8293a5C40FcA10D3F4A8b29Ad027F53F8a3] = 2;
        rewards[0xB45b74Eb35790d20e5f4225b0AC49D5bb074696E] = 496;
        rewards[0x735660e3c4049988393471d60817F0983852Aee6] = 5;
        rewards[0x74375faBA79502580C2906144ac99117a4A3F3B5] = 2;
        rewards[0xC13bA51d26d1b2022Fa51e25243bb49A54c4A953] = 135;
        rewards[0x5aD32C7aeE7F06575EE0740cda8E6bd095CC3919] = 61;
        rewards[0x1471cD9Bd621E8506e427eaC447cCD92d7855be5] = 98;
        rewards[0x63BC843b9640c4D79d6aE0105bc39F773172d121] = 7;
        rewards[0x00290ffc9e9D19bdA7b25c6e44d8ADF55DFBf2dD] = 395;
        rewards[0x9ceB5Bca65e595956320aDE1656Fb38200c52265] = 2;
        rewards[0xD965952823153E5CBc611be87e8322cfc329f056] = 65;
        rewards[0xA1F2D9c5bb44d03FE1b530D18182A008c17A6BcC] = 2;
        rewards[0x9543746e414926D1695eC001BC7B76277895490f] = 44;
        rewards[0x1724AB964c750F4ba543970ad652961535D48d85] = 7;
        rewards[0xC8D46eb7881975F9aE15216FeEBa2ff58E55803c] = 18;
        rewards[0x354371c378a880D2695c445226F36B94b8dE1F61] = 11;
        rewards[0x06da20fF018e3Dc3cFA9ea16f687bf3b22668914] = 8;
        rewards[0xF85fA2414a0647142C061CBADDB892Ea91696Ecf] = 68;
        rewards[0x3cAFF18D45E051a25F0B4ACd9F5C40001C541f7F] = 4;
        rewards[0x62C704b3645Ed6274c5220d324253b816855BC7C] = 11;
        rewards[0xF41499F6E105786576fb99cB0c060626Fb9f3A31] = 28;
        rewards[0x9428b02560e91608BD9780a916d5eB89Eb9a4b6D] = 2;
        rewards[0x64e5624790084F8Fb0e0cdF3e400828F2b68eAE3] = 1;
        rewards[0x74379C5ECA1cBb6Ecc1699755dfdDc256F4162A4] = 36;
        rewards[0xD814a8e950D84D78E7AC94Cb1d24739073F3026e] = 36;
        rewards[0xc4feAC1E44e8f051560B1E8B0b02dd8dD7c11485] = 2;
        rewards[0x58440dAc3D6962F3FAD231e2E238F02A7FbA8D7a] = 8;
        rewards[0x74De89721e8E86576b828B5F42057ABFb74F41C3] = 9;
        rewards[0x4DbE965AbCb9eBc4c6E9d95aEb631e5B58E70d5b] = 117;
        rewards[0xD895689d4e6390bFd43AeEff844bC8C98E76F7cD] = 35;
        rewards[0x9F9692FfF5Ce2C81737f62bccA101a7a7bC31c46] = 28;
        rewards[0x1012e83Da77E283910D00E9Dc1Af5B103d62db12] = 22;
        rewards[0xDbFe90f5bF1425eEa1489978048Fb03B1D37Ed2F] = 6;
        rewards[0x01b23f8cc7FBF107b0F39AA0Ba7C17eBAFb5D618] = 12;
        rewards[0x408c9B38919DDeF2EeD0008e4f89a378ec5c3922] = 6;
        rewards[0xFA6eb99d1F3A8692f39d8794B2Ce72D7E391E2e0] = 23;
        rewards[0xdeDee77Ec7163a77040dc18578776b39B58cE878] = 16;
        rewards[0xfCFf948994B89C47d39a77806Ad06f63482524b1] = 17;
        rewards[0xAb7559304eAd66D8CA0BC1e0365b6d1aE89c9077] = 2;
        rewards[0xE7083ea81d723a15400fEaF8424317aBA068f7e2] = 10;
        rewards[0x4CeD6205D981bDEB8F75DAAbAfF56Cb187281315] = 3;
        rewards[0x934AdbB72e3a8CbBd4DC0934Fd2Bd579948EAEfB] = 15;
        rewards[0x92A0bfeF7926Cb7bA584c37227b5b74B911068ff] = 6;
        rewards[0xe8B32939133DD60A04161cF61829270bD8b5Fc57] = 6;
        rewards[0x9053a30186a6C54422981859116C427f998CD894] = 9;
        rewards[0xc494a87A34F90C6CBf423776fDA3c072edB42a65] = 2;
        rewards[0xa9C83863bbfc4f152B7118F07608D4F61Fd6090e] = 5;
        rewards[0xBd1E1Cc9613B510d1669D1e79Fd0115C70a4C7be] = 5;
        rewards[0x597aAB0305ed1D37d1a009854303e927C468b52c] = 7;
        rewards[0xD6FC9B58774Bf3fa0B1ae0f1E701BA360E8B316B] = 2;
        rewards[0x5330D616c96118E6fc5290475B8eA377CfFB66B4] = 8;
        rewards[0x0e3c7363dEcaBFE24637CAAD9e6432c6Ab750648] = 3;
        rewards[0x0e3c7363dEcaBFE24637CAAD9e6432c6Ab750648] = 6;
        rewards[0xC2F3192dC907EA10e12582135d1335aD0846faAf] = 17;
        rewards[0xc6AFa04760A511a59D821CA1c2EE41C0cFa87927] = 3;
        rewards[0x6f974385AbBcB0417332d9f906ad42e75Fc2F31c] = 15;
        rewards[0x96e803C8c5aA5084a6507cf5b71289d3E9B14495] = 3;
        rewards[0x0dd12bc0B1F2fE03600A1f828CB50f046938295b] = 4;
        rewards[0x111cD92405B1Dfbd19882D361418F49D99d8FED8] = 3;
        rewards[0x8948e76B10612d4C3360917B02EDfA45b56588a9] = 1;
        rewards[0x8ca6F5e6ba3e7B85c9094D7Cc04308F3707134fA] = 31;
        rewards[0xC66135b1671aD1f2cAE217ff19234A77F7A0B00c] = 13;
        rewards[0x0799442CE0f90F8837fdeEce82Cd2735625B4bf9] = 265;
    }

    function claimRewards() external {
        require(rewards[msg.sender] > 0, "no more rewards for this address");
        safeNovaTransfer(msg.sender, rewards[msg.sender]*1 ether);
        rewards[msg.sender] = 0;
    }

    function swap(uint256 _amount) external {
        novaV1.transferFrom(msg.sender, address(this), _amount);
        safeNovaTransfer(msg.sender, _amount);
    }

    // Safe nova transfer function, just in case
    // if rounding error causes pool to not have enough NOVAs.
    function safeNovaTransfer(address _to, uint256 _amount) private {
        uint256 novaBal = novaV2.balanceOf(address(this));
        novaV2.transfer(_to, _amount > novaBal ? novaBal : _amount);
    }
}
