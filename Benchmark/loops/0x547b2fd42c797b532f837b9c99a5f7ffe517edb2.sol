/**
 *Submitted for verification at Etherscan.io on 2019-09-17
*/

/**
 *Submitted for verification at Etherscan.io on 2019-09-16
*/

/**
 *Submitted for verification at Etherscan.io on 2019-06-21
*/

//pragma solidity ^0.5.7;
pragma solidity >=0.5 <0.7.17;

// Skt Public Sale

/**
 * @title SafeMath for uint256
 * @dev Unsigned math operations with safety checks that revert on error.
 */
library SafeMath256 {
    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
     * @dev Multiplies two unsigned integers, reverts on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
     * @dev Integer division of two unsigned integers truncating the quotient,
     * reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b > 0);
        uint256 c = a / b;
        assert(a == b * c + a % b);
        return a / b;
    }

    /**
     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

/**
 * @title SafeMath for uint16
 * @dev Unsigned math operations with safety checks that revert on error.
 */
library SafeMath16 {
    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     */
    function add(uint16 a, uint16 b) internal pure returns (uint16 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint16 a, uint16 b) internal pure returns (uint16) {
        assert(b <= a);
        return a - b;
    }

    /**
     * @dev Multiplies two unsigned integers, reverts on overflow.
     */
    function mul(uint16 a, uint16 b) internal pure returns (uint16 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
     * @dev Integer division of two unsigned integers truncating the quotient,
     * reverts on division by zero.
     */
    function div(uint16 a, uint16 b) internal pure returns (uint16) {
        assert(b > 0);
        uint256 c = a / b;
        assert(a == b * c + a % b);
        return a / b;
    }

    /**
     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint16 a, uint16 b) internal pure returns (uint16) {
        require(b != 0);
        return a % b;
    }
}


/**
 * @title Ownable
 */
contract Ownable {
    address private _owner;
    address payable internal _receiver;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event ReceiverChanged(address indexed previousReceiver, address indexed newReceiver);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract
     * to the sender account.
     */
    constructor () internal {
        _owner = msg.sender;
        _receiver = msg.sender;
    }

    /**
     * @return The address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == _owner);
        _;
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != _owner);
        address __previousOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(__previousOwner, newOwner);
    }

   
}


/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
    bool private _paused;

    event Paused(address account);
    event Unpaused(address account);

    constructor () internal {
        _paused = false;
    }

    /**
     * @return Returns true if the contract is paused, false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!_paused, "Paused.");
        _;
    }

    /**
     * @dev Called by a pauser to pause, triggers stopped state.
     */
    function setPaused(bool state) external onlyOwner {
        if (_paused && !state) {
            _paused = false;
            emit Unpaused(msg.sender);
        } else if (!_paused && state) {
            _paused = true;
            emit Paused(msg.sender);
        }
    }
}


/**
 * @title ERC20 interface
 * @dev see https://eips.ethereum.org/EIPS/eip-20
 */
interface IERC20 {
    function balanceOf(address owner) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
}


/**
 * @title Skt interface
 */
interface ISkt {
    function balanceOf(address owner) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function inWhitelist(address account) external view returns (bool);
    function referrer(address account) external view returns (address);
    function refCount(address account) external view returns (uint256);
}


/**
 * @title Skt Public Sale
 */
contract SktPublicSale is Ownable, Pausable{
    using SafeMath16 for uint16;
    using SafeMath256 for uint256;

    // Skt
    ISkt public SKT = ISkt(0x2fB74C37Fb2C8DC76beA1910737aa9E3e2b53535);

    // Start timestamp
    uint32 _startTimestamp;

    // Audit ether price
    uint256 private _etherPrice;    

    // Referral rewards, 35% for 15 levels
    uint16 private WHITELIST_REF_REWARDS_PCT_SUM = 35; 
	
    uint16[3] private WHITELIST_REF_REWARDS_PCT = [
        15,  // 15% for Level.1
        12,  // 12% for Level.2
        8   // 8% for Level.3
    ];
	
	
    // Wei & Gas
    uint72 private WEI_MIN = 0.1 ether;     
    uint72 private WEI_MAX = 100 ether;     
    uint72 private WEI_BONUS = 10 ether;    
    uint24 private GAS_MIN = 3000000;       
    uint24 private GAS_EX  = 1500000;        

    // Price
    uint256 private SKT_USD_PRICE_START = 100000;       
    uint256 private SKT_USD_PRICE_STEP = 10000;         
   
    uint256 private STAGE_USD_CAP_START = 9000000000000;    
    uint256 private STAGE_USD_CAP_STEP = 900000000000;       
    uint256 private STAGE_USD_CAP_MAX = 90000000000000;   
    
    uint256 private STAGE_SKT_CAP_START = 900000000000;    
    uint256 private STAGE_SKT_CAP_STEP  = 900000000000;       
    uint256 private STAGE_SKT_CAP_MAX   = 90000000000000;    
    
    uint256 private _SKTUsdPrice = SKT_USD_PRICE_START; 
    
    uint16 private STAGE_MAX = 100;  
    

    uint16 private _stage;
   

    // Sum
    uint256 private _txs; 
    uint256 private _SKTTxs;
    uint256 private _SKTBonusTxs;
    uint256 private _SKTWhitelistTxs;
    uint256 private _SKTIssued;
    uint256 private _SKTBonus;
    uint256 private _SKTWhitelist;
    uint256 private _usdSold;
    uint256 private _weiSold;  
    uint256 private _weiRefRewarded;  
    uint256 private _weiTeam; 
    


    // During tx
    bool private _inWhitelist_;
   
    uint16[] private _rewards_;
    address[] private _referrers_;

    

    // Stage
    mapping (uint16 => uint256) private _stageUsdSold; 
    mapping (uint16 => uint256) private _stageSKTIssued; 
   

   

    // Account
    mapping (address => uint256) private _accountSKTIssued;
    mapping (address => uint256) private _accountSKTBonus;
    mapping (address => uint256) private _accountSKTWhitelisted;
    mapping (address => uint256) private _accountWeiPurchased; 
    mapping (address => uint256) private _accountWeiRefRewarded; 

  
   

    // Events
    event AuditEtherPriceChanged(uint256 value, address indexed account);
    event AuditEtherPriceAuditorChanged(address indexed account, bool state);

    event SKTBonusTransfered(address indexed to, uint256 amount);
    event SKTWhitelistTransfered(address indexed to, uint256 amount);
    event SKTIssuedTransfered(uint16 stageIndex, address indexed to, uint256 SKTAmount, uint256 auditEtherPrice, uint256 weiUsed);

    event StageClosed(uint256 _stageNumber, address indexed account);
   
    event TeamWeiTransfered(address indexed to, uint256 amount);
    event PendingWeiTransfered(address indexed to, uint256 amount);


    /**
     * @dev Start timestamp.
     */
    function startTimestamp() public view returns (uint32) {
        return _startTimestamp;
    }

    /**
     * @dev Set start timestamp.
     */
    function setStartTimestamp(uint32 timestamp) external onlyOwner {
        _startTimestamp = timestamp;
    }

  

    /**
     * @dev Set audit ether price.
     */
    function setEtherPrice(uint256 value) external onlyOwner {
        _etherPrice = value;
        emit AuditEtherPriceChanged(value, msg.sender);
    }

 

   

    /**
     * @dev Stage SKT price in USD, by stage index.
     */
	//返回 当前 阶段 USD的 值
	function stageSKTUsdPrice(uint16 stageIndex) private view returns (uint256) {
		
        return SKT_USD_PRICE_START.add(SKT_USD_PRICE_STEP.mul(stageIndex));
    }

    /**
     * @dev wei => USD
     */
    function wei2usd(uint256 amount) private view returns (uint256) {
        return amount.mul(_etherPrice).div(1 ether);
    }

    /**
     * @dev USD => wei
     */
    function usd2wei(uint256 amount) private view returns (uint256) {
        return amount.mul(1 ether).div(_etherPrice);
    }

    /**
     * @dev USD => SKT
     */
    function usd2SKT(uint256 usdAmount) private view returns (uint256) {
      
		return usdAmount.mul(1000000).div(_SKTUsdPrice);
    }
    
     /**
     * @dev SKT => USD
     */
    function SKT2usd(uint256 usdAmount) private view returns (uint256) {
      
		return usdAmount.mul(_SKTUsdPrice).div(1000000);
    }

    /**
     * @dev USD => SKT
     */
    function usd2SKTByStage(uint256 usdAmount, uint16 stageIndex) public view returns (uint256) {

        if(stageIndex<1){
            stageIndex = 0;
        }
        return usdAmount.mul(1000000).div(stageSKTUsdPrice(stageIndex));
    }


    /**
     * @dev Status.
     */
    function status() public view returns (uint256 auditEtherPrice,
                                           uint16 stage,
                                           uint256 SKTUsdPrice,
                                           uint256 txs,
                                           uint256 SKTTxs,
                                           uint256 SKTBonusTxs,
                                           uint256 SKTWhitelistTxs,
                                           uint256 SKTIssued,
                                           uint256 SKTBonus,
                                           uint256 useSold,
                                           uint256 weiSold,
                                           uint256 weiReferralRewarded,
                                           uint256 weiTeam) {
        auditEtherPrice = _etherPrice;

        if (_stage > STAGE_MAX) {
            stage = STAGE_MAX;
            
        } else {
            stage = _stage + 1;
            
        }

        SKTUsdPrice = _SKTUsdPrice;
        txs = _txs;
        SKTTxs = _SKTTxs;
        SKTBonusTxs = _SKTBonusTxs;
        SKTWhitelistTxs = _SKTWhitelistTxs;
        SKTIssued = _SKTIssued;
        SKTBonus = _SKTBonus;
        useSold = _usdSold;
        weiSold = _weiSold;
        weiReferralRewarded = _weiRefRewarded;
        weiTeam = _weiTeam;
    }

   

    /**
     * @dev Throws if gas is not enough.
     */
    modifier enoughGas() {
        require(gasleft() > GAS_MIN);
        _;
    }

    /**
     * @dev Throws if not started.
     */
    modifier onlyOnSale() {
        require(_startTimestamp > 0 && now > _startTimestamp, "SKT Public-Sale has not started yet.");
        require(_etherPrice > 0, "Audit ETH price must be greater than zero.");
        require(!paused(), "SKT Public-Sale is paused.");
        require(_stage <= STAGE_MAX, "SKT Public-Sale Closed.");
        _;
    }


    /**
     * @dev Calculate stage dollor cap, by stage index.
     */
    function stageUsdCap(uint16 stageIndex) private view returns (uint256) {
        uint256 __usdCap = STAGE_USD_CAP_START.add(STAGE_USD_CAP_STEP.mul(stageIndex));

        if (__usdCap > STAGE_USD_CAP_MAX) {
            return STAGE_USD_CAP_MAX;
        }

        return __usdCap;
    }
    
    
    function stageSKTCapGet(uint16 stageIndex) private view returns (uint256) {
        uint256 __sktCap = STAGE_SKT_CAP_START.add(STAGE_SKT_CAP_STEP.mul(stageIndex));

        if (__sktCap >= STAGE_SKT_CAP_MAX) {
            return STAGE_SKT_CAP_MAX;
        }

        return __sktCap;
    }

    /**
     * @dev Stage Vokdn cap, by stage index.
     */
    function stageSKTCap(uint16 stageIndex) private view returns (uint256) {
      
        stageIndex = 1;
        return STAGE_SKT_CAP_STEP.mul(stageIndex);
    }

    /**
     * @dev Stage status, by stage index.
     */
    function stageStatus(uint16 stageIndex) public view returns (uint256 SKTUsdPrice,
                                                                 uint256 SKTCap,
                                                                 uint256 SKTOnSale,
                                                                 uint256 SKTSold,
                                                                 uint256 weiSold,
                                                                 uint256 usdSold
                                                                 ) {
        if (stageIndex > STAGE_MAX) {
            return (0, 0, 0, 0, 0 , 0);
        }
        
        if(stageIndex<1)
        {
            return (0, 0, 0, 0, 0 , 0);
        }
        
        stageIndex = stageIndex.sub(1);

        SKTUsdPrice = stageSKTUsdPrice(stageIndex);

        SKTSold = _stageSKTIssued[stageIndex]; 
        SKTCap = stageSKTCap(stageIndex); 
        SKTOnSale = SKTCap.sub(SKTSold);
        
        usdSold = _stageUsdSold[stageIndex];
        weiSold = usd2wei(usdSold);
       
    }



    /**
     * @dev Query account.
     */
    function accountQuery(address account) public view returns (uint256 SKTIssued,
                                                                uint256 SKTWhitelisted,
                                                                uint256 weiPurchased,
                                                                uint256 weiReferralRewarded) {
        SKTIssued = _accountSKTIssued[account];
        SKTWhitelisted = _accountSKTWhitelisted[account];
        weiPurchased = _accountWeiPurchased[account];
        weiReferralRewarded = _accountWeiRefRewarded[account];
    }



    /**
     * @dev constructor
     */
    constructor () public {
       
        _stage = 0;
        
    }
    

    /**
     * @dev Receive ETH, and send SKTs.
     */
    function () external payable enoughGas onlyOnSale {
        require(msg.value >= WEI_MIN); // WEI_MIN 0.1 ether
        require(msg.value <= WEI_MAX); // WEI_MAX 100 ether

        // Set temporary variables.
        setTemporaryVariables();
		
		
        uint256 __usdAmount = wei2usd(msg.value);
        uint256 __usdRemain = __usdAmount;
        uint256 __sktRemain = usd2SKT(__usdAmount);
        uint256 __SKTIssued; 
        uint256 __usdUsed;
        uint256 __weiUsed;
        
        
        
        // USD => SKT
		while (gasleft() > GAS_EX && __sktRemain > 0 && _stage <= STAGE_MAX) {
			
			if(_stage.add(1)==STAGE_MAX && _stageSKTIssued[_stage] == STAGE_SKT_CAP_STEP){
			    break;
			}
			
            uint256 __txSKTIssued;
			
            (__txSKTIssued, __usdRemain,__sktRemain) = ex(__usdRemain);
            __SKTIssued = __SKTIssued.add(__txSKTIssued);
        }
        
        

        // Used
        __usdUsed = __usdAmount.sub(__usdRemain);
        __weiUsed = usd2wei(__usdUsed);

       
        // Whitelisted
        // BUY-ONE-AND-GET-ONE-MORE-FREE
        if (_inWhitelist_ && __SKTIssued > 0 && _stage <= STAGE_MAX) {
            // both issued and bonus
            assert(transferSKTWhitelisted(__SKTIssued));

            // 35% for 3 levels
            sendWhitelistReferralRewards(__weiUsed);
        }

        // If wei remains, refund.
        if (__usdRemain > 0) {
            uint256 __weiRemain = usd2wei(__usdRemain);

            __weiUsed = msg.value.sub(__weiRemain);
            
            // Refund wei back
            msg.sender.transfer(__weiRemain);
        }

        // Counter
        if (__weiUsed > 0) {
		
            _txs = _txs.add(1);
		
            _weiSold = _weiSold.add(__weiUsed);
		
            _accountWeiPurchased[msg.sender] = _accountWeiPurchased[msg.sender].add(__weiUsed);
        }

        // Wei team
        uint256 __weiTeam;
       
        __weiTeam = _weiSold.sub(_weiRefRewarded).sub(_weiTeam);

        _weiTeam = _weiTeam.add(__weiTeam);
         
        _receiver.transfer(__weiTeam);

        // Assert finished
        assert(true);
    }

    /**
     * @dev Set temporary variables.
     */
    function setTemporaryVariables() private {
        delete _referrers_;
        delete _rewards_;
		
        _inWhitelist_ = SKT.inWhitelist(msg.sender);
		
        
		
        address __cursor = msg.sender;

        for(uint16 i = 0; i < WHITELIST_REF_REWARDS_PCT.length; i++) {
			
            address __refAccount = SKT.referrer(__cursor);
            
            if (__cursor == __refAccount) {
				
                break;
            }
            
            _rewards_.push(WHITELIST_REF_REWARDS_PCT[i]);
            _referrers_.push(__refAccount);
            
            __cursor = __refAccount;
        }
    }

    /**
     * @dev USD => SKT
     */
    function ex(uint256 usdAmount) private returns (uint256, uint256, uint256) {
	
		
		uint256 __stageSktCap = STAGE_SKT_CAP_STEP;
		uint256 __SKTsued;
        uint256 __SKTIssued;
        
        __SKTsued = usd2SKT(usdAmount);

        // in stage
        if (_stageSKTIssued[_stage].add(__SKTsued) <= __stageSktCap) {
            
			exCount(usdAmount);

            __SKTIssued = usd2SKT(usdAmount);
            assert(transferSKTIssued(__SKTIssued, usdAmount));

            // close stage, if stage dollor cap reached
            if (__stageSktCap == _stageSKTIssued[_stage]) {
                assert(closeStage());
            }

            return (__SKTIssued, 0, 0);
        }
		
        // close stage
        __SKTIssued = __stageSktCap.sub(_stageSKTIssued[_stage]);
        
        uint256 __usdUsed = SKT2usd(__SKTIssued);
        
        
        exCount(__usdUsed);
        
        uint256 __sktRemain = __SKTsued.sub(__SKTIssued);
        uint256 __usdRemain = usdAmount.sub(__usdUsed);
        
        assert(transferSKTIssued(__SKTIssued, __usdUsed));
        assert(closeStage());

        return (__SKTIssued, __usdRemain, __sktRemain);
    }
	
   

    /**
     * @dev Ex counter.
     */
    function exCount(uint256 usdAmount) private {
       
        _stageUsdSold[_stage] = _stageUsdSold[_stage].add(usdAmount);                   // stage sold, in USD
        _usdSold = _usdSold.add(usdAmount);
    }

    /**
     * @dev Transfer SKT issued.
     */
    function transferSKTIssued(uint256 amount, uint256 usdAmount) private returns (bool) {
        
		_SKTTxs = _SKTTxs.add(1);
	
        _SKTIssued = _SKTIssued.add(amount);
		
        _stageSKTIssued[_stage] = _stageSKTIssued[_stage].add(amount);
	
        _accountSKTIssued[msg.sender] = _accountSKTIssued[msg.sender].add(amount);

        assert(SKT.transfer(msg.sender, amount));
        emit SKTIssuedTransfered(_stage, msg.sender, amount, _etherPrice, usdAmount);
        return true;
    }

 

    /**
     * @dev Transfer SKT whitelisted.
     */
    function transferSKTWhitelisted(uint256 amount) private returns (bool) {
       
		_SKTWhitelistTxs = _SKTWhitelistTxs.add(1);
		_SKTBonusTxs = _SKTBonusTxs.add(1) ;
		
		
		
		uint256 __stageSktCap = STAGE_SKT_CAP_STEP;//stageSKTCapGet(_stage);
	    
	    uint256 __remainSKT = amount; 
      
	    while (_stageSKTIssued[_stage].add(__remainSKT) >= __stageSktCap) {
            
            uint256 __transferSKT = __stageSktCap.sub(_stageSKTIssued[_stage]);
            
                
            _stageSKTIssued[_stage] = _stageSKTIssued[_stage].add(__transferSKT);
            __remainSKT = __remainSKT.sub(__transferSKT);
            
            assert(closeStage());
            
        }
        
        _stageSKTIssued[_stage] = _stageSKTIssued[_stage].add(__remainSKT);
        
        _SKTWhitelist = _SKTWhitelist.add(amount);
		
        _accountSKTWhitelisted[msg.sender] = _accountSKTWhitelisted[msg.sender].add(amount);
        
		_SKTIssued = _SKTIssued.add(amount);
		_SKTBonus =  _SKTBonus.add(amount);

        
        assert(SKT.transfer(msg.sender, amount));
        
        
        emit SKTWhitelistTransfered(msg.sender, amount);
        return true;
    }

    /**
     * Close current stage.
     */
    function closeStage() private returns (bool) {
        emit StageClosed(_stage, msg.sender);
        _stage = _stage.add(1);
        _SKTUsdPrice = stageSKTUsdPrice(_stage);
        
        if(_stage>=STAGE_MAX)
        {
            _stage = STAGE_MAX.sub(1);
        }
       
        return true;
    }
    
    
    /**
     * @dev Send whitelist referral rewards.
     */
    function sendWhitelistReferralRewards(uint256 weiAmount) private {
        uint256 __weiRemain = weiAmount;
         
        for (uint16 i = 0; i < _rewards_.length; i++) {
			
            uint256 __weiReward = weiAmount.mul(_rewards_[i]).div(100);
            
            address payable __receiverRefer = address(uint160(_referrers_[i]));
		
            _weiRefRewarded = _weiRefRewarded.add(__weiReward);
		
            _accountWeiRefRewarded[__receiverRefer] = _accountWeiRefRewarded[__receiverRefer].add(__weiReward);
            __weiRemain = __weiRemain.sub(__weiReward);
            
            if(__receiverRefer!=address(this)){
                __receiverRefer.transfer(__weiReward);
            }
        }

       
    }
}
