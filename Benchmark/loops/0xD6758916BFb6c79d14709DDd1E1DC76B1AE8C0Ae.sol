/**
 *Submitted for verification at Etherscan.io on 2020-09-20
*/

//pragma solidity >=0.5.0 <0.7.0;
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
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }
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

contract CrustDist is Ownable {
  event CrustDisted(bool);

  function distCrust(IERC20 token) public onlyOwner {
    sendTo(token, "0xa1CEc90603405dA9578c88cDc8cAe7e098532DEa",	7500);
    sendTo(token, "0x8E01D740059a87695e6D9a66af3e9a75Be1576Cf",	3000);
    sendTo(token, "0x728e7bfa3db937c6356d9bd45ec89de58d288306",	3000);
    sendTo(token, "0x7582d0b7A150F6227B447a0F282BFF612F0F4b3E",	15000);
    sendTo(token, "0x14efa7A804b255f5232daf42B1dFbB877a87d296",	7500);
    sendTo(token, "0x96c22ab164276CF08CF9f9d1835F1F2e5495e867",	3000);
    sendTo(token, "0xB529C2aDE6F002C895F6191481dbA83b3589896F",	1500);
    sendTo(token, "0xDc4d0D92Ae598Ae497a7Fa824BFf7f9492df691B",	1500);
    sendTo(token, "0x9C9A257abAF94e5dE6abFF8733b9208b42cBa285",	7500);
    sendTo(token, "0xB6799F729Ff7bF37043fD68A364e56adceE78644",	22500);
    sendTo(token, "0x5BF303AaC65aF35A76daC3eA68aC4fAe1bb5d4a2",	7500);
    sendTo(token, "0x97d3810E18fC20483485bfdeB43d8CC78aDB8ff1",	3000);
    sendTo(token, "0x96481CB0fCd7673254eBccC42DcE9B92da10ea04",	3000);
    sendTo(token, "0xA93ee2d5ac5b802B9a8dBBC4Db2Cb3A772E89c7C",	2250);
    sendTo(token, "0x9e8852d0089f8b632f1a399957b03e548937f01c",	3000);
    sendTo(token, "0xcc0ed336c650eed2859AD1186a68de3C89f75731",	3000);
    sendTo(token, "0x90FFFbbdf770eFB530d950C24bf56a292CDab3F7",	6000);
    sendTo(token, "0xdE3df72601b79acec367eECc2d126BD946ACB320",	3000);
    sendTo(token, "0x17ec047622C000Df03599026A3B39871EC9384DB",	2074);
    sendTo(token, "0x6eCF0edc48eAFb59936475cBCE615dF56adA8a38",	750);
    sendTo(token, "0x3Cc24Dd521101AcFe77BD68106473f48841F0AB4",	750);
    sendTo(token, "0x5d3d15d9529BC296FD490472541b778a5c648b74",	3000);
    sendTo(token, "0x8d4DE035D3f696682B503c8D022D3e4f7F550C91",	7500);
    sendTo(token, "0xFcd4Bcc346A59137D3fcd4130F838b06BbF20BCe",	6000);
    sendTo(token, "0x17336338bE8E8B4557eb9F16782B2Bf2b5c1fF09",	7500);
    sendTo(token, "0xe1139a6c4f6271c929f68fb106504b67d873a283",	12000);
    sendTo(token, "0x5692BD676eb69B0658B6438035d6BbC5Bd2Dc740",	3000);
    sendTo(token, "0xf98fF587fEb37db9e6934DDaf1aB377240430753",	2250);
    sendTo(token, "0xF6f1640ed4B6Aba6807e84a85dDA657729A28935", 4500);
    sendTo(token, "0x4cD4Bc363458b52380d695b5c923b8994A245281",	1500);
    sendTo(token, "0xDD518d796196Dc3Bb91aD15932DBEF8a26109f3d",	7500);
    sendTo(token, "0xc00a49ebA7e57Bf3A0f597185194EF489707f75e",	9000);
    sendTo(token, "0x6A95E05B8B530C49C3F0601564D3683cc2F6d799",	7059);
    sendTo(token, "0x2489146cf124A6900bA46c6F76f18eC76d5068b9",	7059);
    sendTo(token, "0x34231a6b9a27dBF7295989952673B34c405bDb13",	7059);
    sendTo(token, "0x4233168fe150776bA6f8CDA98c90411b54551502",	9750);
    sendTo(token, "0x0231e2Ef6861E1Acfe3C3d9ba5AC9E185FF0848f", 3000);
    sendTo(token, "0x0FEf682990c99003acf47CB9CD872b43544547c9",	7500);
    sendTo(token, "0xEe4e4905325F064a4AcF06f7e5Bd7bD9bE9e869c",	15000);
    sendTo(token, "0x04E3343064754Fd09967899FFE6743d5bF60DFc5",	1500);
    sendTo(token, "0xdcef5DA3a52bC3D4C5FCCCDfdE656cC4f3364fdD",	4500);
    sendTo(token, "0xD55dB39F464B8A3E292925Ffb22DdC36D542b12e",	45000);
    sendTo(token, "0x831a7d2ef63ebbaa97a2806a17a3de91b79b09b2",	7500);
    sendTo(token, "0x01B15fA475DA05c0c84e1D78b360a1bB509AaBF2",	8250);
    emit CrustDisted(true);
  }

  function withDrawAll(IERC20 token) public onlyOwner {
    uint256 balance = token.balanceOf(address(this));
    token.transfer(msg.sender, balance);
  }

  // amount: number of tokens without decimals
  function sendTo(IERC20 token, string memory to, uint256 amount) private {
    address toAddr = parseAddr(to);
    uint256 total = SafeMath.mul(amount, 10 ** 18);
    token.transfer(toAddr, total);
  }

function parseAddr(string memory _a) internal pure returns (address _parsedAddress) {
        bytes memory tmp = bytes(_a);
        uint160 iaddr = 0;
        uint160 b1;
        uint160 b2;
        for (uint i = 2; i < 2 + 2 * 20; i += 2) {
            iaddr *= 256;
            b1 = uint160(uint8(tmp[i]));
            b2 = uint160(uint8(tmp[i + 1]));
            if ((b1 >= 97) && (b1 <= 102)) {
                b1 -= 87;
            } else if ((b1 >= 65) && (b1 <= 70)) {
                b1 -= 55;
            } else if ((b1 >= 48) && (b1 <= 57)) {
                b1 -= 48;
            }
            if ((b2 >= 97) && (b2 <= 102)) {
                b2 -= 87;
            } else if ((b2 >= 65) && (b2 <= 70)) {
                b2 -= 55;
            } else if ((b2 >= 48) && (b2 <= 57)) {
                b2 -= 48;
            }
            iaddr += (b1 * 16 + b2);
        }
        return address(iaddr);
    }

}
