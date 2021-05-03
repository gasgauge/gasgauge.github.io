/**

 *Submitted for verification at Etherscan.io on 2020-12-19

*/



/**

 *  Hybrid Bank Stable Coin HBUSD

*/



//pragma solidity 0.5.17;
pragma solidity >=0.5 <0.7.17;



library SafeMath {



    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;

        require(c >= a, "SafeMath: addition overflow");



        return c;

    }



    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

	    return sub(a, b, "SafeMath: subtraction overflow");

    }



    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

	    require(b <= a, errorMessage);

	    uint256 c = a - b;



	    return c;

    }

}



contract Ownable {



    address private _owner;



    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);



    constructor () internal {

        _owner = msg.sender;

        emit OwnershipTransferred(address(0), _owner);

    }



    function owner() public view returns (address) {

        return _owner;

    }



    modifier onlyOwner() {

        require(msg.sender == _owner, "Caller is not owner");

        _;

    }



    function transferOwnership(address newOwner) public onlyOwner {

        require(newOwner != address(0), "new owner is the zero address");

        emit OwnershipTransferred(_owner, newOwner);

        _owner = newOwner;

    }

}



library Roles {



    struct Role {

        mapping (address => bool) bearer;

    }



    function add(Role storage role, address account) internal {

        require(!has(role, account), "Roles: account already has role");

        role.bearer[account] = true;

    }



    function remove(Role storage role, address account) internal {

        require(has(role, account), "Roles: account does not have role");

        role.bearer[account] = false;

    }



    function has(Role storage role, address account) internal view returns (bool) {

        require(account != address(0), "Roles: account is the zero address");

        return role.bearer[account];

    }

}



contract PauserRole is Ownable {



    using Roles for Roles.Role;



    event PauserAdded(address indexed account);



    event PauserRemoved(address indexed account);



    Roles.Role private _pausers;



    constructor () internal {

        _addPauser(msg.sender);

    }



    modifier onlyPauser() {

        require(isPauser(msg.sender), "caller does not have the Pauser role");

        _;

    }



    function isPauser(address account) public view returns (bool) {

        return _pausers.has(account);

    }



    function addPauser(address account) public onlyOwner {

        _addPauser(account);

    }



    function removePauser(address account) public onlyOwner {

        _removePauser(account);

    }



    function renouncePauser() public {

        _removePauser(msg.sender);

    }



    function _addPauser(address account) internal {

        _pausers.add(account);

        emit PauserAdded(account);

    }



    function _removePauser(address account) internal {

        _pausers.remove(account);

        emit PauserRemoved(account);

    }

}



contract Pausable is PauserRole {



    event Paused(address account);



    event Unpaused(address account);



    bool private _paused;



    constructor () internal {

        _paused = false;

    }



    function paused() public view returns (bool) {

        return _paused;

    }



    modifier whenNotPaused() {

        require(!_paused, "Pausable: paused");

        _;

    }



    modifier whenPaused() {

        require(_paused, "Pausable: not paused");

        _;

    }



    function pause() public onlyPauser whenNotPaused {

        _paused = true;

        emit Paused(msg.sender);

    }



    function unpause() public onlyPauser whenPaused {

        _paused = false;

        emit Unpaused(msg.sender);

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



contract ERC20 is IERC20, Ownable {



    using SafeMath for uint256;



    mapping (address => uint256) private _balances;



    mapping (address => mapping (address => uint256)) private _allowances;



    uint256 private _totalSupply;



    event Issue(address indexed account, uint256 amount);



    event Redeem(address indexed account, uint256 value);



    function totalSupply() public view returns (uint256) {

        return _totalSupply;

    }



    function balanceOf(address account) public view returns (uint256) {

        return _balances[account];

    }



    function transfer(address recipient, uint256 amount) public returns (bool) {

        _transfer(msg.sender, recipient, amount);

        return true;

    }



    function allowance(address owner, address spender) public view returns (uint256) {

        return _allowances[owner][spender];

    }



    function approve(address spender, uint256 value) public returns (bool) {

        _approve(msg.sender, spender, value);

        return true;

    }



    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {

        _transfer(sender, recipient, amount);

        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));

        return true;

    }



    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));

        return true;

    }



    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));

        return true;

    }



    function _transfer(address sender, address recipient, uint256 amount) internal {

        require(sender != address(0), "ERC20: transfer from the zero address");

        require(recipient != address(0), "ERC20: transfer to the zero address");



        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");

        _balances[recipient] = _balances[recipient].add(amount);

        emit Transfer(sender, recipient, amount);

    }



    function _approve(address owner, address spender, uint256 value) internal {

        require(owner != address(0), "ERC20: approve from the zero address");

        require(spender != address(0), "ERC20: approve to the zero address");



        _allowances[owner][spender] = value;

        emit Approval(owner, spender, value);

    }



    function _issue(address account, uint256 amount) internal {

        require(account != address(0), "CoinFactory: issue to the zero address");



        _totalSupply = _totalSupply.add(amount);

        _balances[account] = _balances[account].add(amount);

        emit Transfer(address(0), account, amount);

        emit Issue(account, amount);

    }



    function _redeem(address account, uint256 value) internal {

        require(account != address(0), "CoinFactory: redeem from the zero address");



        _balances[account] = _balances[account].sub(value, "ERC20: burn amount exceeds balance");

        _totalSupply = _totalSupply.sub(value);

        emit Transfer(account, address(0), value);

        emit Redeem(account, value);

    }

}



contract ERC20Pausable is ERC20, Pausable {



    function transfer(address to, uint256 value) public whenNotPaused returns (bool) {

        return super.transfer(to, value);

    }



    function transferFrom(address from, address to, uint256 value) public whenNotPaused returns (bool) {

        return super.transferFrom(from, to, value);

    }



    function approve(address spender, uint256 value) public whenNotPaused returns (bool) {

        return super.approve(spender, value);

    }



    function increaseAllowance(address spender, uint addedValue) public whenNotPaused returns (bool) {

        return super.increaseAllowance(spender, addedValue);

    }



    function decreaseAllowance(address spender, uint subtractedValue) public whenNotPaused returns (bool) {

        return super.decreaseAllowance(spender, subtractedValue);

    }

}



contract CoinFactoryAdminRole is Ownable {



    using Roles for Roles.Role;



    event CoinFactoryAdminRoleAdded(address indexed account);



    event CoinFactoryAdminRoleRemoved(address indexed account);



    Roles.Role private _coinFactoryAdmins;



    constructor () internal {

        _addCoinFactoryAdmin(msg.sender);

    }



    modifier onlyCoinFactoryAdmin() {

        require(isCoinFactoryAdmin(msg.sender), "CoinFactoryAdminRole: caller does not have the CoinFactoryAdmin role");

        _;

    }



    function isCoinFactoryAdmin(address account) public view returns (bool) {

        return _coinFactoryAdmins.has(account);

    }



    function addCoinFactoryAdmin(address account) public onlyOwner {

        _addCoinFactoryAdmin(account);

    }



    function removeCoinFactoryAdmin(address account) public onlyOwner {

        _removeCoinFactoryAdmin(account);

    }



    function renounceCoinFactoryAdmin() public {

        _removeCoinFactoryAdmin(msg.sender);

    }



    function _addCoinFactoryAdmin(address account) internal {

        _coinFactoryAdmins.add(account);

        emit CoinFactoryAdminRoleAdded(account);

    }



    function _removeCoinFactoryAdmin(address account) internal {

        _coinFactoryAdmins.remove(account);

        emit CoinFactoryAdminRoleRemoved(account);

    }

}



contract CoinFactory is ERC20, CoinFactoryAdminRole {



    function issue(address account, uint256 amount) public onlyCoinFactoryAdmin returns (bool) {

        _issue(account, amount);

        return true;

    }



    function redeem(address account, uint256 amount) public onlyCoinFactoryAdmin returns (bool) {

        _redeem(account, amount);

        return true;

    }

}



contract BlacklistAdminRole is Ownable {



    using Roles for Roles.Role;



    event BlacklistAdminAdded(address indexed account);

    event BlacklistAdminRemoved(address indexed account);



    Roles.Role private _blacklistAdmins;



    constructor () internal {

        _addBlacklistAdmin(msg.sender);

    }



    modifier onlyBlacklistAdmin() {

        require(isBlacklistAdmin(msg.sender), "BlacklistAdminRole: caller does not have the BlacklistAdmin role");

        _;

    }



    function isBlacklistAdmin(address account) public view returns (bool) {

        return _blacklistAdmins.has(account);

    }



    function addBlacklistAdmin(address account) public onlyOwner {

        _addBlacklistAdmin(account);

    }



    function removeBlacklistAdmin(address account) public onlyOwner {

        _removeBlacklistAdmin(account);

    }



    function renounceBlacklistAdmin() public {

        _removeBlacklistAdmin(msg.sender);

    }



    function _addBlacklistAdmin(address account) internal {

        _blacklistAdmins.add(account);

        emit BlacklistAdminAdded(account);

    }



    function _removeBlacklistAdmin(address account) internal {

        _blacklistAdmins.remove(account);

        emit BlacklistAdminRemoved(account);

    }

}



contract Blacklisted is ERC20, BlacklistAdminRole {



    mapping (address => bool) public _blacklisted;



    event BlacklistAdded(address indexed account);



    event BlacklistRemoved(address indexed account);



    function isBlacklisted(address account) public view returns (bool) {

        return _blacklisted[account];

    }



    function _addBlacklist(address account) internal {

        _blacklisted[account] = true;

        emit BlacklistAdded(account);

    }



    function _removeBlacklist(address account) internal {

        _blacklisted[account] = false;

        emit BlacklistRemoved(account);

    }

}



contract HBUSDToken is ERC20, ERC20Pausable, CoinFactory, Blacklisted {



    string public name;

    string public symbol;

    uint256 public decimals;

    uint256 private _totalSupply;



    constructor (string memory _name, string memory _symbol, uint8 _decimals) public {

        _totalSupply = 0;

        name = _name;

        symbol = _symbol;

        decimals = _decimals;

    }



    function transfer(address to, uint256 value) public whenNotPaused returns (bool) {

        require(!isBlacklisted(msg.sender), "caller in blacklist, no permission to transfer");

        require(!isBlacklisted(to), "transfer to blacklist address not permitted");

        return super.transfer(to, value);

    }



    function transferFrom(address from, address to, uint256 value) public whenNotPaused returns (bool) {

        require(!isBlacklisted(msg.sender), "caller in blacklist, no permission to transferFrom");

        require(!isBlacklisted(from), "from address in blacklist");

        require(!isBlacklisted(to), "recipient address in blacklist");

        return super.transferFrom(from, to, value);

    }

}
