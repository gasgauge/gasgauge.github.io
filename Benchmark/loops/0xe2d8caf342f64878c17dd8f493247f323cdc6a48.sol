/**
 *Submitted for verification at Etherscan.io on 2020-09-05
*/

//pragma solidity 0.5.16;
//pragma solidity>=0.5;
pragma solidity >=0.5 <0.7.17;


contract fesschain {

    function transferFrom (address,address, uint256) external returns (bool);
    function balanceOf(address) public view returns (uint256);
    function allowance(address, address) external view returns (uint256);
    function transfer (address, uint256) external returns (bool);

}

contract Owned {

    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed from, address indexed _to);

    constructor(address _owner) public {
        owner = _owner;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}

contract Pausable is Owned {
    event Pause();
    event Unpause();

    bool public paused = false;

    modifier whenNotPaused() {
      require(!paused);
      _;
    }

    modifier whenPaused() {
      require(paused);
      _;
    }

    function pause() onlyOwner whenNotPaused public {
      paused = true;
      emit Pause();
    }

    function unpause() onlyOwner whenPaused public {
      paused = false;
      emit Unpause();
    }
}

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see `ERC20Detailed`.
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
     * Emits a `Transfer` event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through `transferFrom`. This is
     * zero by default.
     *
     * This value changes when `approve` or `transferFrom` are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * > Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an `Approval` event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a `Transfer` event.
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
     * a call to `approve`. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

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
        require(b <= a, "SafeMath: subtraction overflow");
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
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
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
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

}

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol

/**
 * @dev Implementation of the `IERC20` interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using `_mint`.
 * For a generic mechanism see `ERC20Mintable`.
 *
 * *For a detailed writeup see our guide [How to implement supply
 * mechanisms](https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226).*
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an `Approval` event is emitted on calls to `transferFrom`.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard `decreaseAllowance` and `increaseAllowance`
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See `IERC20.approve`.
 */
contract ERC20 is IERC20, Pausable {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    /**
     * @dev See `IERC20.totalSupply`.
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See `IERC20.balanceOf`.
     */
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }


    /**
     * @dev See `IERC20.allowance`.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See `IERC20.approve`.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }


    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to `approve` that can be used as a mitigation for
     * problems described in `IERC20.approve`.
     *
     * Emits an `Approval` event indicating the updated allowance.
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
     * This is an alternative to `approve` that can be used as a mitigation for
     * problems described in `IERC20.approve`.
     *
     * Emits an `Approval` event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to `transfer`, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a `Transfer` event.
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

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a `Transfer` event with `from` set to the zero address.
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
     * @dev Destoys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a `Transfer` event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 value) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    /**
     * @dev See `IERC20.transferFrom`.
     *
     * Emits an `Approval` event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of `ERC20`;
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `value`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function _transferFrom(address sender, address recipient, uint256 amount) internal whenNotPaused returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }


    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an `Approval` event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

}

contract Fessstable is ERC20 {

    using SafeMath for uint256;
    string  public  name;
    string  public  symbol;
    uint8   public constant decimals = 18;
    address public fesschainAddress;

    uint256 public feesAmount;
    address payable public feesWallet;
    uint256 public rate; 
    fesschain public token;
    uint256 public priceOfFesstoken;
    

    struct stakingDetails {

        uint256 value;
        uint256 timePeriod;
        uint256 startTime;

    }

    mapping(address => stakingDetails) public stakingEvent;
    mapping(address => bool) public stakingActive;
    
    constructor(address _owner, address payable _feesWallet, string memory _name, string memory _symbol, fesschain _fesschainAddress) public Owned(_owner) {

               name = _name;
               symbol = _symbol;
               token = _fesschainAddress;
               feesWallet = _feesWallet;
               feesAmount = 100000000000000000 wei;
               rate = 12;

    }

    /**
     * @dev See `IERC20.transfer`.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public whenNotPaused returns (bool) {

        super._transfer(msg.sender, recipient, amount);


        return true;
    }

    /**
     * @dev See `IERC20.transferFrom`.
     *
     * Emits an `Approval` event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of `ERC20`;
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `value`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public whenNotPaused returns (bool) {

        super._transferFrom(sender, recipient, amount);

        return true;
    }


    function setWalletAddress(address payable wallet) public whenNotPaused onlyOwner returns (bool) {

      feesWallet = wallet;

        return true;
    }

    function setbaseFees() public payable whenNotPaused onlyOwner returns (bool) {

      feesAmount = msg.value;
      feesWallet.transfer(msg.value);
        return true;
    }

    function setRateOfConversion(uint256 _rate) public whenNotPaused onlyOwner returns (bool) {

    require (rate>0);
      rate = _rate;

        return true;
    }

    function setPriceofToken(uint256 _price) public whenNotPaused onlyOwner returns (bool) {

      priceOfFesstoken = _price;

        return true;
    }


    function mint(address _userAddress, uint256 _value) public whenNotPaused onlyOwner returns (bool) {

    _mint(_userAddress,_value);

        return true;
    }

    
    function swapTokens(uint256 value) public whenNotPaused payable returns (bool) {

       require(token.balanceOf(msg.sender) >= value,'balance of a user is less then value');
       
       uint256 checkAllowance = token.allowance(msg.sender, address(this)); 

       require (checkAllowance >= value, 'allowance is wrong');
       require(token.transferFrom(msg.sender,address(this),value),'transfer From failed');
       require(rate > 0, 'rate is zero');
       require(feesWallet != address(0), 'fee wallet address not set');
       require(msg.value >= feesAmount, 'fee value is less then required');

       uint256 worthOfUSd = value.mul(priceOfFesstoken).div(100);
       uint256 totalvalueToSent = worthOfUSd.add(worthOfUSd.mul(rate).div(100));       

       require(mint(msg.sender,totalvalueToSent),'Minting failed');
       feesWallet.transfer(msg.value);
       
        return true;
    }    

    function staking(uint256 _value, uint256 _timePeriod) public whenNotPaused returns (bool) {

       require(token.balanceOf(msg.sender) >= _value,'balance of a user is less then value');

       uint256 checkAllowance = token.allowance(msg.sender, address(this)); 

       require (checkAllowance >= _value, 'allowance is wrong');
       require(token.transferFrom(msg.sender,address(this),_value),'transferFROM failed');

       require(stakingActive[msg.sender] == false);
       require(_timePeriod == 3 || _timePeriod == 6  || _timePeriod == 9  || _timePeriod == 12 , 'wrong time period');
       
     stakingEvent[msg.sender] = stakingDetails(
       {

         value : _value,
         timePeriod : _timePeriod,
         startTime : now


       });

     stakingActive[msg.sender] = true;

        return true;
    }    

    function withdrawStaking() public whenNotPaused returns (bool) {

        require(stakingActive[msg.sender] == true);
        stakingDetails memory stakingTemp = stakingEvent[msg.sender];

        uint256 oneMonthInSeconds = 2592000;
        uint256 stakingTineInseconds =  (stakingTemp.timePeriod).mul(2592000);
        require(now >= stakingTineInseconds);

        if(stakingTemp.timePeriod == 3){
        
        uint256 valueToTransfer = stakingTemp.value.mul(12).div(100);    
        require(token.transfer(msg.sender,stakingTemp.value) && mint(msg.sender,valueToTransfer));
        stakingActive[msg.sender] = false;
        return true;

        }else if (stakingTemp.timePeriod == 6) {

        uint256 valueToTransfer = stakingTemp.value.mul(24).div(100);    
        require(token.transfer(msg.sender,stakingTemp.value) && mint(msg.sender,valueToTransfer));
        stakingActive[msg.sender] = false;
        return true;
            
        }else if(stakingTemp.timePeriod == 9){

        uint256 valueToTransfer = stakingTemp.value.mul(36).div(100);    
        require(token.transfer(msg.sender,stakingTemp.value) && mint(msg.sender,valueToTransfer));
        stakingActive[msg.sender] = false;
        return true;

        }else if (stakingTemp.timePeriod == 12) {

        uint256 valueToTransfer = stakingTemp.value.mul(48).div(100);    
        require(token.transfer(msg.sender,stakingTemp.value) && mint(msg.sender,valueToTransfer));
        stakingActive[msg.sender] = false;
        return true;
        
        }

    }    


     /**
      * @dev distribution function to tokens. Best works upto 50 addresses in one time. Maximum limit is 200 addresses in one time.
      * @param _addresses array of address in serial order
      * @param _amount amount in serial order with respect to address array
      */
      function distributeTokens(address[] memory _addresses, uint256[] memory _amount) public  onlyOwner returns (bool){

          require(_addresses.length == _amount.length,"Invalid Array");
          uint256 count = _addresses.length;
          for (uint256 i = 0; i < count; i++){

                mint(_addresses[i],_amount[i]);
          }
          return true;
      }

    function () external payable {
    
       revert();

    }
    
 function transferAnyERC20Token(address tokenAddress, uint tokens) public whenNotPaused onlyOwner returns (bool success) {
        require(tokenAddress != address(0));
        return ERC20(tokenAddress).transfer(owner, tokens);
    }}
