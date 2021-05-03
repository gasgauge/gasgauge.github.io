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
/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
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
 contract AtomicProxyInterface {

    function checkAddresses(address _dappAddressOne, address _dappAddressTwo) public ;

    function safeTransferFrom(address _dapp, address _from, address _to, uint256 _tokenId) public ;

}

 contract ERC721Interface {

  function approve(address to, uint256 tokenId) public ;

}

contract AtomicSwap is IERC721Receiver, Ownable, Pausable {

    // Importo i contatori

    using Counters for Counters.Counter;

    // Costanti per gestire il tempo in formato unix timestamp

    uint256 constant secs = 86400;



    // Dichiaro contatori

    Counters.Counter private _swapIds;



    // Flag per gestire la create swap

    bool private swapFlag;

    

    // Stato dello swap

    enum swapStatus { Opened, Closed, Cancelled }

    

    // Rappresentazione dello swap

    struct swapIntent {

        Counters.Counter id;

        address nftOwnerOne;

        address dappAddressOne;

        uint256 nftTokenIdOne;

        address nftOwnerTwo;

        address dappAddressTwo;

        uint256 nftTokenIdTwo;

        uint256 swapStart;

        uint256 swapEnd;

        swapStatus status;

    }

    

    struct paymentStruct {

        bool status;

        uint256 value;

    }

    

    // Mapping chiave/valore per ottenere le informazioni sullo swap

    mapping (address => swapIntent[]) swapList;

    mapping (address => Counters.Counter) swapCount;

    

    address public proxyAddress;

    AtomicProxyInterface proxyInterface;

    ERC721Interface erc721Interface;

    paymentStruct payment;

    

    

    // Events

    event swapEvent(address indexed _swapCreator, uint256 indexed time, swapStatus indexed _status, uint256 _swapId, address _swapCounterPart);

    event paymentReceived(address indexed _payer, uint256 _value);

    

    constructor() public {

        payment.status=false;

        payment.value=0;

    }



    //Questa chiamata ogni qual volta vengono inviati degli ethereum con il calldata empty

    function receive() external payable { 

        emit paymentReceived(msg.sender, msg.value);

    }

    

    // Creo lo swap

    function createSwapIntent(address _dappAddressOne, uint256 _tokenIdOne, address _dappAddressTwo, uint256 _tokenIdTwo) payable public isPaused {

        swapFlag = false;

        if((_dappAddressOne == _dappAddressTwo) && (_tokenIdOne == _tokenIdTwo))

            swapFlag = true;

            require(swapFlag==false, "Impossible to swap the same item");

        if(payment.status)

            require(msg.value>=payment.value, "Not enought WEI for handle the transaction");

        proxyInterface.checkAddresses(_dappAddressOne, _dappAddressTwo);

        _swapIds = swapCount[msg.sender];

        swapList[msg.sender].push(swapIntent(_swapIds, msg.sender, _dappAddressOne, _tokenIdOne, address(0), _dappAddressTwo, _tokenIdTwo, block.timestamp, 0, swapStatus.Opened));

        proxyInterface.safeTransferFrom(_dappAddressOne, msg.sender, address(this), _tokenIdOne);

        emit swapEvent(msg.sender, (block.timestamp-(block.timestamp%secs)), swapStatus.Opened, _swapIds.current(), address(0));

        emit paymentReceived(msg.sender, msg.value);

        _swapIds.increment();

        swapCount[msg.sender] = _swapIds;

    }

    

    // Concludo lo swap

    function closeSwapIntent(address _swapCreator, uint256 _swapId) payable public isPaused {

        require(swapList[_swapCreator][_swapId].status == swapStatus.Opened, "Swap Status is not opened");

        if(payment.status)

            require(msg.value>=payment.value, "Not enought WEI for handle the transaction");

        swapList[_swapCreator][_swapId].nftOwnerTwo = msg.sender;

        swapList[_swapCreator][_swapId].swapEnd = block.timestamp;

        swapList[_swapCreator][_swapId].status = swapStatus.Closed;

        proxyInterface.safeTransferFrom(swapList[_swapCreator][_swapId].dappAddressTwo, msg.sender, swapList[_swapCreator][_swapId].nftOwnerOne, swapList[_swapCreator][_swapId].nftTokenIdTwo);

        erc721Interface = ERC721Interface(swapList[_swapCreator][_swapId].dappAddressOne);

        erc721Interface.approve(proxyAddress, swapList[_swapCreator][_swapId].nftTokenIdOne);

        proxyInterface.safeTransferFrom(swapList[_swapCreator][_swapId].dappAddressOne, address(this), swapList[_swapCreator][_swapId].nftOwnerTwo, swapList[_swapCreator][_swapId].nftTokenIdOne);

        emit swapEvent(msg.sender, (block.timestamp-(block.timestamp%secs)), swapStatus.Closed, _swapId, _swapCreator);

        emit paymentReceived(msg.sender, msg.value);

    }



    // Cancello lo swap

    function cancelSwapIntent(uint256 _swapId) public {

        require(swapList[msg.sender][_swapId].status == swapStatus.Opened, "Swap Status is not opened");

        erc721Interface = ERC721Interface(swapList[msg.sender][_swapId].dappAddressOne);

        erc721Interface.approve(proxyAddress, swapList[msg.sender][_swapId].nftTokenIdOne);

        swapList[msg.sender][_swapId].swapEnd = block.timestamp;

        swapList[msg.sender][_swapId].status = swapStatus.Cancelled;

        proxyInterface.safeTransferFrom(swapList[msg.sender][_swapId].dappAddressOne, address(this), msg.sender, swapList[msg.sender][_swapId].nftTokenIdOne);

        emit swapEvent(msg.sender, (block.timestamp-(block.timestamp%secs)), swapStatus.Cancelled, _swapId, address(0));

    }

    

    //FIXME: SERVE? Si attiva quando viene utilizzata la SafeTransfer

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external  returns (bytes4) {

        return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));

    }

    

    // Abbino l'indirizzo all'interfaccia del proxy

    function setProxyAddress(address _proxyAddress) public onlyOwner isPaused {

        proxyAddress = _proxyAddress;

        proxyInterface = AtomicProxyInterface(_proxyAddress);

    }

    

    // Setto il pagamento

    function setPayment(bool _status, uint256 _value) public onlyOwner isPaused {

        payment.status = _status;

        payment.value = _value;

    }

    

    // Ottengo l'importo di WEI settato

    function getWeiPayValueAmount() public view returns(uint256) {

        return payment.value;

    }

    

    // Ottengo il numero di swap legati a questo indirizzo

    function getSwapCount() public view returns(uint256) {

        return swapCount[msg.sender].current();

    }

    

    // Ottengo lo swap indicato

    function getSwapIntentByAddress(address _creator, uint256 _index) public view returns(swapIntent memory) {

        return swapList[_creator][_index];

    }



    // Ottengo gli swap dell'owner passando l'id

    function getSwapIntentByOwner(uint256 _index) public view returns(swapIntent memory) {

        return swapList[msg.sender][_index];

    }



    // Ottengo il balance dello smart contract

    function getVaultBalance() public view onlyOwner isPaused returns(uint256) {

        return address(this).balance;

    }



    // Sposto il balance dello smart contract

    function sendVaultBalance(uint256 _amount, address payable _receiver) public onlyOwner isPaused {

        require(address(this).balance>= _amount, "Not enought WEI in the balance");

        _receiver.transfer(_amount);

    }

}
