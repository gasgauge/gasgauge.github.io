/**
 *Submitted for verification at Etherscan.io on 2019-11-04
*/

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

// Ct Public Sale

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
 * @title Ct interface
 */
interface ICt {
    function balanceOf(address owner) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function inWhitelist(address account) external view returns (bool);
    function referrer(address account) external view returns (address);
    function referrerel(address account) external view returns (address[] memory);
    function refCount(address account) external view returns (uint256);
}


/**
 * @title Ct Public Sale
 */
contract CtPublicSale is Ownable, Pausable{
    using SafeMath16 for uint16;
    using SafeMath256 for uint256;

    // Ct
    ICt public CT = ICt(0x3Fa7807FF5a1C70699C912b66413f358AaDeaA75);

    // Start timestamp
    uint32 _startTimestamp;

    // Audit ether price
    uint256 private _etherPrice;    

    
	
    uint16[2] private WHITELIST_REF_REWARDS_PCT = [
        15,  // 15% for Level.1
        12  // 12% for Level.2
        
    ];
	
	
    // Wei & Gas
    uint72 private WEI_MIN = 0.1 ether;     
    uint72 private WEI_MAX = 100 ether;     
    uint72 private WEI_BONUS = 10 ether;    
    uint24 private GAS_MIN = 3000000;       
    uint24 private GAS_EX  = 1500000;        

    // Price
    uint256 private CT_USD_PRICE_START = 100000;       
    uint256 private CT_USD_PRICE_STEP = 10000;         
   
    uint256 private STAGE_USD_CAP_START = 10000000000000;    
    uint256 private STAGE_USD_CAP_STEP = 1000000000000;       
    uint256 private STAGE_USD_CAP_MAX = 100000000000000;   
    
    uint256 private STAGE_CT_CAP_START = 1000000000000;    
    uint256 private STAGE_CT_CAP_STEP  = 1000000000000;       
    uint256 private STAGE_CT_CAP_MAX   = 100000000000000;    
    
    uint256 private _CTUsdPrice = CT_USD_PRICE_START; 
    
    uint16 private STAGE_MAX = 100;  
    

    uint16 private _stage;
   

    // Sum
    uint256 private _txs; 
    uint256 private _CTTxs;
    uint256 private _CTBonusTxs;
    uint256 private _CTWhitelistTxs;
    uint256 private _CTIssued;
    uint256 private _CTBonus;
    uint256 private _CTWhitelist;
    uint256 private _usdSold;
    uint256 private _weiSold;  
    uint256 private _weiRefRewarded;  
    
    uint256 private _ctRefRewarded;
    uint256 private _weiTeam=0; 
    


    // During tx
    bool private _inWhitelist_;
   
    uint16[] private _rewards_;
    address[] private _referrers_;

    

    // Stage
    mapping (uint16 => uint256) private _stageUsdSold; 
    mapping (uint16 => uint256) private _stageCTIssued; 
    mapping (uint16 => uint256) private _stageCTRewarded;
    
    mapping (uint16 => uint256) private _stageCTRewardedTx;

   

    // Account
    mapping (address => uint256) private _accountCTIssued;
    mapping (address => uint256) private _accountCTBonus;
    mapping (address => uint256) private _accountCTWhitelisted;
    mapping (address => uint256) private _accountWeiPurchased; 
    mapping (address => uint256) private _accountWeiRefRewarded; 

  
   

    // Events
    event AuditEtherPriceChanged(uint256 value, address indexed account);
    event AuditEtherPriceAuditorChanged(address indexed account, bool state);

    event CTBonusTransfered(address indexed to, uint256 amount);
    event CTWhitelistTransfered(address indexed to, uint256 amount);
    event CTIssuedTransfered(uint16 stageIndex, address indexed to, uint256 CTAmount, uint256 auditEtherPrice, uint256 weiUsed);

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
     * @dev Stage CT price in USD, by stage index.
     */
	//返回 当前 阶段 USD的 值
	function stageCTUsdPrice(uint16 stageIndex) private view returns (uint256) {
		
        return CT_USD_PRICE_START.add(CT_USD_PRICE_STEP.mul(stageIndex));
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
     * @dev USD => CT
     */
    function usd2CT(uint256 usdAmount) private view returns (uint256) {
      
		return usdAmount.mul(1000000).div(_CTUsdPrice);
    }
    
     /**
     * @dev CT => USD
     */
    function CT2usd(uint256 usdAmount) private view returns (uint256) {
      
		return usdAmount.mul(_CTUsdPrice).div(1000000);
    }

    /**
     * @dev USD => CT
     */
    function usd2CTByStage(uint256 usdAmount, uint16 stageIndex) public view returns (uint256) {

        if(stageIndex<1){
            stageIndex = 0;
        }
        return usdAmount.mul(1000000).div(stageCTUsdPrice(stageIndex));
    }


    /**
     * @dev Status.
     */
    function status() public view returns (uint256 auditEtherPrice,
                                           uint16  stage,
                                           uint256 CTUsdPrice,
                                           uint256 txs,
                                           uint256 CTTxs,
                                           uint256 CTBonusTxs,
                                           uint256 CTWhitelistTxs,
                                           uint256 CTIssued,
                                           uint256 CTBonus,
                                           uint256 useSold,
                                           uint256 weiSold,
                                           uint256 weiReferralRewarded,
                                           uint256 ctReferralRewarded,
                                           uint256 weiTeam) {
        auditEtherPrice = _etherPrice;

        if (_stage > STAGE_MAX) {
            stage = STAGE_MAX;
            
        } else {
            stage = _stage + 1;
            
        }

        CTUsdPrice = _CTUsdPrice;
        txs = _txs;
        CTTxs = _CTTxs;
        CTBonusTxs = _CTBonusTxs;
        CTWhitelistTxs = _CTWhitelistTxs;
        CTIssued = _CTIssued;
        CTBonus = _CTBonus;
        useSold = _usdSold;
        weiSold = _weiSold;
        weiReferralRewarded = _weiRefRewarded;
        ctReferralRewarded  = _ctRefRewarded;
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
        require(_startTimestamp > 0 && now > _startTimestamp, "CT Public-Sale has not started yet.");
        require(_etherPrice > 0, "Audit ETH price must be greater than zero.");
        require(!paused(), "CT Public-Sale is paused.");
        require(_stage <= STAGE_MAX, "CT Public-Sale Closed.");
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
    
    
    function stageCTCapGet(uint16 stageIndex) private view returns (uint256) {
        uint256 __ctCap = STAGE_CT_CAP_START.add(STAGE_CT_CAP_STEP.mul(stageIndex));

        if (__ctCap >= STAGE_CT_CAP_MAX) {
            return STAGE_CT_CAP_MAX;
        }

        return __ctCap;
    }

    /**
     * @dev Stage Vokdn cap, by stage index.
     */
    function stageCTCap(uint16 stageIndex) private view returns (uint256) {
      
        stageIndex = 1;
        return STAGE_CT_CAP_STEP.mul(stageIndex);
    }

    /**
     * @dev Stage status, by stage index.
     */
    function stageStatus(uint16 stageIndex) public view returns (uint256 CTUsdPrice,
                                                                 uint256 CTCap,
                                                                 uint256 CTOnSale,
                                                                 uint256 CTSold,
                                                                 uint256 CTRewarded,
                                                                 uint256 CTWhitelistTxs,
                                                                 uint256 weiSold,
                                                                 uint256 usdSold
                                                                 ) {
        if (stageIndex > STAGE_MAX) {
            return (0, 0, 0, 0, 0,0,0,0);
        }
        
        if(stageIndex<1)
        {
            return (0, 0, 0, 0, 0,0,0,0);
        }
        
        stageIndex = stageIndex.sub(1);

        CTUsdPrice = stageCTUsdPrice(stageIndex);

        CTSold = _stageCTIssued[stageIndex]; 
        CTRewarded = _stageCTRewarded[stageIndex];
        CTCap = stageCTCap(stageIndex); 
        CTOnSale = CTCap.sub(CTSold);
        
        CTWhitelistTxs = _stageCTRewardedTx[stageIndex];
        
        usdSold = _stageUsdSold[stageIndex];
        weiSold = usd2wei(usdSold);
       
    }



    /**
     * @dev Query account.
     */
    function accountQuery(address account) public view returns (uint256 CTIssued,
                                                                uint256 CTWhitelisted,
                                                                uint256 weiPurchased,
                                                                uint256 weiReferralRewarded) {
        CTIssued = _accountCTIssued[account];
        CTWhitelisted = _accountCTWhitelisted[account];
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
     * @dev Receive ETH, and send CTs.
     */
    function () external payable enoughGas onlyOnSale {
        require(msg.value >= WEI_MIN); // WEI_MIN 0.1 ether
        require(msg.value <= WEI_MAX); // WEI_MAX 100 ether

        // Set temporary variables.
         setTemporaryVariables();
		
		
        uint256 __usdAmount = wei2usd(msg.value);
        uint256 __usdRemain = __usdAmount;
        uint256 __ctRemain = usd2CT(__usdAmount);
        uint256 __CTIssued; 
        uint256 __usdUsed;
        uint256 __weiUsed;
        
        // USD => CT
		while (gasleft() > GAS_EX && __ctRemain > 0 && _stage <= STAGE_MAX) {
			
			if(_stage.add(1)==STAGE_MAX && _stageCTIssued[_stage] == STAGE_CT_CAP_STEP){
			    break;
			}
			
            uint256 __txCTIssued;
			
            (__txCTIssued, __usdRemain,__ctRemain) = ex(__usdRemain);
            __CTIssued = __CTIssued.add(__txCTIssued);
        }
        
        if(__CTIssued>0)
        {
            assert(CT.transfer(msg.sender, __CTIssued));
        }
        
        
        // Used
        __usdUsed = __usdAmount.sub(__usdRemain);
        __weiUsed = usd2wei(__usdUsed);

       
        // Whitelisted
        // BUY-ONE-AND-GET-ONE-MORE-FREE
        if (_inWhitelist_ && __CTIssued > 0 && _stage <= STAGE_MAX) {
            
            // 35% for 3 levels
            sendWhitelistReferralRewards(__CTIssued);
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
        
        emit CTWhitelistTransfered(msg.sender, _weiSold);
        
        emit CTWhitelistTransfered(msg.sender, _weiRefRewarded);

        // Wei team
        uint256 __weiTeam;
       
        __weiTeam = _weiSold.sub(_weiRefRewarded).sub(_weiTeam);

        _weiTeam = _weiTeam.add(__weiTeam);
         
        _receiver.transfer(__weiTeam);

        // Assert finished
        assert(true);
    }
    
    function _mint(address account, uint256 value) public onlyOwner returns (bool) {
        require(CT.balanceOf(address(this)) > value);
        require(account != address(0));

        assert(CT.transfer(account, value));
        
        return transferCTWhitelisted(value);
     
        
    }

    /**
     * @dev Set temporary variables.
     */
    function setTemporaryVariables() private {
        delete _referrers_;
        delete _rewards_;
		
        _inWhitelist_ = true;
		
        address __cursor = msg.sender;

        for(uint16 i = 0; i < WHITELIST_REF_REWARDS_PCT.length; i++) {
			
            address __refAccount = CT.referrer(__cursor);
            
            
            if(__refAccount==address(0)){
                break;
            }
            
            if (__cursor == __refAccount) {
				
                break;
            }
            
            _rewards_.push(WHITELIST_REF_REWARDS_PCT[i]);
            _referrers_.push(__refAccount);
            
            __cursor = __refAccount;
        }
    }

    /**
     * @dev USD => CT
     */
    function ex(uint256 usdAmount) private returns (uint256, uint256, uint256) {
	
		
		uint256 __stageCtCap = STAGE_CT_CAP_STEP;
		uint256 __CTsued;
        uint256 __CTIssued;
        
        __CTsued = usd2CT(usdAmount);

        // in stage
        if (_stageCTIssued[_stage].add(__CTsued) <= __stageCtCap) {
            
			exCount(usdAmount);

            __CTIssued = usd2CT(usdAmount);
           assert(transferCTIssued(__CTIssued, usdAmount));

            // close stage, if stage dollor cap reached
            if (__stageCtCap == _stageCTIssued[_stage]) {
                assert(closeStage());
            }

            return (__CTIssued, 0, 0);
        }
		
        // close stage
        __CTIssued = __stageCtCap.sub(_stageCTIssued[_stage]);
        
        uint256 __usdUsed = CT2usd(__CTIssued);
        
        
        exCount(__usdUsed);
        
        uint256 __ctRemain = __CTsued.sub(__CTIssued);
        uint256 __usdRemain = usdAmount.sub(__usdUsed);
        
        assert(transferCTIssued(__CTIssued, __usdUsed));
        assert(closeStage());

        return (__CTIssued, __usdRemain, __ctRemain);
    }
	
   

    /**
     * @dev Ex counter.
     */
    function exCount(uint256 usdAmount) private {
       
        _stageUsdSold[_stage] = _stageUsdSold[_stage].add(usdAmount);                   // stage sold, in USD
        _usdSold = _usdSold.add(usdAmount);
    }

    /**
     * @dev Transfer CT issued.
     */
    function transferCTIssued(uint256 amount, uint256 usdAmount) private returns (bool) {
        
		_CTTxs = _CTTxs.add(1);
	
        _CTIssued = _CTIssued.add(amount);
		
        _stageCTIssued[_stage] = _stageCTIssued[_stage].add(amount);
	
        _accountCTIssued[msg.sender] = _accountCTIssued[msg.sender].add(amount);

        emit CTIssuedTransfered(_stage, msg.sender, amount, _etherPrice, usdAmount);
        return true;
    }

 

    /**
     * @dev Transfer CT whitelisted.
     */
    function transferCTWhitelisted(uint256 amount) private returns (bool) {
      
		_CTBonusTxs = _CTBonusTxs.add(1) ;
		
		uint256 __stageCtCap = STAGE_CT_CAP_STEP;//stageCTCapGet(_stage);
	    
	    uint256 __remainCT = amount; 
      
	    while (_stageCTIssued[_stage].add(__remainCT) >= __stageCtCap) {
            
            uint256 __transferCT = __stageCtCap.sub(_stageCTIssued[_stage]);
            
                
            _stageCTIssued[_stage] = _stageCTIssued[_stage].add(__transferCT);
            __remainCT = __remainCT.sub(__transferCT);
            
            assert(closeStage());
            
        }
        
        _stageCTIssued[_stage] = _stageCTIssued[_stage].add(__remainCT);
        
        _CTWhitelist = _CTWhitelist.add(amount);
		
        _accountCTWhitelisted[msg.sender] = _accountCTWhitelisted[msg.sender].add(amount);
        
		_CTIssued = _CTIssued.add(amount);
		_CTBonus =  _CTBonus.add(amount);
        
        emit CTWhitelistTransfered(msg.sender, amount);
        return true;
    }

    /**
     * Close current stage.
     */
    function closeStage() private returns (bool) {
        emit StageClosed(_stage, msg.sender);
        _stage = _stage.add(1);
        _CTUsdPrice = stageCTUsdPrice(_stage);
        
        if(_stage>=STAGE_MAX)
        {
            _stage = STAGE_MAX.sub(1);
        }
       
        return true;
    }
    
    
    /**
     * @dev Send whitelist referral rewards.
     */
    function sendWhitelistReferralRewards(uint256 ctIssued) private {
        uint256 __ctIssued = ctIssued;
         
        for (uint16 i = 0; i < _rewards_.length; i++) {
			
            uint256 __ctReward = __ctIssued.mul(_rewards_[i]).div(100);
            
            assert(CT.transfer(_referrers_[i], __ctReward));
            
            transferCTWhitelisted(__ctReward);
            _ctRefRewarded = _ctRefRewarded.add(__ctReward);
            _CTWhitelistTxs = _CTWhitelistTxs.add(1);
            _stageCTRewarded[_stage] = _stageCTRewarded[_stage].add(__ctReward);
            
            _stageCTRewardedTx[_stage] = _stageCTRewardedTx[_stage].add(1);
		
            
        }

       
    }
}
