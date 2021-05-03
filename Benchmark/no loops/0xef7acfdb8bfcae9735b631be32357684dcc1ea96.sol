/**
 *Submitted for verification at Etherscan.io on 2020-12-17
*/

// SPDX-License-Identifier: MIT
//pragma solidity 0.6.12;
pragma solidity >=0.5 <0.7.17;
library SafeMath {
  function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {
    if (x == 0) {
      return 0;
    }
    z = x * y;
    assert(z / x == y);
    return z;
  }
  function div(uint256 x, uint256 y) internal pure returns (uint256) {
    return x / y;
  }
  function sub(uint256 x, uint256 y) internal pure returns (uint256) {
    assert(y <= x);
    return x - y;
  }
  function add(uint256 x, uint256 y) internal pure returns (uint256 z) {
    z = x + y;
    assert(z >= x);
    return z;
  }
}
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract Ownable {
    address private _owner;
    constructor() public {
        setOwner(msg.sender);
    }
    function owner() external view returns (address) {
        return _owner;
    }
    function setOwner(address newOwner) internal {
        _owner = newOwner;
    }
    modifier onlyOwner() {
        require(msg.sender == _owner, "You are not the owner");
        _;
    }
}
contract Pausable is Ownable {
    event Pause();
    event Unpause();
    bool public paused = false;
    modifier whenNotPaused() {
        require(!paused, "Contract paused");
        _;
    }
    function pause() external onlyOwner {
        paused = true;
        emit Pause();
    }
    function unpause() external onlyOwner {
        paused = false;
        emit Unpause();
    }
}
contract Freezable is Ownable {
    mapping(address => bool) internal freezed;
    event Freezed(address indexed _account);
    event UnFreezed(address indexed _account);
    modifier notFreezed(address _account) {
        require( !freezed[_account], "Account is freezed" );
        _;
    }
    modifier alreadyFreezed(address _account) {
        require( freezed[_account], "Account is not freezed" );
        _;
    }
    function isFreezed(address _account) external view returns (bool) {
        return freezed[_account];
    }
    function freeze(address _account) external onlyOwner {
        freezed[_account] = true;
        emit Freezed(_account);
    }
    function unFreeze(address _account) external onlyOwner {
        require( freezed[_account], "Account is not freezed" );
        freezed[_account] = false;
        emit UnFreezed(_account);
    }
}
 contract BaseToken is IERC20 {
    function _approve( address owner, address spender, uint256 value ) internal ;
    function _transfer( address from, address to, uint256 value) internal ;
}
contract NARToken is  Ownable, Pausable, Freezable,BaseToken {
    using SafeMath for uint256;

    string public name;
    string public symbol;
    uint8 public decimals;
    bool internal initialized;

    mapping(address => uint256) internal balances;
    mapping(address => mapping(address => uint256)) internal allowed;
    uint256 internal totalSupply_ = 0;

    event Mint(address indexed to, uint256 amount);
    event Burn(address indexed burner, uint256 amount);

    function initialize( string memory tokenName, string memory tokenSymbol, uint8 tokenDecimals ) public {
        require(!initialized, "Contract is already initialized");

        name = tokenName;
        symbol = tokenSymbol;
        decimals = tokenDecimals;
        setOwner(msg.sender);
        initialized = true;
    }
    function mint(address _to, uint256 _amount) external whenNotPaused onlyOwner notFreezed(_to) returns (bool) {
        require(_to != address(0), "Mint to address can not be zero");
        require(_amount > 0, "Mint amount can not lower than 0");

        totalSupply_ = totalSupply_.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Mint(_to, _amount);
        emit Transfer(address(0), _to, _amount);
        return true;
    }
    function allowance(address owner, address spender) external  view returns (uint256){
        return allowed[owner][spender];
    }
    function totalSupply() external  view returns (uint256) {
        return totalSupply_;
    }
    function balanceOf(address account)  external   view returns (uint256){
        return balances[account];
    }
    function approve(address spender, uint256 value) external  whenNotPaused notFreezed(msg.sender)  notFreezed(spender) returns (bool){
        _approve(msg.sender, spender, value);
        return true;
    }
    function _approve( address owner, address spender,  uint256 value ) internal  {
        require(owner != address(0), "Approve from address can not be the zero");
        require(spender != address(0), "Approve to address can not be the zero");
        allowed[owner][spender] = value;
        emit Approval(owner, spender, value);
    }
    function transferFrom( address from, address to, uint256 value  ) external  whenNotPaused notFreezed(msg.sender) notFreezed(from) notFreezed(to) returns (bool){
        require( value <= allowed[from][msg.sender],  "Transfer amount exceeds allowance"  );
        _transfer(from, to, value);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(value);
        return true;
    }
    function transfer(address to, uint256 value) external  whenNotPaused notFreezed(msg.sender)  notFreezed(to) returns (bool){
        _transfer(msg.sender, to, value);
        return true;
    }
    function _transfer( address from, address to, uint256 value ) internal  {
        require(from != address(0), "Transfer from address can not be the zero");
        require(to != address(0), "Transfer to address can not be the zero");
        require(  value <= balances[from], "Transfer amount exceeds balance" );

        balances[from] = balances[from].sub(value);
        balances[to] = balances[to].add(value);
        emit Transfer(from, to, value);
    }
    function burn(uint256 _amount) external whenNotPaused onlyOwner notFreezed(msg.sender) {
        uint256 balance = balances[msg.sender];
        require(_amount > 0, "Burn amount can not lower than 0");
        require(balance >= _amount, "Burn amount exceeds balance");

        totalSupply_ = totalSupply_.sub(_amount);
        balances[msg.sender] = balance.sub(_amount);
        emit Burn(msg.sender, _amount);
        emit Transfer(msg.sender, address(0), _amount);
    }
    function burnFreezed(address account) external onlyOwner alreadyFreezed(account)  returns (bool){
        uint256 accountBalance = balances[account];
        require(accountBalance > 0, "Burn amount can not lower than 0");
        balances[account] = 0;
        totalSupply_ = totalSupply_.sub(accountBalance);
        emit Burn(account, accountBalance);
        emit Transfer(account, address(0), accountBalance);
    }
}
