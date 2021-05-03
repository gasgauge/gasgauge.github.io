/**
 *Submitted for verification at Etherscan.io on 2020-12-16
*/

// hevm: flattened sources of src/uni.sol
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

////// src/uni.sol
/* pragma solidity ^0.5.0; */

/* import "./base.sol"; */
/* import "./safeMath.sol"; */

interface UniswapV2PairLike {
    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );
}

contract UniswapAdapterForStables is IAdapter {
    using SafeMath for uint256;

    struct TokenPair {
        address t0;
        address t1;
        uint256 r0;
        uint256 r1;
        uint256 usdPrec;
    }

    function calc(
        address gem,
        uint256 value,
        uint256 factor
    ) external view returns (uint256) {
        (uint112 _reserve0, uint112 _reserve1, ) = UniswapV2PairLike(gem).getReserves();

        TokenPair memory tokenPair;
        tokenPair.usdPrec = 10**6;

        tokenPair.t0 = UniswapV2PairLike(gem).token0();
        tokenPair.t1 = UniswapV2PairLike(gem).token1();

        tokenPair.r0 = uint256(_reserve0).mul(tokenPair.usdPrec).div(
            uint256(10)**IERC20(tokenPair.t0).decimals()
        );
        tokenPair.r1 = uint256(_reserve1).mul(tokenPair.usdPrec).div(
            uint256(10)**IERC20(tokenPair.t1).decimals()
        );

        uint256 totalValue = tokenPair.r0.min(tokenPair.r1).mul(2); //total value in uni's reserves for stables only

        uint256 supply = UniswapV2PairLike(gem).totalSupply();

        return value.mul(totalValue).mul(factor).mul(1e18).div(supply.mul(tokenPair.usdPrec));
    }
}

contract UniswapAdapterWithOneStable is IAdapter {
    using SafeMath for uint256;

    struct LocalVars {
        address t0;
        address t1;
        uint256 totalValue;
        uint256 supply;
        uint256 usdPrec;
    }

    address public deployer;
    address public buck;

    constructor() public {
        deployer = msg.sender;
    }

    function setup(address _buck) public {
        require(deployer == msg.sender);
        buck = _buck;
        deployer = address(0);
    }

    function calc(
        address gem,
        uint256 value,
        uint256 factor
    ) external view returns (uint256) {
        (uint112 _reserve0, uint112 _reserve1, ) = UniswapV2PairLike(gem).getReserves();

        LocalVars memory loc;
        loc.t0 = UniswapV2PairLike(gem).token0();
        loc.t1 = UniswapV2PairLike(gem).token1();
        loc.usdPrec = 10**6;

        if (buck == loc.t0) {
            loc.totalValue = uint256(_reserve0).mul(loc.usdPrec).div(
                uint256(10)**IERC20(loc.t0).decimals()
            );
        } else if (buck == loc.t1) {
            loc.totalValue = uint256(_reserve1).mul(loc.usdPrec).div(
                uint256(10)**IERC20(loc.t1).decimals()
            );
        } else {
            require(false, "gem w/o buck");
        }

        loc.supply = UniswapV2PairLike(gem).totalSupply();

        return
            value.mul(loc.totalValue).mul(2).mul(factor).mul(1e18).div(
                loc.supply.mul(loc.usdPrec)
            );
    }
}

contract UniForRewardCheckerBase {
    mapping(address => bool) public tokens;

    function check(address gem) external {
        address t0 = UniswapV2PairLike(gem).token0();
        address t1 = UniswapV2PairLike(gem).token1();

        require(tokens[t0] && tokens[t1], "non-approved-stable");
    }
}

contract UniForRewardCheckerMainnet is UniForRewardCheckerBase {
    constructor(address usdfl, address gov) public {
        tokens[usdfl] = true;
        tokens[gov] = true;
        tokens[0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48] = true; //usdc
        tokens[0xdAC17F958D2ee523a2206206994597C13D831ec7] = true; //usdt
        tokens[0x6B175474E89094C44Da98b954EedeAC495271d0F] = true; //dai
        tokens[0x674C6Ad92Fd080e4004b2312b45f796a192D27a0] = true; //usdn
    }
}

contract UniForRewardCheckerKovan is UniForRewardCheckerBase {
    constructor(address usdfl, address gov) public {
        tokens[usdfl] = true;
        tokens[gov] = true;
        tokens[0xe22da380ee6B445bb8273C81944ADEB6E8450422] = true; //usdc
        tokens[0x13512979ADE267AB5100878E2e0f485B568328a4] = true; //usdt
        tokens[0xFf795577d9AC8bD7D90Ee22b6C1703490b6512FD] = true; //dai
        tokens[0x5f99471D242d04C42a990A33e8233f5B48F89C43] = true; //usdn
    }
}

contract UniForRewardCheckerRinkeby is UniForRewardCheckerBase {
    constructor(address usdfl, address gov) public {
        tokens[usdfl] = true;
        tokens[gov] = true;
        tokens[0x4DBCdF9B62e891a7cec5A2568C3F4FAF9E8Abe2b] = true; //usdc
        tokens[0xD9BA894E0097f8cC2BBc9D24D308b98e36dc6D02] = true; //usdt
        tokens[0x97833b01a73733065684A851Fd1E91D7951b5fD8] = true; //dai
        tokens[0x033C5b4A8E1b8A2f3b5A7451a9defD561028a8C5] = true; //usdn
    }
}
