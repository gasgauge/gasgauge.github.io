/**
 *Submitted for verification at Etherscan.io on 2020-09-05
*/

//pragma solidity 0.5.16;
pragma solidity >=0.5 <0.7.17;

contract InfiniteEthereum {
    address public ownerWallet;

    struct UserStruct {
        uint currentPool;
        address user;
        mapping(uint => PoolStruct) pool;
    }
    
    struct PoolStruct {
        uint currentID;
        uint referrerID;
        uint[] referrals;
        uint reinvestCount;
    }
    
    uint public DOWNLINE_LIMIT = 5;
    bool public lockStatus;
    
    mapping(uint => UserStruct) public poolusers;
    mapping (uint => mapping(uint => address)) public poolList;
    mapping (uint => uint) public PoolcurrentID;
    
    mapping (uint => uint) public poolPrice;
    mapping (address => mapping (uint => bool)) public levelStatus;
    
    event JoinFee( address indexed UserAddress, uint UserID, uint Amount, uint Time);
    event BuyPool(uint indexed Pool, address indexed UserAddress, uint UserID, address indexed toaddress, uint RefererID, uint Amount, uint flag, uint Time);
    
    constructor() public {
        ownerWallet = msg.sender;
        poolPrice[1] = 0.05 ether;
        poolPrice[2] = 0.1 ether;
        poolPrice[3] = 0.4 ether;
        poolPrice[4] = 1.6 ether;
        poolPrice[5] = 6.4 ether;
        poolPrice[6] = 25.6 ether;
        poolPrice[7] = 102.4 ether;
        poolPrice[8] = 409.6 ether;
        poolPrice[9] = 1638.4 ether;
        poolPrice[10] = 6553.6 ether;
        poolPrice[11] = 26214.4 ether;
        poolPrice[12] = 104857.6 ether;
        
        for(uint i=1; i <= 12; i++) {
            poolusers[1].currentPool = i;
            poolusers[1].user = ownerWallet;
            poolusers[1].pool[1].referrals = new uint[](0); 
            levelStatus[ownerWallet][i] = true;
            PoolcurrentID[i]++;
            poolusers[PoolcurrentID[i]].pool[1].currentID = PoolcurrentID[i];
            poolList[i][PoolcurrentID[i]] = ownerWallet;
        }
    } 
    
    
    function poolRegistration(uint _referrerID) public payable returns (bool) {
        require(lockStatus == false, "Contract Locked");
        require(!levelStatus[msg.sender][1], "User exist");
        require(msg.value == poolPrice[1], "Incorrect value");
        require(_referrerID > 0 && _referrerID <= PoolcurrentID[1], "Incorrect referrer Id");
             
        PoolcurrentID[1]++;
        
        UserStruct memory userStruct;
        
        userStruct = UserStruct({
            currentPool: 1,
            user: msg.sender
        });

        poolusers[PoolcurrentID[1]] = userStruct;
        
        poolusers[PoolcurrentID[1]].pool[1].currentID = PoolcurrentID[1];
        poolusers[PoolcurrentID[1]].pool[1].referrerID = _referrerID;

        poolList[1][PoolcurrentID[1]] = msg.sender;
        
        poolusers[_referrerID].pool[1].referrals.push(PoolcurrentID[1]);
        
        levelStatus[msg.sender][1] = true;
        
        if(poolusers[_referrerID].pool[1].referrals.length < DOWNLINE_LIMIT) {
            uint amount = poolPrice[1]/2;
            
            require(address(uint160(ownerWallet)).send(amount) && address(uint160(poolList[1][_referrerID])).send(amount), "Owner wallet and referer transfer failed");  

            emit BuyPool(1, msg.sender, PoolcurrentID[1], poolList[1][_referrerID], _referrerID, amount, 0, now);
            emit JoinFee( msg.sender, PoolcurrentID[1], amount, now); 
        }    
        else {
            payForLevel(_referrerID , PoolcurrentID[1],  1, 1);
            poolusers[_referrerID].pool[1].referrals = new uint[](0);
            poolusers[_referrerID].pool[1].reinvestCount++;
        }
        return true; 
    }
    
    function buyPool(uint _pool, uint _referrerID) public payable returns (bool) {
        require(lockStatus == false, "Contract Locked");
        require(_pool > 1 && _pool <= 12, "Incorrect Pool");
        require(!levelStatus[msg.sender][_pool], "User exist");
        require(msg.value == poolPrice[_pool], "Incorrect value");
        require(_referrerID > 0 && _referrerID <= PoolcurrentID[_pool], "Incorrect referrer Id");
        
        require(levelStatus[msg.sender][_pool-1], "Buy Pool in sequence");
             
        PoolcurrentID[_pool]++;

        poolusers[PoolcurrentID[_pool]].currentPool = _pool;
        
        poolusers[PoolcurrentID[_pool]].pool[_pool].currentID = PoolcurrentID[_pool];
        poolusers[PoolcurrentID[_pool]].pool[_pool].referrerID = _referrerID;

        poolList[_pool][PoolcurrentID[_pool]] = msg.sender;
        
        poolusers[_referrerID].pool[_pool].referrals.push(PoolcurrentID[_pool]);
        
        levelStatus[msg.sender][_pool] = true;
        
        if(poolusers[_referrerID].pool[_pool].referrals.length < DOWNLINE_LIMIT) {
            payForLevel(_referrerID , PoolcurrentID[_pool],  _pool, 0);
        }    
        else {
           payForLevel(_referrerID , PoolcurrentID[_pool],  _pool, 1);
           poolusers[_referrerID].pool[_pool].referrals = new uint[](0);
           poolusers[_referrerID].pool[_pool].reinvestCount++;
        }
        return true; 
    }
    
    
    function payForLevel(uint _referrerID , uint _userID, uint _pool, uint _flag)internal {
        address referrer;
        if(_flag ==0)
            referrer = poolList[_pool][_referrerID];
        else
            referrer = ownerWallet;
        
        require(address(uint160(referrer)).send(poolPrice[_pool]), "Transfer Failed");
        
        emit BuyPool(_pool, msg.sender, _userID,  poolList[_pool][_referrerID], _referrerID, poolPrice[_pool], _flag, now);
    }
    
    function findFreeReferrer(uint _userID, uint8 _pool, uint _reInvestCount) public view returns(uint) {
        while (true) {
            
            if (poolusers[_userID].pool[_pool].reinvestCount < _reInvestCount) {
                return _userID;
            }
            
            _userID++;
        }
    }
    
    function failSafe(address payable _toUser, uint _amount) public returns (bool) {
        require(msg.sender == ownerWallet, "only Owner Wallet");
        require(_toUser != address(0), "Invalid Address");
        require(address(this).balance >= _amount, "Insufficient balance");

        (_toUser).transfer(_amount);
        return true;
    }
    
    function updatePrice(uint _pool, uint _price) public returns (bool) {
        require(msg.sender == ownerWallet, "only OwnerWallet");

        poolPrice[_pool] = _price;
        return true;
    }
    
    function contractLock(bool _lockStatus) public returns (bool) {
        require(msg.sender == ownerWallet, "Invalid User");

        lockStatus = _lockStatus;
        return true;
    }
    
    function userPool(uint _userID, uint8 _pool) public view returns(uint, uint, uint) {
        return (poolusers[_userID].pool[_pool].currentID,
                poolusers[_userID].pool[_pool].referrerID,
                poolusers[_userID].pool[_pool].reinvestCount);
    }
    
    
    function viewUserReferral(uint _pool, uint _userID) public view returns(uint[] memory) {
        return poolusers[_userID].pool[_pool].referrals;
    }

}
