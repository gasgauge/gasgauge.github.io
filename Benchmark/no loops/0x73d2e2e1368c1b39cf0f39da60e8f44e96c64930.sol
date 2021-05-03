/**
 *Submitted for verification at Etherscan.io on 2020-09-18
*/

/**
 *Submitted for verification at Etherscan.io on 2019-09-30
*/

pragma solidity >=0.5 <0.7.17;

library SafeMathMod {// Partial SafeMath Library

    function sub(uint256 a, uint256 b) internal pure returns (uint256 c) {
        require((c = a - b) < a);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        require((c = a + b) > a);
    }
    
    function mul(uint256 a, uint256 b) internal pure returns(uint c) {
    c = a * b;
    require(a == 0 || c / a == b);
  }
  
  function div(uint a, uint b) internal pure returns(uint c) {
    require(b > 0);
    c = a / b;
  }
}

contract ERC20Interface {
  function totalSupply() public view returns(uint);
  function balanceOf(address tokenOwner) public view returns(uint balance);
  function allowance(address tokenOwner, address spender) public view returns(uint remaining);
  function transfer(address to, uint tokens) public returns(bool success);
  function approve(address spender, uint tokens) public returns(bool success);
  function transferFrom(address from, address to, uint tokens) public returns(bool success);
  event Transfer(address indexed from, address indexed to, uint tokens);
  event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract ApproveAndCallFallBack {
  function receiveApproval(address from, uint256 tokens, address token, bytes memory data) public;
}

contract Owned {
  address public owner;
  event OwnershipTransferred(address indexed _from, address indexed _to);
  constructor() public {
    owner = msg.sender;
  }
  modifier onlyOwner {
    require(msg.sender == owner);
    _;
  }
  function transferOwnership(address newOwner) public onlyOwner {
    owner = newOwner;
    emit OwnershipTransferred(owner, newOwner);
  }
}
// blacklist
contract UserLock is Owned {
  mapping(address => bool) blacklist;
  event LockUser(address indexed who);
  event UnlockUser(address indexed who);
  modifier permissionCheck {
    require(!blacklist[msg.sender]);
    _;
  }
  function lockUser(address who) public onlyOwner {
    blacklist[who] = true;
    emit LockUser(who);
  }
  function unlockUser(address who) public onlyOwner {
    blacklist[who] = false;
    emit UnlockUser(who);
  }
}

contract Tokenlock is Owned {
  uint8 isLocked = 0;
  event Freezed();
  event UnFreezed();
  modifier validLock {
    require(isLocked == 0);
    _;
  }
  function freeze() public onlyOwner {
    isLocked = 1;
    emit Freezed();
  }
  function unfreeze() public onlyOwner {
    isLocked = 0;
    emit UnFreezed();
  }
}

contract GTR is ERC20Interface, Tokenlock, UserLock{//is inherently ERC20
    using SafeMathMod for uint256;

    /**
    * @constant name The name of the token
    * @constant symbol  The symbol used to display the currency
    * @constant decimals  The number of decimals used to dispay a balance
    * @constant totalSupply The total number of tokens times 10^ of the number of decimals
    * @constant MAX_UINT256 Magic number for unlimited allowance
    * @storage balanceOf Holds the balances of all token holders
    * @storage allowed Holds the allowable balance to be transferable by another address.
    */

    string constant public name = "GTR";

    string constant public symbol = "GTR";

    uint8 constant public decimals = 6;

    uint256  _totalSupply = 15e11; // 1500W

    uint256 constant private MAX_UINT256 = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    mapping (address => uint256) public balances;
    
    mapping (address => mapping (address => uint256)) public allowed;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event TransferFrom(address indexed _spender, address indexed _from, address indexed _to, uint256 _value);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    constructor() public {
        balances[owner] = _totalSupply;
        emit Transfer(address(0), owner, _totalSupply);
    }
    
    function totalSupply() public view returns(uint) {
        return _totalSupply;
    }
    
    function balanceOf(address tokenOwner) public view returns(uint balance) {
        return balances[tokenOwner];
    }
    
    /**
    * @notice send `_value` token to `_to` from `msg.sender`
    *
    * @param _to The address of the recipient
    * @param _value The amount of token to be transferred
    * @return Whether the transfer was successful or not
    */
    function transfer(address _to, uint256 _value) public validLock permissionCheck returns (bool success) {
        /* Ensures that tokens are not sent to address "0x0" */
        require(_to != address(0));
        /* Prevents sending tokens directly to contracts. */
        require(isNotContract(_to));

        /* SafeMathMOd.sub will throw if there is not enough balance and if the transfer value is 0. */
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
    * @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    *
    * @param _from The address of the sender
    * @param _to The address of the recipient
    * @param _value The amount of token to be transferred
    * @return Whether the transfer was successful or not
    */
    function transferFrom(address _from, address _to, uint256 _value) public validLock permissionCheck returns (bool success) {
        /* Ensures that tokens are not sent to address "0x0" */
        require(_to != address(0));
        /* Ensures tokens are not sent to this contract */
        require(_to != address(this));
        
        uint256 allowance = allowed[_from][msg.sender];
        /* Ensures sender has enough available allowance OR sender is balance holder allowing single transsaction send to contracts*/
        require(_value <= allowance || _from == msg.sender);

        /* Use SafeMathMod to add and subtract from the _to and _from addresses respectively. Prevents under/overflow and 0 transfers */
        balances[_to] = balances[_to].add(_value);
        balances[_from] = balances[_from].sub(_value);

        /* Only reduce allowance if not MAX_UINT256 in order to save gas on unlimited allowance */
        /* Balance holder does not need allowance to send from self. */
        if (allowed[_from][msg.sender] != MAX_UINT256 && _from != msg.sender) {
            allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        }
        emit Transfer(_from, _to, _value);
        return true;
    }

    /**
    * @notice `msg.sender` approves `_spender` to spend `_value` tokens
    *
    * @param _spender The address of the account able to transfer the tokens
    * @param _value The amount of tokens to be approved for transfer
    * @return Whether the approval was successful or not
    */
    function approve(address _spender, uint256 _value) public validLock permissionCheck returns (bool success) {
        /* Ensures address "0x0" is not assigned allowance. */
        require(_spender != address(0));

        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
    * @param _owner The address of the account owning tokens
    * @param _spender The address of the account able to transfer the tokens
    * @return Amount of remaining tokens allowed to spent
    */
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        remaining = allowed[_owner][_spender];
    }
    
    // trust pay
    function approveAndCall(address spender, uint tokens, bytes memory data) public validLock permissionCheck returns(bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, address(this), data);
        return true;
    }
    
    function mintToken(address target, uint256 mintedAmount) public onlyOwner {
        require(target != address(0));
        balances[target] += mintedAmount;
        _totalSupply = _totalSupply.add(mintedAmount);
        emit Transfer(address(0), owner, mintedAmount);
        emit Transfer(owner, target, mintedAmount);
    }
    
    function () external payable {
        revert();
    }

    function isNotContract(address _addr) private view returns (bool) {
        uint length;
        assembly {
        /* retrieve the size of the code on target address, this needs assembly */
        length := extcodesize(_addr)
        }
        return (length == 0);
    }

}