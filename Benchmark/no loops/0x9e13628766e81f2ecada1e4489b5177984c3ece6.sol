/**

 *Submitted for verification at Etherscan.io on 2020-12-20

*/



// ███████╗░█████╗░██████╗░██████╗░███████╗██████╗░░░░███████╗██╗

// ╚════██║██╔══██╗██╔══██╗██╔══██╗██╔════╝██╔══██╗░░░██╔════╝██║

// ░░███╔═╝███████║██████╔╝██████╔╝█████╗░░██████╔╝░░░█████╗░░██║

// ██╔══╝░░██╔══██║██╔═══╝░██╔═══╝░██╔══╝░░██╔══██╗░░░██╔══╝░░██║

// ███████╗██║░░██║██║░░░░░██║░░░░░███████╗██║░░██║██╗██║░░░░░██║

// ╚══════╝╚═╝░░╚═╝╚═╝░░░░░╚═╝░░░░░╚══════╝╚═╝░░╚═╝╚═╝╚═╝░░░░░╚═╝

// Copyright (C) 2020 zapper



// This program is free software: you can redistribute it and/or modify

// it under the terms of the GNU Affero General Public License as published by

// the Free Software Foundation, either version 2 of the License, or

// (at your option) any later version.

//

// This program is distributed in the hope that it will be useful,

// but WITHOUT ANY WARRANTY; without even the implied warranty of

// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the

// GNU Affero General Public License for more details.

//



///@author Zapper

///@notice This contract mints cover/no-cover tokens and deposits them in their respective balancer pools



// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol



//pragma solidity ^0.5.5;
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

    event Approval(

        address indexed owner,

        address indexed spender,

        uint256 value

    );

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

    function sub(

        uint256 a,

        uint256 b,

        string memory errorMessage

    ) internal pure returns (uint256) {

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

    function div(

        uint256 a,

        uint256 b,

        string memory errorMessage

    ) internal pure returns (uint256) {

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

    function mod(

        uint256 a,

        uint256 b,

        string memory errorMessage

    ) internal pure returns (uint256) {

        require(b != 0, errorMessage);

        return a % b;

    }

}



/**

 * @dev Collection of functions related to the address type

 */

library Address {

    /**

     * @dev Returns true if `account` is a contract.

     *

     * [IMPORTANT]

     * ====

     * It is unsafe to assume that an address for which this function returns

     * false is an externally-owned account (EOA) and not a contract.

     *

     * Among others, `isContract` will return false for the following

     * types of addresses:

     *

     *  - an externally-owned account

     *  - a contract in construction

     *  - an address where a contract will be created

     *  - an address where a contract lived, but was destroyed

     * ====

     */

    function isContract(address account) internal view returns (bool) {

        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts

        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned

        // for accounts without code, i.e. `keccak256('')`

        bytes32 codehash;





            bytes32 accountHash

         = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;

        // solhint-disable-next-line no-inline-assembly

        assembly {

            codehash := extcodehash(account)

        }

        return (codehash != accountHash && codehash != 0x0);

    }



    /**

     * @dev Converts an `address` into `address payable`. Note that this is

     * simply a type cast: the actual underlying value is not changed.

     *

     * _Available since v2.4.0._

     */

    function toPayable(address account)

        internal

        pure

        returns (address payable)

    {

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

        require(

            address(this).balance >= amount,

            "Address: insufficient balance"

        );



        // solhint-disable-next-line avoid-call-value

        (bool success, ) = recipient.call.value(amount)("");

        require(

            success,

            "Address: unable to send value, recipient may have reverted"

        );

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



    function safeTransfer(

        IERC20 token,

        address to,

        uint256 value

    ) internal {

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



    function safeApprove(

        IERC20 token,

        address spender,

        uint256 value

    ) internal {

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



    function safeIncreaseAllowance(

        IERC20 token,

        address spender,

        uint256 value

    ) internal {

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



    function safeDecreaseAllowance(

        IERC20 token,

        address spender,

        uint256 value

    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(

            value,

            "SafeERC20: decreased allowance below zero"

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

        require(address(token).isContract(), "SafeERC20: call to non-contract");



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

 * _Since v2.5.0:_ this module is now much more gas efficient, given net gas

 * metering changes introduced in the Istanbul hardfork.

 */

contract ReentrancyGuard {

    bool private _notEntered;



    constructor() internal {

        // Storing an initial non-zero value makes deployment a bit more

        // expensive, but in exchange the refund on every call to nonReentrant

        // will be lower in amount. Since refunds are capped to a percetange of

        // the total transaction's gas, it is best to keep them low in cases

        // like this one, to increase the likelihood of the full refund coming

        // into effect.

        _notEntered = true;

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

        require(_notEntered, "ReentrancyGuard: reentrant call");



        // Any calls to nonReentrant after this point will fail

        _notEntered = false;



        _;



        // By storing the original value once again, a refund is triggered (see

        // https://eips.ethereum.org/EIPS/eip-2200)

        _notEntered = true;

    }

}



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

    address payable public _owner;



    event OwnershipTransferred(

        address indexed previousOwner,

        address indexed newOwner

    );



    /**

     * @dev Initializes the contract setting the deployer as the initial owner.

     */

    constructor() internal {

        address payable msgSender = _msgSender();

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

    function transferOwnership(address payable newOwner) public onlyOwner {

        _transferOwnership(newOwner);

    }



    /**

     * @dev Transfers ownership of the contract to a new account (`newOwner`).

     */

    function _transferOwnership(address payable newOwner) internal {

        require(

            newOwner != address(0),

            "Ownable: new owner is the zero address"

        );

        emit OwnershipTransferred(_owner, newOwner);

        _owner = newOwner;

    }

}



interface IBFactory {

    function isBPool(address b) external view returns (bool);

}



interface IBPool {

    function joinswapExternAmountIn(

        address tokenIn,

        uint256 tokenAmountIn,

        uint256 minPoolAmountOut

    ) external payable returns (uint256 poolAmountOut);



    function isBound(address t) external view returns (bool);

}



interface ICoverFactory {

    function getAllProtocolAddresses() external view returns (address[] memory);

}



interface ICoverProtocol {

    function addCover(

        address _collateral,

        uint48 _timestamp,

        uint256 _amount

    ) external returns (bool);



    function activeCovers(uint256 _index) external view returns (address);



    function activeCoversLength() external view returns (uint256);

}



interface ICover {

    function getCoverDetails()

        external

        view

        returns (

            string memory _name,

            uint48 _expirationTimestamp,

            address _collateral,

            uint256 _claimNonce,

            address _claimCovToken,

            address _noclaimCovToken

        );

}



contract Cover_ZapIn_General_V1 is ReentrancyGuard, Ownable {

    using SafeMath for uint256;

    using Address for address;

    using SafeERC20 for IERC20;



    bool public stopped = false;

    uint16 public goodwill;



    address payable

        private constant zgoodwillAddress = 0x3CE37278de6388532C3949ce4e886F365B14fB56;



    address

        public constant collateralAddress = 0x6B175474E89094C44Da98b954EedeAC495271d0F;



    ICoverFactory public constant coverFactory = ICoverFactory(

        0xedfC81Bf63527337cD2193925f9C0cF2D537AccA

    );



    IBFactory public constant BalancerFactory = IBFactory(

        0x9424B1412450D0f8Fc2255FAf6046b98213B76Bd

    );



    event Zapin(

        address toWhomToIssue,

        address protocolCovered,

        uint256 claimRec,

        uint256 noClaimRec,

        uint256 claimBPTRec,

        uint256 noClaimBPTRec

    );



    constructor(uint16 _goodwill) public {

        goodwill = _goodwill;

    }



    // circuit breaker modifiers

    modifier stopInEmergency {

        if (stopped) {

            revert("Temporarily Paused");

        } else {

            _;

        }

    }



    /**

    @notice This function is used to mint cover for a supported protocol and add the cover/no-cover to balancer pools

    @param _fromTokenAddress The token used for investment (address(0x00) if ether)

    @param _protocolAddress The address of protocol to acquire cover for

    @param _claimBalancerAddress The balancer pool address for cover

    @param _noClaimBalancerAddress The balancer pool address for no-cover 

    @param _amount The amount of ERC to invest, use any arbitrary value if ether

    @param _allowanceTarget Spender for the swap

    @param _swapTarget Excecution target for the swap

    @param swapData DEX quote data

    @return Claim/No-Claim BPT Received

     */

    function ZapIn(

        address _fromTokenAddress,

        address _protocolAddress,

        address _claimBalancerAddress,

        address _noClaimBalancerAddress,

        uint256 _amount,

        address _allowanceTarget,

        address _swapTarget,

        bytes calldata swapData

    )

        external

        payable

        nonReentrant

        stopInEmergency

        returns (

            uint256 claimRec,

            uint256 noClaimRec,

            uint256 claimBpt,

            uint256 noClaimBpt

        )

    {

        uint256 valueToSend;

        address tokenToSend;

        if (_fromTokenAddress == address(0)) {

            require(msg.value > 0, "ERR: No ETH sent");

            valueToSend = _transferGoodwill(_fromTokenAddress, msg.value);

        } else {

            require(_amount > 0, "Err: No Tokens Sent");

            require(msg.value == 0, "ERR: ETH sent with Token");

            tokenToSend = _fromTokenAddress;

            IERC20(tokenToSend).safeTransferFrom(

                msg.sender,

                address(this),

                _amount

            );

            valueToSend = _transferGoodwill(_fromTokenAddress, _amount);

        }



        if (_fromTokenAddress != collateralAddress) {

            valueToSend = _fillQuote(

                tokenToSend,

                valueToSend,

                _allowanceTarget,

                _swapTarget,

                swapData

            );

        }

        (claimRec, noClaimRec, claimBpt, noClaimBpt) = _enterPosition(

            _protocolAddress,

            valueToSend,

            _claimBalancerAddress,

            _noClaimBalancerAddress

        );



        IERC20(_claimBalancerAddress).safeTransfer(msg.sender, claimBpt);



        IERC20(_noClaimBalancerAddress).safeTransfer(msg.sender, noClaimBpt);



        emit Zapin(

            msg.sender,

            _protocolAddress,

            claimRec,

            noClaimRec,

            claimBpt,

            noClaimBpt

        );

    }



    function _enterPosition(

        address _protocolAddress,

        uint256 amount,

        address _claimBalancerAddress,

        address _noClaimBalancerAddress

    )

        internal

        returns (

            uint256 claimRec,

            uint256 noClaimRec,

            uint256 claimBpt,

            uint256 noClaimBpt

        )

    {

        (claimRec, noClaimRec) = _enterCover(_protocolAddress, amount);



        (claimBpt, noClaimBpt) = _enterBalancer(

            _protocolAddress,

            claimRec,

            noClaimRec,

            _claimBalancerAddress,

            _noClaimBalancerAddress

        );

    }



    function _enterBalancer(

        address _protocolAddress,

        uint256 claimAmt,

        uint256 noClaimAmt,

        address _claimBalancerAddress,

        address _noClaimBalancerAddress

    ) internal returns (uint256 claimBptRec, uint256 noClaimBptRec) {

        (, address _claim, address _noClaim) = _getCoverDetails(

            _protocolAddress

        );

        IBPool balancerClaim = IBPool(_claimBalancerAddress);

        IBPool balancerNoClaim = IBPool(_noClaimBalancerAddress);



        require(

            balancerClaim.isBound(_claim) && balancerNoClaim.isBound(_noClaim),

            "Token not bound"

        );



        IERC20(_claim).safeApprove(address(_claimBalancerAddress), claimAmt);



        IERC20(_noClaim).safeApprove(

            address(_noClaimBalancerAddress),

            noClaimAmt

        );



        claimBptRec = balancerClaim.joinswapExternAmountIn(_claim, claimAmt, 1);

        noClaimBptRec = balancerNoClaim.joinswapExternAmountIn(

            _noClaim,

            noClaimAmt,

            1

        );

    }



    function _enterCover(address _protocolAddress, uint256 amount)

        internal

        returns (uint256, uint256)

    {

        (uint48 timestamp, address _claim, address _noclaim) = _getCoverDetails(

            _protocolAddress

        );

        IERC20 claim = IERC20(_claim);

        IERC20 noClaim = IERC20(_noclaim);



        uint256 initialBalanceClaim = claim.balanceOf(address(this));

        uint256 initialBalancenoClaim = noClaim.balanceOf(address(this));



        ICoverProtocol protocol = ICoverProtocol(_protocolAddress);



        IERC20(collateralAddress).safeApprove(address(_protocolAddress), 0);

        IERC20(collateralAddress).safeApprove(

            address(_protocolAddress),

            amount

        );



        bool success = protocol.addCover(collateralAddress, timestamp, amount);



        require(success, "Error minting CLAIM/NO-CLAIM Tokens");



        uint256 claimRec = claim.balanceOf(address(this)).sub(

            initialBalanceClaim

        );

        uint256 noClaimRec = claim.balanceOf(address(this)).sub(

            initialBalancenoClaim

        );



        return (claimRec, noClaimRec);

    }



    function _fillQuote(

        address _fromTokenAddress,

        uint256 _amount,

        address _allowanceTarget,

        address _swapTarget,

        bytes memory swapData

    ) internal returns (uint256 collateralBought) {

        uint256 valueToSend;

        if (_fromTokenAddress == address(0)) {

            valueToSend = _amount;

        } else {

            IERC20 fromToken = IERC20(_fromTokenAddress);

            fromToken.safeApprove(address(_allowanceTarget), 0);

            fromToken.safeApprove(address(_allowanceTarget), _amount);

        }



        IERC20 collateral = IERC20(collateralAddress);



        uint256 initialBalance = collateral.balanceOf(address(this));



        (bool success, ) = _swapTarget.call.value(valueToSend)(swapData);

        require(success, "Error Swapping Tokens");



        collateralBought = collateral.balanceOf(address(this)).sub(

            initialBalance

        );



        require(collateralBought > 0, "Swapped to Invalid Intermediate");

    }



    function _getCoverDetails(address _protocolAddress)

        internal

        view

        returns (

            uint48 timestamp,

            address _claim,

            address _noClaim

        )

    {

        ICoverProtocol protocol = ICoverProtocol(_protocolAddress);



        ICover cover = ICover(

            protocol.activeCovers((protocol.activeCoversLength()).sub(1))

        );



        (, timestamp, , , _claim, _noClaim) = cover.getCoverDetails();

    }



    /**

    @dev This function is used to calculate and transfer goodwill

    @param _tokenContractAddress Token from which goodwill is deducted

    @param valueToSend The total value being zapped in

    @return The quantity of remaining tokens

     */

    function _transferGoodwill(

        address _tokenContractAddress,

        uint256 valueToSend

    ) internal returns (uint256) {

        if (goodwill == 0) return valueToSend;



        uint256 goodwillPortion = SafeMath.div(

            SafeMath.mul(valueToSend, goodwill),

            10000

        );

        if (_tokenContractAddress == address(0)) {

            zgoodwillAddress.transfer(goodwillPortion);

        } else {

            IERC20(_tokenContractAddress).safeTransfer(

                zgoodwillAddress,

                goodwillPortion

            );

        }

        return valueToSend.sub(goodwillPortion);

    }



    function set_new_goodwill(uint16 _new_goodwill) public onlyOwner {

        require(

            _new_goodwill >= 0 && _new_goodwill < 10000,

            "GoodWill Value not allowed"

        );

        goodwill = _new_goodwill;

    }



    function inCaseTokengetsStuck(address _tokenAddress) public onlyOwner {

        IERC20 tokenAddress = IERC20(_tokenAddress);

        uint256 qty = tokenAddress.balanceOf(address(this));

        tokenAddress.safeTransfer(owner(), qty);

    }



    // - to Pause the contract

    function toggleContractActive() public onlyOwner {

        stopped = !stopped;

    }



    // - to withdraw any ETH balance sitting in the contract

    function withdraw() public onlyOwner {

        uint256 contractBalance = address(this).balance;

        address payable _to = owner().toPayable();

        _to.transfer(contractBalance);

    }

}
