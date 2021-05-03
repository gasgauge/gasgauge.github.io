/**

 *Submitted for verification at Etherscan.io on 2020-12-18

*/



// SPDX-License-Identifier: MIT

//pragma solidity >=0.6.0 <0.8.0;
pragma solidity >=0.5 <0.7.17;
pragma experimental ABIEncoderV2;


// 
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

// 
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

// 
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

// 
/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented or decremented by one. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 * Since it is not possible to overflow a 256 bit integer with increments of one, `increment` can skip the {SafeMath}
 * overflow check, thereby saving gas. This does assume however correct usage, in that the underlying `_value` is never
 * directly accessed.
 */
library Counters {
    using SafeMath for uint256;

    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        // The {SafeMath} overflow check can be skipped here, see the comment at the top
        counter._value += 1;
    }

    function decrement(Counter storage counter) internal {
        counter._value = counter._value.sub(1);
    }
}

// 
contract Pausable is Ownable {

    bool pause;

    

    constructor() public {

        pause = false;

    }

    

    function setPauseStatus(bool _pauseStatus) public onlyOwner {

        pause = _pauseStatus;

    }

    

    function getPauseStatus() view public returns(bool)  {

        return pause;

    }

    

    modifier isPaused() {

        require(pause==false, "The system is paused");

        _;

    }

}

// 
 contract ERC721Interface {

  function safeTransferFrom(address _from, address _to, uint256 _tokenId) public ;

  function approve(address to, uint256 tokenId) public ;

}

contract AtomicProxy is Ownable, Pausable {

    // Importo i contatori

    using Counters for Counters.Counter;

    // Dichiaro contatori

    Counters.Counter private _erc721DappIndex;

    

    // Struct per verificare se la dapp è gestita o meno

    struct Erc721Dapp {

        ERC721Interface erc721Interface;

        uint256 index;

        bool enabled;

    }

    

    mapping(uint256 => address) addressIndexErc721Map;

    mapping(address => uint256) counterIndexErc721Map;

    mapping(address => Erc721Dapp) erc721Map;

    

    address[] erc721Handled;

    mapping(address => uint256) erc721IndexHandled;

    

    modifier erc721AddressIsAvailable(address _erc721address) {

        require(erc721Map[_erc721address].enabled==false, "erc721 address already available");

        _;

    }

    

    modifier erc721AddressIsNotAvailable(address _erc721address) {

        require(erc721Map[_erc721address].enabled==true, "erc721 is not available");

        _;

    }

    

    // Aggiungo un nuovo contratto ERC721

    function addERC721Contract(address _erc721address) public onlyOwner isPaused erc721AddressIsAvailable(_erc721address) {

        _erc721DappIndex.increment();

        addressIndexErc721Map[_erc721DappIndex.current()] = _erc721address;

        counterIndexErc721Map[_erc721address] = _erc721DappIndex.current();

        erc721Map[_erc721address] = Erc721Dapp(ERC721Interface(_erc721address), _erc721DappIndex.current(), true);

        erc721Handled.push(_erc721address);

        erc721IndexHandled[_erc721address] = erc721Handled.length - 1;

    }

    

    // Rimuovo un contratto ERC721

    function removeERC721Contract(address _erc721address) public onlyOwner isPaused erc721AddressIsNotAvailable(_erc721address) {

        uint256 ausCounter;

        ausCounter = counterIndexErc721Map[_erc721address];

        addressIndexErc721Map[ausCounter] = address(0);

        counterIndexErc721Map[_erc721address] = 0;

        erc721Map[_erc721address] = Erc721Dapp(ERC721Interface(_erc721address), ausCounter, false);

        _removeElementByIndex(erc721IndexHandled[_erc721address]);

    }

    

    // Ottengo i contratti gestiti dalla nostra dapp

    function getDappHandled() public view returns(address[] memory) {

        return erc721Handled;

    }

    

    // Rimuovo l'elemento dall'array

    function _removeElementByIndex(uint index) internal onlyOwner isPaused {

      require(index < erc721Handled.length);

      uint256 ausIndex = erc721Handled.length-1;

      address ausAddress = erc721Handled[erc721Handled.length-1];

      erc721Handled[index] = erc721Handled[erc721Handled.length-1];

      erc721Handled[ausIndex] = ausAddress;

      erc721Handled.pop();

    }

    

    // Controllo che i due indirizzi siano presenti sullo smart contract

    function checkAddresses(address _dappAddressOne, address _dappAddressTwo) public view {

        require(erc721Map[_dappAddressOne].enabled==true, "_dappAddressOne not available");

        require(erc721Map[_dappAddressTwo].enabled==true, "_dappAddressTwo not available");

    }

    

    // Gestisco lo swap verso AtomicSwap

    function safeTransferFrom(address _dapp, address _from, address _to, uint256 _tokenId) public isPaused {

        erc721Map[_dapp].erc721Interface.safeTransferFrom(_from, _to, _tokenId);

    }

}
