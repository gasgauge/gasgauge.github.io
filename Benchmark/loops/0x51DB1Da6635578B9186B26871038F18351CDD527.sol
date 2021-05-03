/**
 *Submitted for verification at Etherscan.io on 2020-12-16
*/

// hevm: flattened sources of src/rewardDecay.sol
//pragma solidity >0.4.13 >=0.4.23 >=0.5.12 >=0.5.0 <0.6.0 >=0.5.10 <0.6.0 >=0.5.12 <0.6.0;
pragma solidity >=0.5 <0.7.17;

////// src/IERC20.sol
/* pragma solidity ^0.5.0; */

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */
interface IERC20 {
    function decimals() external view returns (uint8);

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

    function mint(address account, uint256 amount) external;

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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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

////// src/ReentrancyGuard.sol
// SPDX-License-Identifier: MIT

/* pragma solidity ^0.5.12; */

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() internal {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

////// src/base.sol
/* pragma solidity ^0.5.0; */

/* import "./IERC20.sol"; */

interface IAdapter {
    function calc(
        address gem,
        uint256 acc,
        uint256 factor
    ) external view returns (uint256);
}

interface IGemForRewardChecker {
    function check(address gem) external view returns (bool);
}

////// src/lib.sol
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

/* pragma solidity >=0.5.12; */

contract LibNote {
    event LogNote(
        bytes4 indexed sig,
        address indexed usr,
        bytes32 indexed arg1,
        bytes32 indexed arg2,
        bytes data
    ) anonymous;

    modifier note {
        _;
        assembly {
            // log an 'anonymous' event with a constant 6 words of calldata
            // and four indexed topics: selector, caller, arg1 and arg2
            let mark := msize() // end of memory ensures zero
            mstore(0x40, add(mark, 288)) // update free memory pointer
            mstore(mark, 0x20) // bytes type data offset
            mstore(add(mark, 0x20), 224) // bytes size (padded)
            calldatacopy(add(mark, 0x40), 0, 224) // bytes payload
            log4(
                mark,
                288, // calldata
                shl(224, shr(224, calldataload(0))), // msg.sig
                caller(), // msg.sender
                calldataload(4), // arg1
                calldataload(36) // arg2
            )
        }
    }
}

contract Auth is LibNote {
    mapping(address => uint256) public wards;
    address public deployer;

    function rely(address usr) external note auth {
        wards[usr] = 1;
    }

    function deny(address usr) external note auth {
        wards[usr] = 0;
    }

    modifier auth {
        require(wards[msg.sender] == 1 || deployer == msg.sender, "Auth/not-authorized");
        _;
    }
}

////// src/safeMath.sol
/* pragma solidity ^0.5.0; */

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

    function min(uint x, uint y) internal pure returns (uint z) {
        return x <= y ? x : y;
    }
}

////// src/safeERC20.sol
/* pragma solidity ^0.5.12; */

/* import "./IERC20.sol"; */
/* import "./safeMath.sol"; */



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
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
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


////// src/lpTokenWrapper.sol
/**
 *Submitted for verification at Etherscan.io on 2020-08-12
 */

/**
 *Submitted for verification at Etherscan.io on
 */

/*
   ____            __   __        __   _
  / __/__ __ ___  / /_ / /  ___  / /_ (_)__ __
 _\ \ / // // _ \/ __// _ \/ -_)/ __// / \ \ /
/___/ \_, //_//_/\__//_//_/\__/ \__//_/ /_\_\
     /___/

* Synthetix: YFIRewards.sol
*
* Docs: https://docs.synthetix.io/
*
*
* MIT License
* ===========
*
* Copyright (c) 2020 Synthetix
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
*/

/* pragma solidity ^0.5.12; */

/* import "./IERC20.sol"; */
/* import "./base.sol"; */
/* import "./safeMath.sol"; */
/* import "./safeERC20.sol"; */

// File: @openzeppelin/contracts/math/Math.sol

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + (((a % 2) + (b % 2)) / 2);
    }
}

// File: @openzeppelin/contracts/GSN/Context.sol

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
    constructor() internal {}

    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: @openzeppelin/contracts/ownership/Ownable.sol

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
    constructor() internal {
        _owner = _msgSender();
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
        require(
            initializing || isConstructor() || !initialized,
            "Contract instance has already been initialized"
        );

        bool wasInitializing = initializing;
        initializing = true;
        initialized = true;

        _;

        initializing = wasInitializing;
    }

    /// @dev Returns true if and only if the function is running in the constructor
    function isConstructor() private view returns (bool) {
        // extcodesize checks the size of the code stored in an address, and
        // address returns the current address. Since the code is still not
        // deployed when running a constructor, any checks on its code size will
        // yield zero, making it an effective way to detect if a contract is
        // under construction or not.
        uint256 cs;
        assembly {
            cs := extcodesize(address)
        }
        return cs == 0;
    }

    // Reserved storage space to allow for layout changes in the future.
    uint256[50] private ______gap;
}

contract LPTokenWrapper is Initializable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct PairDesc {
        address gem;
        address adapter;
        address staker;
        uint256 factor;
        bytes32 name;
    }

    mapping(address => PairDesc) public pairDescs;

    address[] private registeredGems;

    uint256 public decimals = 18;

    uint256 public prec = 1e18;

    mapping(address => uint256) private _totalSupply;

    mapping(address => mapping(address => uint256)) private _amounts;
    mapping(address => mapping(address => uint256)) private _balances;

    IGemForRewardChecker public gemForRewardChecker;

    function checkGem(address gem) internal view returns (bool) {
        return gemForRewardChecker.check(gem);
    }

    function registerGem(address gem) internal {
        for (uint256 i = 0; i < registeredGems.length; i++) {
            if (registeredGems[i] == gem) {
                return;
            }
        }
        registeredGems.push(gem);
    }

    function totalSupply() public view returns (uint256) {
        uint256 res = 0;
        for (uint256 i = 0; i < registeredGems.length; i++) {
            res = res.add(_totalSupply[registeredGems[i]]);
        }
        return res.div(prec);
    }

    function balanceOf(address account) public view returns (uint256) {
        uint256 res = 0;
        for (uint256 i = 0; i < registeredGems.length; i++) {
            res = res.add(_balances[registeredGems[i]][account]);
        }
        return res.div(prec);
    }

    function calcCheckValue(uint256 amount, address gem) public view returns (uint256) {
        require(amount > 0);
        PairDesc storage desc = pairDescs[gem];
        require(desc.adapter != address(0x0));
        assert(desc.gem == gem);
        uint256 r = IAdapter(desc.adapter).calc(gem, amount, desc.factor);
        require(r > 0);
        return r;
    }

    function stakeLp(
        uint256 amount,
        address gem,
        address usr
    ) internal {
        uint256 value = calcCheckValue(amount, gem).mul(prec);

        _balances[gem][usr] = _balances[gem][usr].add(value);
        _amounts[gem][usr] = _amounts[gem][usr].add(amount);
        _totalSupply[gem] = _totalSupply[gem].add(value);
    }

    function withdrawLp(
        uint256 amount,
        address gem,
        address usr
    ) internal {
        uint256 value = amount.mul(_balances[gem][usr]).div(_amounts[gem][usr]);

        _balances[gem][usr] = _balances[gem][usr].sub(value);
        _amounts[gem][usr] = _amounts[gem][usr].sub(amount);
        _totalSupply[gem] = _totalSupply[gem].sub(value);
    }
}

////// src/rewardsDecayHolder.sol
/* pragma solidity ^0.5.12; */

/* import "./IERC20.sol"; */
/* import "./safeMath.sol"; */
/* import "./safeERC20.sol"; */

interface IRewarder {
    function stake(
        address account,
        uint256 amount,
        address gem
    ) external;

    function withdraw(
        address account,
        uint256 amount,
        address gem
    ) external;
}

contract StakingRewardsDecayHolder {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IRewarder public rewarder;

    uint256 public withdrawErrorCount;

    mapping(address => mapping(address => uint256)) public amounts;

    event withdrawError(uint256 amount, address gem);

    constructor(address _rewarder) public {
        rewarder = IRewarder(_rewarder);
    }

    function stake(uint256 amount, address gem) public {
        require(amount > 0, "Cannot stake 0");

        rewarder.stake(msg.sender, amount, gem);

        amounts[gem][msg.sender] = amounts[gem][msg.sender].add(amount);
        IERC20(gem).safeTransferFrom(msg.sender, address(this), amount);
    }

    function withdraw(uint256 amount, address gem) public {
        require(amount > 0, "Cannot withdraw 0");

        (bool success, ) =
            address(rewarder).call(
                abi.encodeWithSelector(rewarder.withdraw.selector, msg.sender, amount, gem)
            );
        if (!success) {
            //don't interfere with user to withdraw his money regardless
            //of potential rewarder's bug or hacks
            //only amounts map matters
            emit withdrawError(amount, gem);
            withdrawErrorCount++;
        }

        amounts[gem][msg.sender] = amounts[gem][msg.sender].sub(amount);
        IERC20(gem).safeTransfer(msg.sender, amount);
    }
}

////// src/rewardDecay.sol
/*
 * MIT License
 * ===========
 *
 * Copyright (c) 2020 Freeliquid
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 */

/* pragma solidity ^0.5.12; */

/* import "./lpTokenWrapper.sol"; */
/* import "./rewardsDecayHolder.sol"; */
/* import "./lib.sol"; */
/* import "./ReentrancyGuard.sol"; */

contract StakingRewardsDecay is LPTokenWrapper, Auth, ReentrancyGuard {
    address public gov;
    address public aggregator;
    uint256 public totalRewards = 0;

    struct EpochData {
        mapping(address => uint256) userRewardPerTokenPaid;
        mapping(address => uint256) rewards;
        uint256 initreward;
        uint256 duration;
        uint256 starttime;
        uint256 periodFinish;
        uint256 rewardRate;
        uint256 lastUpdateTime;
        uint256 rewardPerTokenStored;
        uint256 lastTotalSupply;
        bool closed;
    }

    uint256 public EPOCHCOUNT = 0;
    uint256 public epochInited = 0;
    EpochData[] public epochs;

    mapping(bytes32 => address) public pairNameToGem;

    mapping(address => uint256) public lastClaimedEpoch;
    mapping(address => uint256) public yetNotClaimedOldEpochRewards;
    uint256 public currentEpoch;

    StakingRewardsDecayHolder public holder;

    event RewardAdded(uint256 reward, uint256 epoch, uint256 duration, uint256 starttime);
    event StopRewarding();
    event Staked(address indexed user, address indexed gem, uint256 amount);
    event Withdrawn(address indexed user, address indexed gem, uint256 amount);
    event RewardTakeStock(address indexed user, uint256 reward, uint256 epoch);
    event RewardPaid(address indexed user, uint256 reward);

    constructor() public {
        deployer = msg.sender;
    }

    function initialize(address _gov, uint256 epochCount) public initializer {
        // only deployer can initialize
        require(deployer == msg.sender);

        gov = _gov;
        require(gov != address(0));
        require(epochCount > 0);

        EPOCHCOUNT = epochCount;
        EpochData memory data;
        for (uint256 i = 0; i < epochCount; i++) {
            epochs.push(data);
        }

        holder = new StakingRewardsDecayHolder(address(this));
    }

    function setupAggregator(address _aggregator) public {
        require(deployer == msg.sender);
        require(_aggregator != address(0));
        require(aggregator == address(0)); //only one set allowed

        aggregator = _aggregator;
    }

    function getStartTime() public view returns (uint256) {
        return epochs[0].starttime;
    }

    modifier checkStart() {
        require(block.timestamp >= getStartTime(), "not start");
        require(epochInited == EPOCHCOUNT, "not all epochs was inited");
        _;
    }

    function initRewardAmount(
        uint256 reward,
        uint256 starttime,
        uint256 duration,
        uint256 idx
    ) public {
        // only deployer can
        require(deployer == msg.sender);
        require(epochInited == 0, "not allowed after approve");
        initEpoch(reward, starttime, duration, idx);
    }

    function setupGemForRewardChecker(address a) public {
        require(deployer == msg.sender);
        gemForRewardChecker = IGemForRewardChecker(a);
    }

    function initEpoch(
        uint256 reward,
        uint256 starttime,
        uint256 duration,
        uint256 idx
    ) internal {
        require(idx < EPOCHCOUNT, "idx < EPOCHCOUNT");
        require(duration > 0, "duration > 0");
        require(starttime >= block.timestamp, "starttime > block.timestamp");

        EpochData storage epoch = epochs[idx];

        epoch.rewardPerTokenStored = 0;
        epoch.starttime = starttime;
        epoch.duration = duration;
        epoch.rewardRate = reward.div(duration);
        require(epoch.rewardRate > 0, "zero rewardRate");

        epoch.initreward = reward;
        epoch.lastUpdateTime = starttime;
        epoch.periodFinish = starttime.add(duration);

        emit RewardAdded(reward, idx, duration, starttime);
    }

    function initAllEpochs(
        uint256[] memory rewards,
        uint256 starttime,
        uint256 duration
    ) public {
        // only deployer can
        require(deployer == msg.sender);
        require(epochInited == 0, "not allowed after approve");

        require(duration > 0);
        require(starttime > 0);

        assert(rewards.length == EPOCHCOUNT);

        uint256 time = starttime;

        for (uint256 i = 0; i < EPOCHCOUNT; i++) {
            initEpoch(rewards[i], time, duration, i);
            time = time.add(duration);
        }
    }

    function getEpochRewardRate(uint256 epochIdx) public view returns (uint256) {
        return epochs[epochIdx].rewardRate;
    }

    function getEpochStartTime(uint256 epochIdx) public view returns (uint256) {
        return epochs[epochIdx].starttime;
    }

    function getEpochFinishTime(uint256 epochIdx) public view returns (uint256) {
        return epochs[epochIdx].periodFinish;
    }

    function getTotalRewards() public view returns (uint256 result) {
        require(epochInited == EPOCHCOUNT, "not inited");

        result = 0;

        for (uint256 i = 0; i < EPOCHCOUNT; i++) {
            result = result.add(epochs[i].initreward);
        }
    }

    function getTotalRewardTime() public view returns (uint256 result) {
        require(epochInited == EPOCHCOUNT, "not inited");

        result = 0;

        for (uint256 i = 0; i < EPOCHCOUNT; i++) {
            result = result.add(epochs[i].duration);
        }
    }

    function approveEpochsConsistency() public {
        require(deployer == msg.sender);
        require(epochInited == 0, "double call not allowed");

        uint256 totalReward = epochs[0].initreward;
        require(getStartTime() > 0);

        for (uint256 i = 1; i < EPOCHCOUNT; i++) {
            EpochData storage epoch = epochs[i];
            require(epoch.starttime > 0);
            require(epoch.starttime == epochs[i - 1].periodFinish);
            totalReward = totalReward.add(epoch.initreward);
        }

        require(IERC20(gov).balanceOf(address(this)) >= totalReward, "GOV balance not enought");

        epochInited = EPOCHCOUNT;
    }

    function resetDeployer() public {
        // only deployer can do it
        require(deployer == msg.sender);
        require(epochInited == EPOCHCOUNT);
        deployer = address(0);
    }

    function calcCurrentEpoch() public view returns (uint256 res) {
        res = 0;
        for (
            uint256 i = currentEpoch;
            i < EPOCHCOUNT && epochs[i].starttime <= block.timestamp;
            i++
        ) {
            res = i;
        }
    }

    modifier updateCurrentEpoch() {
        currentEpoch = calcCurrentEpoch();

        uint256 supply = totalSupply();
        epochs[currentEpoch].lastTotalSupply = supply;

        for (int256 i = int256(currentEpoch) - 1; i >= 0; i--) {
            EpochData storage epoch = epochs[uint256(i)];
            if (epoch.closed) {
                break;
            }

            epoch.lastTotalSupply = supply;
            epoch.closed = true;
        }

        _;
    }

    function registerPairDesc(
        address gem,
        address adapter,
        uint256 factor,
        bytes32 name
    ) public auth nonReentrant {
        require(gem != address(0x0), "gem is null");
        require(adapter != address(0x0), "adapter is null");

        require(checkGem(gem), "bad gem");

        require(pairNameToGem[name] == address(0) || pairNameToGem[name] == gem, "duplicate name");

        if (pairDescs[gem].name != "") {
            delete pairNameToGem[pairDescs[gem].name];
        }

        registerGem(gem);

        pairDescs[gem] = PairDesc({
            gem: gem,
            adapter: adapter,
            factor: factor,
            staker: address(0),
            name: name
        });

        pairNameToGem[name] = gem;
    }

    function getPairInfo(bytes32 name, address account)
        public
        view
        returns (
            address gem,
            uint256 avail,
            uint256 locked,
            uint256 lockedValue,
            uint256 availValue
        )
    {
        gem = pairNameToGem[name];
        if (gem == address(0)) {
            return (address(0), 0, 0, 0, 0);
        }

        PairDesc storage desc = pairDescs[gem];
        locked = holder.amounts(gem, account);
        lockedValue = IAdapter(desc.adapter).calc(gem, locked, desc.factor);
        avail = IERC20(gem).balanceOf(account);
        availValue = IAdapter(desc.adapter).calc(gem, avail, desc.factor);
    }

    function getPrice(bytes32 name) public view returns (uint256) {
        address gem = pairNameToGem[name];
        if (gem == address(0)) {
            return 0;
        }

        PairDesc storage desc = pairDescs[gem];
        return IAdapter(desc.adapter).calc(gem, 1, desc.factor);
    }

    function getRewardPerHour() public view returns (uint256) {
        EpochData storage epoch = epochs[calcCurrentEpoch()];
        return epoch.rewardRate * 3600;
    }

    function lastTimeRewardApplicable(EpochData storage epoch) internal view returns (uint256) {
        assert(block.timestamp >= epoch.starttime);
        return Math.min(block.timestamp, epoch.periodFinish);
    }

    function rewardPerToken(EpochData storage epoch, uint256 lastTotalSupply)
        internal
        view
        returns (uint256)
    {
        if (lastTotalSupply == 0) {
            return epoch.rewardPerTokenStored;
        }
        return
            epoch.rewardPerTokenStored.add(
                lastTimeRewardApplicable(epoch)
                    .sub(epoch.lastUpdateTime)
                    .mul(epoch.rewardRate)
                    .mul(1e18 * (10**decimals))
                    .div(lastTotalSupply)
            );
    }

    function earnedEpoch(
        address account,
        EpochData storage epoch,
        uint256 lastTotalSupply
    ) internal view returns (uint256) {
        return
            balanceOf(account)
                .mul(
                rewardPerToken(epoch, lastTotalSupply).sub(epoch.userRewardPerTokenPaid[account])
            )
                .div(1e18 * (10**decimals))
                .add(epoch.rewards[account]);
    }

    function earned(address account) public view returns (uint256 acc) {
        uint256 currentSupply = totalSupply();
        int256 lastClaimedEpochIdx = int256(lastClaimedEpoch[account]);

        for (int256 i = int256(calcCurrentEpoch()); i >= lastClaimedEpochIdx; i--) {
            EpochData storage epoch = epochs[uint256(i)];

            uint256 epochTotalSupply = currentSupply;
            if (epoch.closed) {
                epochTotalSupply = epoch.lastTotalSupply;
            }
            acc = acc.add(earnedEpoch(account, epoch, epochTotalSupply));
        }

        acc = acc.add(yetNotClaimedOldEpochRewards[account]);
    }

    function getRewardEpoch(address account, EpochData storage epoch) internal returns (uint256) {
        uint256 reward = earnedEpoch(account, epoch, epoch.lastTotalSupply);
        if (reward > 0) {
            epoch.rewards[account] = 0;
            return reward;
        }
        return 0;
    }

    function takeStockReward(address account) internal returns (uint256 acc) {
        for (uint256 i = lastClaimedEpoch[account]; i <= currentEpoch; i++) {
            uint256 reward = getRewardEpoch(account, epochs[i]);
            acc = acc.add(reward);
            emit RewardTakeStock(account, reward, i);
        }
        lastClaimedEpoch[account] = currentEpoch;
    }

    function gatherOldEpochReward(address account) internal {
        if (currentEpoch == 0) {
            return;
        }

        uint256 acc = takeStockReward(account);
        yetNotClaimedOldEpochRewards[account] = yetNotClaimedOldEpochRewards[account].add(acc);
    }

    function stakeEpoch(
        uint256 amount,
        address gem,
        address usr,
        EpochData storage epoch
    ) internal updateReward(usr, epoch) {
        gatherOldEpochReward(usr);
        stakeLp(amount, gem, usr);
        emit Staked(usr, gem, amount);
    }

    function stake(
        address account,
        uint256 amount,
        address gem
    ) public nonReentrant checkStart updateCurrentEpoch {
        require(address(holder) == msg.sender);
        assert(amount > 0);
        stakeEpoch(amount, gem, account, epochs[currentEpoch]);
    }

    function withdrawEpoch(
        uint256 amount,
        address gem,
        address usr,
        EpochData storage epoch
    ) internal updateReward(usr, epoch) {
        gatherOldEpochReward(usr);
        withdrawLp(amount, gem, usr);
        emit Withdrawn(usr, gem, amount);
    }

    function withdraw(
        address account,
        uint256 amount,
        address gem
    ) public nonReentrant checkStart updateCurrentEpoch {
        require(address(holder) == msg.sender);
        assert(amount > 0);
        withdrawEpoch(amount, gem, account, epochs[currentEpoch]);
    }

    function getRewardCore(address account)
        internal
        checkStart
        updateCurrentEpoch
        updateReward(account, epochs[currentEpoch])
        returns (uint256 acc)
    {
        acc = takeStockReward(account);

        acc = acc.add(yetNotClaimedOldEpochRewards[account]);
        yetNotClaimedOldEpochRewards[account] = 0;

        if (acc > 0) {
            totalRewards = totalRewards.add(acc);
            IERC20(gov).safeTransfer(account, acc);
            emit RewardPaid(account, acc);
        }
    }

    function getReward() public nonReentrant returns (uint256) {
        return getRewardCore(msg.sender);
    }

    function getRewardEx(address account) public nonReentrant returns (uint256) {
        require(aggregator == msg.sender);
        return getRewardCore(account);
    }

    modifier updateReward(address account, EpochData storage epoch) {
        assert(account != address(0));

        epoch.rewardPerTokenStored = rewardPerToken(epoch, epoch.lastTotalSupply);
        epoch.lastUpdateTime = lastTimeRewardApplicable(epoch);
        epoch.rewards[account] = earnedEpoch(account, epoch, epoch.lastTotalSupply);
        epoch.userRewardPerTokenPaid[account] = epoch.rewardPerTokenStored;
        _;
    }
}

contract RewardDecayAggregator {
    using SafeMath for uint256;

    StakingRewardsDecay[2] public rewarders;

    constructor(address rewarder0, address rewarder1) public {
        rewarders[0] = StakingRewardsDecay(rewarder0);
        rewarders[1] = StakingRewardsDecay(rewarder1);
    }

    function claimReward() public {
        for (uint256 i = 0; i < rewarders.length; i++) {
            rewarders[i].getRewardEx(msg.sender);
        }
    }

    function earned() public view returns (uint256 res) {
        for (uint256 i = 0; i < rewarders.length; i++) {
            res = res.add(rewarders[i].earned(msg.sender));
        }
    }
}
