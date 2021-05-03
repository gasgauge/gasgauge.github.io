/**
 *Submitted for verification at Etherscan.io on 2020-09-11
*/

// File: contracts/libs/SafeMath.sol

// SPDX-License-Identifier: GPL-2.0

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
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// File: contracts/interfaces/IERC20.sol


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

// File: contracts/libs/SafeERC20.sol


pragma solidity >=0.5 <0.7.17;



library SafeERC20 {
    function transfer(IERC20 _token, address _to, uint256 _val) internal returns (bool) {
        (bool success, bytes memory data) = address(_token).call(abi.encodeWithSelector(_token.transfer.selector, _to, _val));
        return success && (data.length == 0 || abi.decode(data, (bool)));
    }
}

// File: contracts/libs/PineUtils.sol


pragma solidity >=0.5 <0.7.17;




library PineUtils {
    address internal constant ETH_ADDRESS = address(0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee);

    /**
     * @notice Get the account's balance of token or ETH
     * @param _token - Address of the token
     * @param _addr - Address of the account
     * @return uint256 - Account's balance of token or ETH
     */
    function balanceOf(IERC20 _token, address _addr) internal view returns (uint256) {
        if (ETH_ADDRESS == address(_token)) {
            return _addr.balance;
        }

        return _token.balanceOf(_addr);
    }

     /**
     * @notice Transfer token or ETH to a destinatary
     * @param _token - Address of the token
     * @param _to - Address of the recipient
     * @param _val - Uint256 of the amount to transfer
     * @return bool - Whether the transfer was success or not
     */
    function transfer(IERC20 _token, address _to, uint256 _val) internal returns (bool) {
        if (ETH_ADDRESS == address(_token)) {
            (bool success, ) = _to.call.value(_val)("");
            return success;
        }

        return SafeERC20.transfer(_token, _to, _val);
    }
}

// File: contracts/commons/Order.sol


pragma solidity >=0.5 <0.7.17;


contract Order {
    address public constant ETH_ADDRESS = address(0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee);
}

// File: contracts/interfaces/IHandler.sol

pragma solidity >=0.5 <0.7.17;


interface IHandler {
    /// @notice receive ETH
   function receive() external payable;

    /**
     * @notice Handle an order execution
     * @param _inputToken - Address of the input token
     * @param _outputToken - Address of the output token
     * @param _inputAmount - uint256 of the input token amount
     * @param _minReturn - uint256 of the min return amount of output token
     * @param _data - Bytes of arbitrary data
     * @return bought - Amount of output token bought
     */
    function handle(
        IERC20 _inputToken,
        IERC20 _outputToken,
        uint256 _inputAmount,
        uint256 _minReturn,
        bytes calldata _data
    ) external payable returns (uint256 bought);

    /**
     * @notice Check whether can handle an order execution
     * @param _inputToken - Address of the input token
     * @param _outputToken - Address of the output token
     * @param _inputAmount - uint256 of the input token amount
     * @param _minReturn - uint256 of the min return amount of output token
     * @param _data - Bytes of arbitrary data
     * @return bool - Whether the execution can be handled or not
     */
    function canHandle(
        IERC20 _inputToken,
        IERC20 _outputToken,
        uint256 _inputAmount,
        uint256 _minReturn,
        bytes calldata _data
    ) external view returns (bool);
}

// File: contracts/handlers/OneInchHandler.sol


pragma solidity >=0.5 <0.7.17;






/// @notice UniswapV1 Handler used to execute an order

interface IOneSplitWrapper {
    function swap(
        address fromToken,
        address toToken,
        uint256 amount,
        uint256 minReturn,
        uint256[] calldata distribution,
        uint256 flags
    ) external payable;
}

contract OneinchHandler is IHandler, Order {
    using SafeMath for uint256;

    IOneSplitWrapper public  oneSplitWrapper;

    uint256 private constant never = uint(-1);

    /**
     * @notice Creates the handler
     * @param _oneSplitWrapper - Address of oneSplitWrapper
     */
    constructor(IOneSplitWrapper _oneSplitWrapper) public {
        oneSplitWrapper = _oneSplitWrapper;
    }

    /// @notice receive ETH
   function receive() external  payable {
        require(msg.sender != tx.origin, "UniswapV1Handler#receive: NO_SEND_ETH_PLEASE");
    }

    /**
     * @notice Handle an order execution
     * @param _inputToken - Address of the input token
     * @param _outputToken - Address of the output token
     * @param _data - Bytes of arbitrary data
     * @return bought - Amount of output token bought
     */
    function handle(
        IERC20 _inputToken,
        IERC20 _outputToken,
        uint256,
        uint256,
        bytes calldata _data
    ) external payable  returns (uint256 bought) {
        // Load real initial balance, don't trust provided value
        uint256 inputAmount = PineUtils.balanceOf(_inputToken, address(this));
        address inputToken = address(_inputToken);
        address outputToken = address(_outputToken);

        (,address payable relayer, uint256 fee, uint256 flag, uint256[] memory distributionsA, uint256[] memory distributionsB) =
             abi.decode(_data, (address, address, uint256, uint256, uint256[], uint256[]));

        if (inputToken == ETH_ADDRESS) {
            // Keep some eth for paying the fee
            uint256 sell = inputAmount.sub(fee);
            bought = _swap(inputToken, outputToken, sell, msg.sender, distributionsA, flag);
        } else if (outputToken == ETH_ADDRESS) {
            // Convert
            bought = _swap(inputToken, outputToken, inputAmount, address(this), distributionsA, flag);
            bought = bought.sub(fee);

            // Send amount bought
            (bool successSender,) = msg.sender.call.value(bought)("");
            require(successSender, "UniswapV1Handler#handle: TRANSFER_ETH_TO_CALLER_FAILED");
        } else {
            // Convert from fromToken to ETH
            uint256 boughtEth = _swap(inputToken, outputToken, inputAmount, address(this), distributionsA, flag);

            // Convert from ETH to toToken
            bought = _swap(inputToken, outputToken, boughtEth.sub(fee), msg.sender, distributionsB, flag);
        }

        // Send fee to relayer
        (bool successRelayer,) = relayer.call.value(fee)("");
        require(successRelayer, "UniswapV1Handler#handle: TRANSFER_ETH_TO_RELAYER_FAILED");
    }

    /**
     * @notice Check whether can handle an order execution
     * @return bool - Whether the execution can be handled or not
     */
    function canHandle(
        IERC20,
        IERC20,
        uint256,
        uint256,
        bytes calldata
    ) external  view returns (bool) {
       return false;
    }

    /**
     * @notice Swap input token to output token
     * @param _inputToken - Address of the input token
     * @param _outputToken - Address of the output token
     * @param _inputAmount - uint256 of the input token amount
     * @param _recipient - Address of the recipient
     * @param _distributions - Array of weights for volume distribution
     * @param _flag - flags
     * @return bought - Amount of output token bought
     */
    function _swap(
        address _inputToken,
        address _outputToken,
        uint256 _inputAmount,
        address _recipient,
        uint256[] memory _distributions,
        uint256 _flag
    ) internal returns (uint256 bought) {
        // Check if previous allowance is enough and approve the pool if not
        IERC20 inputToken = IERC20(_inputToken);

        uint256 prevAllowance = inputToken.allowance(address(this), address(oneSplitWrapper));
        if (prevAllowance < _inputAmount) {
            if (prevAllowance != 0) {
                inputToken.approve(address(oneSplitWrapper), 0);
            }

            inputToken.approve(address(oneSplitWrapper), uint(-1));
        }

        oneSplitWrapper.swap(
            _inputToken,
            _outputToken,
            _inputAmount,
            0,
            _distributions,
            _flag
        );

        bought = PineUtils.balanceOf(IERC20(_outputToken), address(this));

        if (_recipient != address(this)) {
            PineUtils.transfer(IERC20(_outputToken), _recipient, bought);
        }
    }
}
