/**
 *Submitted for verification at Etherscan.io on 2020-12-22
*/

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

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

// File: openzeppelin-solidity/contracts/GSN/Context.sol

//pragma solidity ^0.5.0;
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

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

//pragma solidity ^0.5.0;
pragma solidity >=0.5 <0.7.17;

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

// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol

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

// File: openzeppelin-solidity/contracts/utils/Address.sol

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

// File: openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol

//pragma solidity ^0.5.0;
pragma solidity >=0.5 <0.7.17;




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

// File: contracts/EscrowService.sol

//pragma solidity 0.5.15;
pragma solidity >=0.5 <0.7.17;






contract EscrowService is Ownable {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    enum Status {_, CREATED, FUNDED, DISPUTED, RELEASED, MEDIATED, CANCELLED}

    address private _mediationService;

    //This will be in percentage. 200 for 2%
    uint256 private _mediationServiceFee;

    //TODO: add getter and setters
    address private _feeWallet;

    //TODO: add getter and settes
    uint256 private _fee;

    address constant private ETH_ADDRESS = address(
        0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE
    );

    mapping(address => bool) private _supportedTokens;

    struct Escrow {
        address creator;
        address depositor;
        address recepient;
        address mediator;
        address beneficiary;
        address token;
        uint256 amount;
        uint256 lastDepositTime;
        uint256 createdTime;
        uint256 mediationFee;
        string extraData;
        string reason;
        Status status;
    }

    mapping (uint256 => Escrow) private _idVsEscrow;

    //TODO: add getter
    uint256 private _totalEscrows;

    event TokenAdded(address token);
    event TokenRemoved(address token);

    event MediationServiceChanged(address mediationService);
    event MeidationServiceFeeChanged(uint256 fee);

    event FeeChanged(uint256 indexed fee);
    event FeeWalletChanged(address indexed feeWallet);

    event EscrowAdded(
        address indexed depositor,
        address indexed recepient,
        address indexed mediator,
        uint256 id,
        address token
    );
    //This event is added to listen for creator
    event EscrowCreated(uint256 id, address indexed creator);

    event Funded(uint256 indexed id);
    event Disputed(uint256 indexed id, address party);
    event Cancelled(uint256 id);
    event Released(uint256 id, address indexed receiver);

    modifier tokenSupported(address token){
        require(_supportedTokens[token], "EscrowService: Token not supported");
        _;
    }

    modifier escrowExist(uint256 id){
        require(
            id != 0 && id <= _totalEscrows,
            "EscroService: Invalid escrow"
        );
        _;
    }

    constructor(
        address mediationService,
        uint256 mediationServiceFee,
        uint256 fee,
        address feeWallet
    )
        public
    {
        require(
            mediationService != address(0),
            "EscrowService: Invalid mediation service!!"
        );

        _mediationService = mediationService;
        _mediationServiceFee = mediationServiceFee;
        _fee = fee;
        _feeWallet = feeWallet;
    }

    /**
    * @dev Returns fee wallet
    */
    function getFeeWallet() external view returns(address){
        return _feeWallet;
    }

    /**
    * @dev Allows owner to set fee wallet
    * @param feeWallet Fee wallet address
    */
    function setFeeWallet(address feeWallet) external onlyOwner {
        require(
            feeWallet == address(0),
            "EscrowService: Invalid fee wallet address"
        );
        _feeWallet = feeWallet;
        emit FeeWalletChanged(_feeWallet);

    }
    
    /**
    @dev Returns platform fee
    */
    function getFee() external view returns(uint256) {
        return _fee;
    }
    
    /**
    * @dev Allows owner to set fee
    * @param fee New fees
    */
    function setFee(uint256 fee) external onlyOwner {
        _fee = fee;
        emit FeeChanged(fee);
    }

    /**
    * @dev Returns total escrows so far
    */
    function getTotalEscrows() external view returns(uint256) {
        return _totalEscrows;
    }
    
    /**
    * @dev Returns mediation service address
    */
    function getMediationService() external view returns(address) {
        return _mediationService;
    }

    /**
    * @dev Allows admin to change mediationService address
    * @param mediationService New mediation service
    */
    function changeMediationService(
        address mediationService
    )
        external
        onlyOwner
    {
        require(
            mediationService != address(0),
            "EscrowService: Invalid mediation service!!"
        );

        _mediationService = mediationService;
        emit MediationServiceChanged(mediationService);
    }

    /**
    * @dev Returns mediation service fee
    */
    function getMediationServiceFee() external view returns(uint256) {
        return _mediationServiceFee;
    }

    /**
    * @dev Allow admin to change mediation service fee
    * @param mediationServiceFee New mediation service fee
    */
    function changeMediationServiceFee(
        uint256 mediationServiceFee
    )
        external
        onlyOwner
    {
        _mediationServiceFee = mediationServiceFee;
        emit MeidationServiceFeeChanged(mediationServiceFee);
    }

    /**
    * @dev Returns whether given token is supported or not
    * @param tokenAddress Token to be checked
    */
    function isTokenSupported(
        address tokenAddress
    )
        external
        view
        returns(bool)
    {
        return _supportedTokens[tokenAddress];
    }

    /**
    * @dev Allows admin to add new supported token
    * @param tokenAddress token address to be added
    */
    function addToken(address tokenAddress) external onlyOwner {
        require(tokenAddress != address(0), "EscrowService: Invalid address");
        _supportedTokens[tokenAddress] = true;
        emit TokenAdded(tokenAddress);
    }

    /**
    * @dev Allows admin to remove supported token
    * @param tokenAddress Token to be removed
    */
    function removeToken(address tokenAddress) external onlyOwner {
        require(tokenAddress != address(0), "EscrowService: Invalid address");
        _supportedTokens[tokenAddress] = false;
        emit TokenRemoved(tokenAddress);
    }

    /**
    * @dev Returns Escrow for the given id
    * @param id Id to be fetched
    */
    function getEscrow(uint256 id) external view returns(
        address creator,
        address depositor,
        address recepient,
        address mediator,
        address token,
        uint256 amount,
        uint256 lastDepositTime,
        uint256 mediationFee,
        string memory extraData,
        Status status,
        uint256 createdTime,
        address beneficiary
    )
    {
        Escrow memory escrow = _idVsEscrow[id];
        creator = escrow.creator;
        depositor = escrow.depositor;
        recepient = escrow.recepient;
        mediator = escrow.mediator;
        token = escrow.token;
        amount = escrow.amount;
        lastDepositTime = escrow.lastDepositTime;
        mediationFee = escrow.mediationFee;
        extraData = escrow.extraData;
        status = escrow.status;
        createdTime = escrow.createdTime;
        beneficiary = escrow.beneficiary;

        return(
            creator,
            depositor,
            recepient,
            mediator,
            token,
            amount,
            lastDepositTime,
            mediationFee,
            extraData,
            status,
            createdTime,
            beneficiary
        );
    }


    /**
    * @dev Allows depositor or recepient to release funds to either party
    * @param id id of the escrow
    * @param beneficiary Beneficiary of the release
    */
    function release(
        uint256 id,
        address beneficiary
    )
        external
        escrowExist(id)
    {
        Escrow storage escrow = _idVsEscrow[id];

        require(
            escrow.status == Status.FUNDED,
            "EscrowService: Escrow can not be released"
        );

        require(
            (msg.sender == escrow.depositor && beneficiary == escrow.recepient) ||
            (msg.sender == escrow.recepient && beneficiary == escrow.depositor),
            "EscrowService: Illegal release of funds"
        );

        escrow.status = Status.RELEASED;
        escrow.beneficiary = beneficiary;

        _release(
            escrow.token,
            escrow.amount,
            beneficiary
        );
        emit Released(id, beneficiary);
    }

    /**
    * @dev Allows depositor to deposit funds in the escrow
    * @param id id of the escrow
    */
    function deposit(
        uint256 id
    )
        external
        payable
        escrowExist(id)
    {
        Escrow storage escrow = _idVsEscrow[id];

        require(
            escrow.depositor == address(0) || escrow.depositor == msg.sender,
            "EscrowService: Invalid depositor"
        );

        require(
            escrow.status == Status.CREATED,
            "EscrowService: Not accepting deposit"
        );

        if(escrow.lastDepositTime >= block.timestamp) {
            _deposit(
                escrow.token,
                escrow.amount,
                msg.value
            );
            escrow.status = Status.FUNDED;
            escrow.depositor = msg.sender;
            emit Funded(id);
        }
        else {
            escrow.status = Status.CANCELLED;
            emit Cancelled(id);
        }
    }

    /**
    * @dev allows depositor or recepient to raise dispute
    * @param id id of the escrow
    */
    function raiseDispute(
        uint256 id
    )
        external
        escrowExist(id)
    {
        Escrow storage escrow = _idVsEscrow[id];

        require(
            msg.sender == escrow.depositor ||
            msg.sender == escrow.recepient,
            "EscrowService: Access denied"
        );

        require(
            escrow.status == Status.FUNDED,
            "EscrowService: Escrow can not be disputed"
        );

        escrow.status = Status.DISPUTED;
        emit Disputed(id, msg.sender);
    }

    /**
    * @dev Allows mediator to mediate disputed escrow
    * @param id id of the escrow
    * @param beneficiary to whom escrow will be released
    * @param reason ipfs link to the reason 
    */
    function mediate(
        uint256 id,
        address beneficiary,
        string calldata reason
    )
        external
        escrowExist(id)
    {
        Escrow storage escrow = _idVsEscrow[id];

        require(
            escrow.status == Status.DISPUTED,
            "EscrowService: Escrow not in disputed state"
        );

        require(
            msg.sender == escrow.mediator,
            "EscrowService: Access denied"
        );

        require(
            beneficiary == escrow.depositor ||
            beneficiary == escrow.recepient,
            "EscrowService: Invalid beneficiary"
        );
        uint256 tempAmount = escrow.amount;
        uint256 mediationFee = tempAmount.mul(escrow.mediationFee).div(10000);
        tempAmount = tempAmount.sub(mediationFee);
        escrow.status = Status.MEDIATED;
        escrow.reason = reason;
        escrow.beneficiary = beneficiary;
        
        _release(
            escrow.token,
            mediationFee,
            escrow.mediator
        );

        _release(
            escrow.token,
            tempAmount,
            beneficiary
        );

        emit Released(id, beneficiary);
    }

    /**
    * @dev Add new escrow
    * @param tokenAddress Token to be used for escrow
    * @param recepient Address of the recepient
    * @param depositor Address of the depositor
    * @param mediator Address of the meidator
    * @param amount Amount of escrow
    * @param lastDepositTime Deposit time threshold
    * @param mediationFee Mediation fee in percentage. 100 for 1%
    * @param extraData Extra information, if any
    */
    function addEscrow(
        address tokenAddress,
        address recepient,
        address depositor,
        address mediator,
        uint256 amount,
        uint256 lastDepositTime,
        uint256 mediationFee,
        string memory extraData
    )
        public
        payable
        tokenSupported(tokenAddress)
    {
        require(recepient != address(0), "EscrowService: Invalid recepient");

        _totalEscrows = _totalEscrows.add(1);
        uint256 remValue = _takeFee(
            tokenAddress,
            amount,
            msg.value
        );

        Escrow storage escrow = _idVsEscrow[_totalEscrows];

        //1. Check if creator is depositor
        if (msg.sender == depositor){
            // Make the deposit
            _deposit(
                tokenAddress,
                amount,
                remValue
            );
            escrow.status = Status.FUNDED;
            emit Funded(_totalEscrows);
        }
        else {
            require(lastDepositTime > block.timestamp, "EscrowService: Invalid last deposit time");
            escrow.status = Status.CREATED;
        }
        if (mediator == address(0)) {
            escrow.mediator = _mediationService;
            escrow.mediationFee = _mediationServiceFee;
        }
        else {
            escrow.mediator = mediator;
            escrow.mediationFee = mediationFee;
        }

        escrow.token = tokenAddress;
        escrow.recepient = recepient;
        escrow.depositor = depositor;
        escrow.creator = msg.sender;
        escrow.amount = amount;
        escrow.extraData = extraData;
        escrow.lastDepositTime = lastDepositTime;
        escrow.createdTime = now;

        emit EscrowCreated(_totalEscrows, msg.sender);

        emit EscrowAdded(
            depositor,
            recepient,
            escrow.mediator,
            _totalEscrows,
            tokenAddress
        );

    }

    //Helper method to deposit funds
    function _deposit(
        address token,
        uint256 amount,
        uint256 msgValue
    )
        private
    {
        if (token == ETH_ADDRESS) {
            require(msgValue == amount, "EscrowService: Enough ETH not sent!!");
        }
        else {
            IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        }
    }


    //Helper method
    function _takeFee(
        address tokenAddress,
        uint256 amount,
        uint256 msgValue
    )
        private
        returns(uint256)
    {
        uint256 remValue = 0;
        uint256 fee = amount.mul(_fee).div(10000);

        if (tokenAddress == ETH_ADDRESS) {
            require(msgValue >= fee, "EscrowService: Enough ETH not sent!!");
            (bool success,) = _feeWallet.call.value(fee)("");
            require(success, "EscrowService: Transfer of fee failed");
            remValue = msgValue.sub(fee);
        }
        else{
            IERC20(tokenAddress).safeTransferFrom(msg.sender, _feeWallet, fee);
        }
        return remValue;
    }

    //Helper method to release funds
    function _release(
        address token,
        uint256 amount,
        address beneficiary
    )
        private
    {
        if (token == ETH_ADDRESS) {
            (bool success,) = beneficiary.call.value(amount)("");
            require(success, "EscrowService: Transfer failed");
        }
        else{
            IERC20(token).safeTransfer(beneficiary, amount);
        }
    }

}
