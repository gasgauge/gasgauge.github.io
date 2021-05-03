/**
 *Submitted for verification at Etherscan.io on 2020-08-30
*/

// File: solidity-common/contracts/interface/IERC20.sol

//pragma solidity >=0.5.0 <0.7.0;
pragma solidity >=0.5 <0.7.17;


/**
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
 */
interface IERC20 {
    /**
    * 可选方法
    */
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);

    /**
     * 必须方法
     */
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * 事件类型
     */
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: solidity-common/contracts/library/SafeMath.sol

//pragma solidity >=0.5.0 <0.7.0;
pragma solidity >=0.5 <0.7.17;


/**
 * 算术操作
 */
library SafeMath {
    uint256 constant WAD = 10 ** 18;
    uint256 constant RAY = 10 ** 27;

    function wad() public pure returns (uint256) {
        return WAD;
    }

    function ray() public pure returns (uint256) {
        return RAY;
    }

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

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a <= b ? a : b;
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function sqrt(uint256 a) internal pure returns (uint256 b) {
        if (a > 3) {
            b = a;
            uint256 x = a / 2 + 1;
            while (x < b) {
                b = x;
                x = (a / x + x) / 2;
            }
        } else if (a != 0) {
            b = 1;
        }
    }

    function wmul(uint256 a, uint256 b) internal pure returns (uint256) {
        return mul(a, b) / WAD;
    }

    function wmulRound(uint256 a, uint256 b) internal pure returns (uint256) {
        return add(mul(a, b), WAD / 2) / WAD;
    }

    function rmul(uint256 a, uint256 b) internal pure returns (uint256) {
        return mul(a, b) / RAY;
    }

    function rmulRound(uint256 a, uint256 b) internal pure returns (uint256) {
        return add(mul(a, b), RAY / 2) / RAY;
    }

    function wdiv(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(mul(a, WAD), b);
    }

    function wdivRound(uint256 a, uint256 b) internal pure returns (uint256) {
        return add(mul(a, WAD), b / 2) / b;
    }

    function rdiv(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(mul(a, RAY), b);
    }

    function rdivRound(uint256 a, uint256 b) internal pure returns (uint256) {
        return add(mul(a, RAY), b / 2) / b;
    }

    function wpow(uint256 x, uint256 n) internal pure returns (uint256) {
        uint256 result = WAD;
        while (n > 0) {
            if (n % 2 != 0) {
                result = wmul(result, x);
            }
            x = wmul(x, x);
            n /= 2;
        }
        return result;
    }

    function rpow(uint256 x, uint256 n) internal pure returns (uint256) {
        uint256 result = RAY;
        while (n > 0) {
            if (n % 2 != 0) {
                result = rmul(result, x);
            }
            x = rmul(x, x);
            n /= 2;
        }
        return result;
    }
}

// File: solidity-common/contracts/library/Array.sol

//pragma solidity >=0.5.0 <0.7.0;
pragma solidity >=0.5 <0.7.17;


/**
 * 数组工具包
 */
library Array {
    // 从字节数组array中删除指定的bytes32
    function remove(bytes32[] storage array, bytes32 element) internal returns (bool) {
        for (uint256 index = 0; index < array.length; index++) {
            if (array[index] == element) {
                delete array[index];
                array[index] = array[array.length - 1];
                array.length--;
                return true;
            }
        }
        return false;
    }

    // 从地址数组array中删除指定的address
    function remove(address[] storage array, address element) internal returns (bool) {
        for (uint256 index = 0; index < array.length; index++) {
            if (array[index] == element) {
                delete array[index];
                array[index] = array[array.length - 1];
                array.length--;
                return true;
            }
        }
        return false;
    }
}

// File: solidity-common/contracts/library/Roles.sol

//pragma solidity >=0.5.0 <0.7.0;
pragma solidity >=0.5 <0.7.17;


/**
 * 多角色管理逻辑
 */
library Roles {
    // 存储角色授权数据
    struct Role {
        mapping(address => bool) bearer;
    }

    // 增加一个不存在的地址
    function add(Role storage role, address account) internal {
        require(account != address(0), "Roles: account is the zero address");
        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    // 删除一个存在的地址
    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    // 判断地址是否有权限
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}

// File: solidity-common/contracts/common/Ownable.sol

//pragma solidity >=0.5.0 <0.7.0;
pragma solidity >=0.5 <0.7.17;


/**
 * 合约Owner机制
 */
contract Ownable {
    address private _owner;

    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function isOwner(address account) public view returns (bool) {
        return account == _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }


    modifier onlyOwner() {
        require(isOwner(msg.sender), "Ownable: caller is not the owner");
        _;
    }


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
}

// File: solidity-common/contracts/access/BlacklistedRole.sol

//pragma solidity >=0.5.0 <0.7.0;
pragma solidity >=0.5 <0.7.17;





/**
 *  由owner控制，具备黑名单的合约
 */
contract BlacklistedRole is Ownable {
    using Roles for Roles.Role;
    using Array for address[];

    Roles.Role private _blacklisteds;
    address[] public blacklisteds;

    constructor () internal {}

    function _addBlacklisted(address account) internal {
        _blacklisteds.add(account);
        blacklisteds.push(account);
        emit BlacklistedAdded(account);
    }

    function addBlacklisted(address account) public onlyOwner {
        _addBlacklisted(account);
    }

    function addBlacklisted(address[] memory accounts) public onlyOwner {
        for (uint256 index = 0; index < accounts.length; index++) {
            _addBlacklisted(accounts[index]);
        }
    }

    function _delBlacklisted(address account) internal {
        _blacklisteds.remove(account);

        if (blacklisteds.remove(account)) {
            emit BlacklistedRemoved(account);
        }
    }

    function delBlacklisted(address account) public onlyOwner {
        _delBlacklisted(account);
    }

    function getBlacklistedsLength() public view returns (uint256) {
        return blacklisteds.length;
    }

    function isBlacklisted(address account) public view returns (bool) {
        return _blacklisteds.has(account);
    }


    modifier onlyBlacklisted() {
        require(isBlacklisted(msg.sender), "BlacklistedRole: caller does not have the blacklisted role");
        _;
    }

    modifier onlyNotBlacklisted(address account) {
        require(!isBlacklisted(account), "BlacklistedRole: account has the blacklisted role");
        _;
    }


    event BlacklistedAdded(address indexed account);
    event BlacklistedRemoved(address indexed account);
}

// File: solidity-common/contracts/common/DailyLimit.sol

//pragma solidity >=0.5.0 <0.7.0;
pragma solidity >=0.5 <0.7.17;




/**
 * 代币每日转账额度控制机制
 */
contract DailyLimit is Ownable {
    using SafeMath for uint256;

    mapping(address => UserDailyLimit) public dailyLimits;      // 用户额度信息

    struct UserDailyLimit {
        uint256 spent;                                          // 今日已用额度
        uint256 today;                                          // 今日开始时间
        uint256 limit;                                          // 今日总共额度
    }

    constructor () internal {}

    /**
     * 查询用户每日额度信息
     */
    function getDailyLimit(address account) public view returns (uint256, uint256, uint256){
        UserDailyLimit memory dailyLimit = dailyLimits[account];
        return (dailyLimit.spent, dailyLimit.today, dailyLimit.limit);
    }

    /**
     * 设置用户每日总共额度
     */
    function _setDailyLimit(address account, uint256 limit) internal {
        require(account != address(0), "DailyLimit: account is the zero address");
        require(limit != 0, "DailyLimit: limit can not be zero");

        dailyLimits[account].limit = limit;
    }

    function setDailyLimit(address[] memory accounts, uint256[] memory limits) public onlyOwner {
        require(accounts.length == limits.length, "DailyLimit: accounts and limits length mismatched");

        for (uint256 index = 0; index < accounts.length; index++) {
            _setDailyLimit(accounts[index], limits[index]);
        }
    }

    /**
     * 今日开始时间
     */
    function today() public view returns (uint256){
        return now - (now % 1 days);
    }

    /**
     * 是否小于限制
     */
    function isUnderLimit(address account, uint256 amount) internal returns (bool){
        UserDailyLimit storage dailyLimit = dailyLimits[account];

        if (today() > dailyLimit.today) {
            dailyLimit.today = today();
            dailyLimit.spent = 0;
        }

        // A).limit为0，不用做限制 B).limit非0，需满足限制
        return (dailyLimit.limit == 0 || dailyLimit.spent.add(amount) <= dailyLimit.limit);
    }


    modifier onlyUnderLimit(address account, uint256 amount){
        require(isUnderLimit(account, amount), "DailyLimit: user's spent exceeds daily limit");
        _;
    }
}

// File: solidity-common/contracts/access/PauserRole.sol

//pragma solidity >=0.5.0 <0.7.0;
pragma solidity >=0.5 <0.7.17;





/**
 * 由owner控制，具备可暂停的合约
 */
contract PauserRole is Ownable {
    using Roles for Roles.Role;
    using Array for address[];

    Roles.Role private _pausers;
    address[] public pausers;

    constructor () internal {}

    function _addPauser(address account) internal {
        _pausers.add(account);
        pausers.push(account);
        emit PauserAdded(account);
    }

    function addPauser(address account) public onlyOwner {
        _addPauser(account);
    }

    function addPauser(address[] memory accounts) public onlyOwner {
        for (uint256 index = 0; index < accounts.length; index++) {
            _addPauser(accounts[index]);
        }
    }

    function _delPauser(address account) internal {
        _pausers.remove(account);

        if (pausers.remove(account)) {
            emit PauserRemoved(account);
        }
    }

    function renouncePauser() public {
        _delPauser(msg.sender);
    }

    function delPauser(address account) public onlyOwner {
        _delPauser(account);
    }

    function getPausersLength() public view returns (uint256) {
        return pausers.length;
    }

    function isPauser(address account) public view returns (bool) {
        return _pausers.has(account);
    }


    modifier onlyPauser() {
        require(isPauser(msg.sender), "PauserRole: caller does not have the pauser role");
        _;
    }


    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);
}

// File: solidity-common/contracts/common/Pausable.sol

//pragma solidity >=0.5.0 <0.7.0;
pragma solidity >=0.5 <0.7.17;



/**
 * 紧急暂停机制
 */
contract Pausable is PauserRole {
    bool private _paused;               // 系统暂停标识

    constructor () internal {
        _paused = false;
    }

    // 暂停标识 true-禁用, false-启用
    function paused() public view returns (bool) {
        return _paused;
    }

    // 授权的访客在系统启用时，变更系统为禁用
    function pause() public onlyPauser whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    // 授权的访客在系统禁用时，变更系统为启用
    function unpause() public onlyPauser whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }


    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }


    event Paused(address indexed pauser);
    event Unpaused(address indexed pauser);
}

// File: solidity-common/contracts/erc20/ERC20.sol

//pragma solidity >=0.5.0 <0.7.0;
pragma solidity >=0.5 <0.7.17;







/**
 * ERC20全实现合约
 */
contract ERC20 is IERC20, BlacklistedRole, DailyLimit, Pausable {
    using SafeMath for uint256;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;

    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);

        emit Transfer(sender, recipient, amount);
    }

    function transfer(address recipient, uint256 amount) public whenNotPaused onlyNotBlacklisted(msg.sender) onlyNotBlacklisted(recipient) onlyUnderLimit(msg.sender, amount) returns (bool) {
        dailyLimits[msg.sender].spent = dailyLimits[msg.sender].spent.add(amount);
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public whenNotPaused onlyNotBlacklisted(msg.sender) onlyNotBlacklisted(sender) onlyNotBlacklisted(recipient) onlyUnderLimit(sender, amount) returns (bool) {
        uint256 delta = _allowances[sender][msg.sender].sub(amount, "ERC20: decreased allowance below zero");
        dailyLimits[sender].spent = dailyLimits[sender].spent.add(amount);
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, delta);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function increaseAllowance(address spender, uint256 addedValue) public whenNotPaused onlyNotBlacklisted(msg.sender) onlyNotBlacklisted(spender) returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public whenNotPaused onlyNotBlacklisted(msg.sender) onlyNotBlacklisted(spender) returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function approve(address spender, uint256 amount) whenNotPaused onlyNotBlacklisted(msg.sender) onlyNotBlacklisted(spender) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _burnFrom(address account, uint256 amount) internal {
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount, "ERC20: burn amount exceeds allowance"));
        _burn(account, amount);
    }
}

// File: solidity-common/contracts/access/WhitelistedRole.sol

//pragma solidity >=0.5.0 <0.7.0;
pragma solidity >=0.5 <0.7.17;





/**
 *  由owner控制，具备白名单的合约
 */
contract WhitelistedRole is Ownable {
    using Roles for Roles.Role;
    using Array for address[];

    Roles.Role private _whitelisteds;
    address[] public whitelisteds;

    constructor () internal {}

    function _addWhitelisted(address account) internal {
        _whitelisteds.add(account);
        whitelisteds.push(account);
        emit WhitelistedAdded(account);
    }

    function addWhitelisted(address account) public onlyOwner {
        _addWhitelisted(account);
    }

    function addWhitelisted(address[] memory accounts) public onlyOwner {
        for (uint256 index = 0; index < accounts.length; index++) {
            _addWhitelisted(accounts[index]);
        }
    }

    function _delWhitelisted(address account) internal {
        _whitelisteds.remove(account);

        if (whitelisteds.remove(account)) {
            emit WhitelistedRemoved(account);
        }
    }

    function renounceWhitelisted() public {
        _delWhitelisted(msg.sender);
    }

    function delWhitelisted(address account) public onlyOwner {
        _delWhitelisted(account);
    }

    function getWhitelistedsLength() public view returns (uint256) {
        return whitelisteds.length;
    }

    function isWhitelisted(address account) public view returns (bool) {
        return _whitelisteds.has(account);
    }


    modifier onlyWhitelisted() {
        require(isWhitelisted(msg.sender), "WhitelistedRole: caller does not have the whitelisted role");
        _;
    }

    modifier onlyWhitelisting(address account) {
        require(isWhitelisted(account), "WhitelistedRole: caller does not have the whitelisted role");
        _;
    }


    event WhitelistedAdded(address indexed account);
    event WhitelistedRemoved(address indexed account);
}

// File: solidity-common/contracts/access/MinterRole.sol

//pragma solidity >=0.5.0 <0.7.0;
pragma solidity >=0.5 <0.7.17;





/**
 *  由owner控制，具备动态矿工的合约
 */
contract MinterRole is Ownable {
    using Roles for Roles.Role;
    using Array for address[];

    Roles.Role private _minters;
    address[] public minters;

    constructor () internal {}

    function _addMinter(address account) internal {
        _minters.add(account);
        minters.push(account);
        emit MinterAdded(account);
    }

    function addMinter(address account) public onlyOwner {
        _addMinter(account);
    }

    function addMinter(address[] memory accounts) public onlyOwner {
        for (uint256 index = 0; index < accounts.length; index++) {
            _addMinter(accounts[index]);
        }
    }

    function _delMinter(address account) internal {
        _minters.remove(account);

        if (minters.remove(account)) {
            emit MinterRemoved(account);
        }
    }

    function renounceMinter() public {
        _delMinter(msg.sender);
    }

    function delMinter(address account) public onlyOwner {
        _delMinter(account);
    }

    function getMintersLength() public view returns (uint256) {
        return minters.length;
    }

    function isMinter(address account) public view returns (bool) {
        return _minters.has(account);
    }


    modifier onlyMinter() {
        require(isMinter(msg.sender), "MinterRole: caller does not have the Minter role");
        _;
    }


    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);
}

// File: contracts/interface/IBtswapFactory.sol

//pragma solidity >=0.5.0 <0.7.0;
pragma solidity >=0.5 <0.7.17;


interface IBtswapFactory {
    function FEE_RATE_DENOMINATOR() external view returns (uint256);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function feeRateNumerator() external view returns (uint256);

    function initCodeHash() external view returns (bytes32);

    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setRouter(address) external;

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;

    function setFeeRateNumerator(uint256) external;

    function setInitCodeHash(bytes32) external;

    function sortTokens(address tokenA, address tokenB) external pure returns (address token0, address token1);

    function pairFor(address factory, address tokenA, address tokenB) external view returns (address pair);

    function getReserves(address factory, address tokenA, address tokenB) external view returns (uint256 reserveA, uint256 reserveB);

    function quote(uint256 amountA, uint256 reserveA, uint256 reserveB) external pure returns (uint256 amountB);

    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) external view returns (uint256 amountOut);

    function getAmountIn(uint256 amountOut, uint256 reserveIn, uint256 reserveOut) external view returns (uint256 amountIn);

    function getAmountsOut(address factory, uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);

    function getAmountsIn(address factory, uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);


    event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

}

// File: contracts/interface/IBtswapPairToken.sol

//pragma solidity >=0.5.0 <0.7.0;
pragma solidity >=0.5 <0.7.17;


interface IBtswapPairToken {
    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function router() external view returns (address);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to) external returns (uint256 amount0, uint256 amount1);

    function swap(uint256 amount0Out, uint256 amount1Out, address to, bytes calldata data) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address, address) external;

    function price(address token) external view returns (uint256);


    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
    event Swap(address indexed sender, uint256 amount0In, uint256 amount1In, uint256 amount0Out, uint256 amount1Out, address indexed to);
    event Sync(uint112 reserve0, uint112 reserve1);

}

// File: contracts/interface/IBtswapRouter02.sol

//pragma solidity >=0.5.0 <0.7.0;
pragma solidity >=0.5 <0.7.17;


interface IBtswapRouter02 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function BT() external pure returns (address);

    function addLiquidity(address tokenA, address tokenB, uint256 amountADesired, uint256 amountBDesired, uint256 amountAMin, uint256 amountBMin, address to, uint256 deadline) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);

    function addLiquidityETH(address token, uint256 amountTokenDesired, uint256 amountTokenMin, uint256 amountETHMin, address to, uint256 deadline) external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);

    function removeLiquidity(address tokenA, address tokenB, uint256 liquidity, uint256 amountAMin, uint256 amountBMin, address to, uint256 deadline) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(address token, uint256 liquidity, uint256 amountTokenMin, uint256 amountETHMin, address to, uint256 deadline) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(address tokenA, address tokenB, uint256 liquidity, uint256 amountAMin, uint256 amountBMin, address to, uint256 deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(address token, uint256 liquidity, uint256 amountTokenMin, uint256 amountETHMin, address to, uint256 deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(uint256 amountOut, uint256 amountInMax, address[] calldata path, address to, uint256 deadline) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(uint256 amountOut, uint256 amountInMax, address[] calldata path, address to, uint256 deadline) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(uint256 amountOut, address[] calldata path, address to, uint256 deadline) external payable returns (uint256[] memory amounts);

    function quote(uint256 amountA, uint256 reserveA, uint256 reserveB) external view returns (uint256 amountB);

    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) external view returns (uint256 amountOut);

    function getAmountIn(uint256 amountOut, uint256 reserveIn, uint256 reserveOut) external view returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);

    function removeLiquidityETHSupportingFeeOnTransferTokens(address token, uint256 liquidity, uint256 amountTokenMin, uint256 amountETHMin, address to, uint256 deadline) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(address token, uint256 liquidity, uint256 amountTokenMin, uint256 amountETHMin, address to, uint256 deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external;

    function weth(address token) external view returns (uint256);

    function onTransfer(address sender, address recipient) external returns (bool);

}

// File: contracts/interface/IBtswapToken.sol

//pragma solidity >=0.5.0 <0.7.0;
pragma solidity >=0.5 <0.7.17;


interface IBtswapToken {
    function swap(address account, address input, uint256 amount, address output) external returns (bool);

    function liquidity(address account, address pair) external returns (bool);

}

// File: contracts/interface/IBtswapWhitelistedRole.sol

//pragma solidity >=0.5.0 <0.7.0;
pragma solidity >=0.5 <0.7.17;


interface IBtswapWhitelistedRole {
    function getWhitelistedsLength() external view returns (uint256);

    function isWhitelisted(address) external view returns (bool);

    function whitelisteds(uint256) external view returns (address);

}

// File: contracts/biz/BtswapToken.sol

//pragma solidity >=0.5.0 <0.7.0;
pragma solidity >=0.5 <0.7.17;










contract BtswapToken is IBtswapToken, WhitelistedRole, MinterRole, ERC20 {
    uint256 public constant MINT_DECAY_DURATION = 8409600;
    uint256 public INITIAL_BLOCK_REWARD = SafeMath.wad().mul(56);
    uint256 public PERCENTAGE_FOR_TAKER = SafeMath.wad().mul(60).div(100);
    uint256 public PERCENTAGE_FOR_MAKER = SafeMath.wad().mul(30).div(100);
    address public constant TAKER_ADDRESS = 0x0000000000000000000000000000000000000001;
    address public constant MAKER_ADDRESS = 0x0000000000000000000000000000000000000002;
    address public constant GROUP_ADDRESS = 0x0000000000000000000000000000000000000003;

    IBtswapRouter02 private _router;

    uint256 private _initMintBlock;
    uint256 private _lastMintBlock;
    mapping(address => uint256) private _weights;

    Pool public taker;
    Pool public maker;

    struct Pool {
        uint256 timestamp;
        uint256 quantity;
        uint256 deposit;
        mapping(address => User) users;
    }

    struct User {
        uint256 timestamp;
        uint256 quantity;
        uint256 deposit;
        mapping(address => uint256) deposits;
    }

    constructor () public ERC20("BTswap Token", "BT", 18) {
        _setInitMintBlock(block.number);
        _setLastMintBlock(block.number);
        _mint(msg.sender, 50000000 * 1e18);
    }


    /**
     * dao
     */
    function router() public view returns (IBtswapRouter02) {
        return _router;
    }

    function setRouter(IBtswapRouter02 newRouter) public onlyOwner {
        require(address(newRouter) != address(0), "BtswapToken: new router is the zero address");
        _router = newRouter;
    }

    function initMintBlock() public view returns (uint256) {
        return _initMintBlock;
    }

    function _setInitMintBlock(uint256 blockNumber) internal {
        _initMintBlock = blockNumber;
    }

    function lastMintBlock() public view returns (uint256) {
        return _lastMintBlock;
    }

    function _setLastMintBlock(uint256 blockNumber) internal {
        _lastMintBlock = blockNumber;
    }

    function weightOf(address token) public view returns (uint256) {
        uint256 _weight = _weights[token];

        if (_weight > 0) {
            return _weight;
        }

        return 1;
    }

    function setWeight(address newToken, uint256 newWeight) public onlyOwner {
        require(address(newToken) != address(0), "BtswapToken: new token is the zero address");
        _weights[newToken] = newWeight;
    }


    /**
     * miner
     */
    function phase(uint256 blockNumber) public view returns (uint256) {
        uint256 _phase = 0;

        if (blockNumber > initMintBlock()) {
            _phase = (blockNumber.sub(initMintBlock()).sub(1)).div(MINT_DECAY_DURATION);
        }

        return _phase;
    }

    function phase() public view returns (uint256) {
        return phase(block.number);
    }

    function reward(uint256 blockNumber) public view returns (uint256) {
        uint256 _phase = phase(blockNumber);
        if (_phase >= 10) {
            return 0;
        }

        return INITIAL_BLOCK_REWARD.div(2 ** _phase);
    }

    function reward() public view returns (uint256) {
        return reward(block.number);
    }

    function mintable(uint256 blockNumber) public view returns (uint256) {
        uint256 _mintable = 0;
        uint256 lastMintableBlock = lastMintBlock();
        uint256 n = phase(lastMintBlock());
        uint256 m = phase(blockNumber);

        while (n < m) {
            n++;
            uint256 r = n.mul(MINT_DECAY_DURATION).add(initMintBlock());
            _mintable = _mintable.add((r.sub(lastMintableBlock)).mul(reward(r)));
            lastMintableBlock = r;
        }
        _mintable = _mintable.add((blockNumber.sub(lastMintableBlock)).mul(reward(blockNumber)));

        return _mintable;
    }

    function mint() public returns (bool) {
        if (!isMintable()) {
            return false;
        }

        uint256 _mintable = mintable(block.number);
        if (_mintable <= 0) {
            return false;
        }

        _setLastMintBlock(block.number);

        uint256 takerMintable = _mintable.wmul(PERCENTAGE_FOR_TAKER);
        uint256 makerMintable = _mintable.wmul(PERCENTAGE_FOR_MAKER);
        uint256 groupMintable = _mintable.sub(takerMintable).sub(makerMintable);

        _mint(TAKER_ADDRESS, takerMintable);
        _mint(MAKER_ADDRESS, makerMintable);
        _mint(GROUP_ADDRESS, groupMintable);

        return true;
    }


    /**
     * oracle
     */
    function weth(address token, uint256 amount) public view returns (uint256) {
        uint256 _weth = router().weth(token);
        if (_weth <= 0) {
            return 0;
        }

        return _weth.wmul(amount);
    }

    function rebalance(address account, address pair) public view returns (uint256) {
        if (!isWhitelisted(IBtswapPairToken(pair).token0()) || !isWhitelisted(IBtswapPairToken(pair).token1())) {
            return 0;
        }

        uint256 m = IBtswapPairToken(pair).totalSupply();
        uint256 n = IBtswapPairToken(pair).balanceOf(account);
        if (n <= 0 || m <= 0) {
            return 0;
        }

        (uint112 reserve0, uint112 reserve1,) = IBtswapPairToken(pair).getReserves();
        uint256 _weth0 = weth(IBtswapPairToken(pair).token0(), uint256(reserve0));
        uint256 _weight0 = weightOf(IBtswapPairToken(pair).token0());
        uint256 _weth1 = weth(IBtswapPairToken(pair).token1(), uint256(reserve1));
        uint256 _weight1 = weightOf(IBtswapPairToken(pair).token1());

        uint256 _weth = _weth0.mul(_weight0).add(_weth1.mul(_weight1));

        return _weth.mul(n).div(m);
    }


    /**
     * taker
     */
    function shareOf(address account) public view returns (uint256, uint256) {
        uint256 m = takerQuantityOfPool();
        uint256 n = takerQuantityOf(account);

        return (m, n);
    }

    function takerQuantityOfPool() public view returns (uint256) {
        return taker.quantity;
    }

    function takerTimestampOfPool() public view returns (uint256) {
        return taker.timestamp;
    }

    function takerQuantityOf(address account) public view returns (uint256) {
        return taker.users[account].quantity;
    }

    function takerTimestampOf(address account) public view returns (uint256) {
        return taker.users[account].timestamp;
    }

    function takerBalanceOf() public view returns (uint256) {
        return balanceOf(TAKER_ADDRESS);
    }

    function takerBalanceOf(address account) public view returns (uint256) {
        (uint256 m, uint256 n) = shareOf(account);
        if (n <= 0 || m <= 0) {
            return 0;
        }

        if (n == m) {
            return takerBalanceOf();
        }

        return takerBalanceOf().mul(n).div(m);
    }

    function swap(address account, address input, uint256 amount, address output) public onlyMinter returns (bool) {
        require(account != address(0), "BtswapToken: taker swap account is the zero address");
        require(input != address(0), "BtswapToken: taker swap input is the zero address");
        require(output != address(0), "BtswapToken: taker swap output is the zero address");

        // if (!isWhitelisted(input) || !isWhitelisted(output)) {
        //     return false;
        // }

        uint256 quantity = weth(input, amount);
        if (quantity <= 0) {
            return false;
        }

        mint();

        taker.timestamp = block.timestamp;
        taker.quantity = takerQuantityOfPool().add(quantity);

        User storage user = taker.users[account];
        user.timestamp = block.timestamp;
        user.quantity = takerQuantityOf(account).add(quantity);

        return true;
    }

    function _takerWithdraw(uint256 quantity) internal returns (bool) {
        require(quantity > 0, "BtswapToken: taker withdraw quantity is the zero value");
        require(takerBalanceOf() >= quantity, "BtswapToken: taker withdraw quantity exceeds taker balance");

        uint256 delta = takerQuantityOfPool();
        if (takerBalanceOf() != quantity) {
            delta = takerQuantityOfPool().mul(quantity).div(takerBalanceOf());
        }

        taker.timestamp = block.timestamp;
        taker.quantity = takerQuantityOfPool().sub(delta);

        User storage user = taker.users[msg.sender];
        user.timestamp = block.timestamp;
        user.quantity = takerQuantityOf(msg.sender).sub(delta);

        _transfer(TAKER_ADDRESS, msg.sender, quantity);

        return true;
    }

    function takerWithdraw(uint256 quantity) public returns (bool) {
        mint();

        uint256 balance = takerBalanceOf(msg.sender);
        if (quantity <= balance) {
            return _takerWithdraw(quantity);
        }

        return _takerWithdraw(balance);
    }

    function takerWithdraw() public returns (bool) {
        mint();

        uint256 balance = takerBalanceOf(msg.sender);

        return _takerWithdraw(balance);
    }


    /**
     * maker
     */
    function liquidityOf(address account) public view returns (uint256, uint256) {
        uint256 m = makerQuantityOfPool().add(makerDepositOfPool().mul(block.number.sub(makerTimestampOfPool())));
        uint256 n = makerQuantityOf(account).add(makerDepositOf(account).mul(block.number.sub(makerTimestampOf(account))));

        return (m, n);
    }

    function makerQuantityOfPool() public view returns (uint256) {
        return maker.quantity;
    }

    function makerDepositOfPool() public view returns (uint256) {
        return maker.deposit;
    }

    function makerTimestampOfPool() public view returns (uint256) {
        return maker.timestamp;
    }

    function makerQuantityOf(address account) public view returns (uint256) {
        return maker.users[account].quantity;
    }

    function makerDepositOf(address account) public view returns (uint256) {
        return maker.users[account].deposit;
    }

    function makerLastDepositOf(address account, address pair) public view returns (uint256) {
        return maker.users[account].deposits[pair];
    }

    function makerTimestampOf(address account) public view returns (uint256) {
        return maker.users[account].timestamp;
    }

    function _makerBalanceAndLiquidityOf(address account) internal view returns (uint256, uint256, uint256) {
        (uint256 m, uint256 n) = liquidityOf(account);
        if (n <= 0 || m <= 0) {
            return (0, m, n);
        }

        if (n == m) {
            return (makerBalanceOf(), m, n);
        }

        return (makerBalanceOf().mul(n).div(m), m, n);
    }

    function makerBalanceOf() public view returns (uint256) {
        return balanceOf(MAKER_ADDRESS);
    }

    function makerBalanceOf(address account) public view returns (uint256) {
        (uint256 balance, ,) = _makerBalanceAndLiquidityOf(account);
        return balance;
    }

    function liquidity(address account, address pair) public onlyRouter returns (bool) {
        require(account != address(0), "BtswapToken: maker liquidity account is the zero address");
        require(pair != address(0), "BtswapToken: maker liquidity pair is the zero address");

        mint();
        
        User storage user = maker.users[account];
        uint256 deposit = rebalance(account, pair);
        uint256 previous = makerLastDepositOf(account, pair);

        (uint256 m, uint256 n) = liquidityOf(account);
        maker.quantity = m;
        maker.timestamp = block.number;
        maker.deposit = makerDepositOfPool().add(deposit).sub(previous);

        user.quantity = n;
        user.timestamp = block.number;
        user.deposit = makerDepositOf(account).add(deposit).sub(previous);
        user.deposits[pair] = deposit;

        return true;
    }

    function _makerWithdraw(address account) internal returns (bool) {
        require(account != address(0), "BtswapToken: maker withdraw account is the zero address");

        (uint256 withdrawn, uint256 m, uint256 n) = _makerBalanceAndLiquidityOf(account);
        if (withdrawn <= 0) {
            return false;
        }

        User storage user = maker.users[account];
        maker.timestamp = block.number;
        maker.quantity = m.sub(n);
        user.timestamp = block.number;
        user.quantity = 0;

        _transfer(MAKER_ADDRESS, account, withdrawn);

        return true;
    }

    function makerWithdraw() public returns (bool) {
        mint();

        return _makerWithdraw(msg.sender);
    }


    /**
     * group
     */
    function groupBalanceOf() public view returns (uint256) {
        return balanceOf(GROUP_ADDRESS);
    }

    function groupWithdraw(address account, uint256 amount) public onlyOwner returns (bool) {
        require(account != address(0), "BtswapToken: group withdraw account is the zero address");
        require(amount > 0, "BtswapToken: group withdraw amount is the zero value");
        require(groupBalanceOf() >= amount, "BtswapToken: group withdraw amount exceeds group balance");

        _transfer(GROUP_ADDRESS, account, amount);

        return true;
    }


    /**
     * modifier
     */
    function isMintable() public view returns (bool) {
        if (block.number.sub(lastMintBlock()) > 0 && reward(lastMintBlock()) > 0) {
            return true;
        }
        return false;
    }

    function isRouter(address account) public view returns (bool) {
        return account == address(router());
    }

    modifier onlyRouter() {
        require(isRouter(msg.sender), "BtswapToken: caller is not the router");
        _;
    }

}
