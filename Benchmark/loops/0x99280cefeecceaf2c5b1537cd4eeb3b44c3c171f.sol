/**
 *Submitted for verification at Etherscan.io on 2019-10-23
*/

/**
 *  
 *  __                      _   __    __                               
 * / _\_ __ ___   __ _ _ __| |_/ / /\ \ \__ _ _   _   _ __ _   _ _ __  
 * \ \| '_ ` _ \ / _` | '__| __\ \/  \/ / _` | | | | | '__| | | | '_ \ 
 * _\ \ | | | | | (_| | |  | |_ \  /\  / (_| | |_| |_| |  | |_| | | | |
 * \__/_| |_| |_|\__,_|_|   \__| \/  \/ \__,_|\__, (_)_|   \__,_|_| |_|
 *                                            |___/                    
 * https://smartway.run/
 * 
**/

//pragma solidity 0.5.12;
pragma solidity >=0.5 <0.7.17;

contract SmartWay {

    struct User {
        uint64 id;
        uint64 referrerId;
        address payable[] referrals;
        mapping(uint8 => uint64) levelExpired;
    }

    uint8 public constant REFERRER_1_LEVEL_LIMIT = 2;
    uint64 public constant PERIOD_LENGTH = 12 days;

    address payable public ownerWallet;
    uint64 public lastUserId;
    
    mapping(uint8 => uint) public levelPrice;
    mapping(uint => uint8) public priceLevel;
    
    mapping(address => User) public users;
    mapping(uint64 => address payable) public userList;
    
    event Registration(address indexed user, address referrer);
    event LevelBought(address indexed user, uint8 level);
    event GetMoneyForLevel(address indexed user, address indexed referral, uint8 level);
    event SendMoneyError(address indexed user, address indexed referral, uint8 level);
    event LostMoneyForLevel(address indexed user, address indexed referral, uint8 level);

    constructor(address payable owner) public {
        _initData();
        ownerWallet = owner;

        lastUserId++;
        
        userList[lastUserId] = owner;
        users[owner].id = lastUserId;
        
        for(uint8 i = 1; i <= 12; i++) {
            users[owner].levelExpired[i] = 77777777777;
        }
    }

    function () external payable {
        uint8 level = priceLevel[msg.value];
        require(level != 0, 'Incorrect value sent');
        
        if(users[msg.sender].id != 0)
            return buyLevel(level);
        
        require(level == 1, 'Please buy level 1 for 0.2 ETH');
        
        address referrer = bytesToAddress(msg.data);

        if(users[referrer].id != 0)
            return regUser(users[referrer].id);

        regUser(1);
    }

    function regUser(uint64 referrerId) public payable {
        require(users[msg.sender].id == 0, 'User exist');
        require(referrerId > 0 && referrerId <= lastUserId, 'Incorrect referrer Id');
        require(msg.value == levelPrice[1], 'Incorrect Value');

        if(users[userList[referrerId]].referrals.length >= REFERRER_1_LEVEL_LIMIT) {
            address freeReferrer = findFreeReferrer(userList[referrerId]);
            referrerId = users[freeReferrer].id;
        }
            
        lastUserId++;

        users[msg.sender] = User({
            id: lastUserId,
            referrerId: referrerId,
            referrals: new address payable[](0) 
        });
        
        userList[lastUserId] = msg.sender;

        users[msg.sender].levelExpired[1] = uint64(now + PERIOD_LENGTH);

        users[userList[referrerId]].referrals.push(msg.sender);

        payForLevel(1, msg.sender);

        emit Registration(msg.sender, userList[referrerId]);
    }

    function buyLevel(uint8 level) public payable {
        require(users[msg.sender].id != 0, 'User is not exists'); 
        require(level > 0 && level <= 12, 'Incorrect level');
        require(msg.value == levelPrice[level], 'Incorrect Value');
    
        
        for(uint8 i = level - 1; i > 0; i--) {
            require(users[msg.sender].levelExpired[i] >= now, 'Buy the previous level');
        }
        
        if(users[msg.sender].levelExpired[level] == 0 || users[msg.sender].levelExpired[level] < now) {
            users[msg.sender].levelExpired[level] = uint64(now + PERIOD_LENGTH);
        } else {
            users[msg.sender].levelExpired[level] += PERIOD_LENGTH;
        }
        
        payForLevel(level, msg.sender);

        emit LevelBought(msg.sender, level);
    }
    

    function payForLevel(uint8 level, address user) private {
        address payable referrer;

        if (level%2 == 0) {
            referrer = userList[users[userList[users[user].referrerId]].referrerId]; //extra variable will decrease aroud 50 recursion levels
        } else {
            referrer = userList[users[user].referrerId];
        }

        if(users[referrer].id == 0) {
            referrer = userList[1];
        } 

        if(users[referrer].levelExpired[level] >= now) {
            if (referrer.send(levelPrice[level])) {
                emit GetMoneyForLevel(referrer, msg.sender, level);
            } else {
                emit SendMoneyError(referrer, msg.sender, level);
            }
        } else {
            emit LostMoneyForLevel(referrer, msg.sender, level);

            payForLevel(level, referrer);
        }
    }

    function _initData() private {
        levelPrice[1] = 0.2 ether;
        levelPrice[2] = 0.22 ether;
        levelPrice[3] = 0.4 ether;
        levelPrice[4] = 0.44 ether;
        levelPrice[5] = 0.7 ether;
        levelPrice[6] = 0.77 ether;
        levelPrice[7] = 1.2 ether;
        levelPrice[8] = 1.3 ether;
        levelPrice[9] = 2 ether;
        levelPrice[10] = 2.2 ether;
        levelPrice[11] = 3 ether;
        levelPrice[12] = 3.3 ether;

        priceLevel[0.2 ether] = 1;
        priceLevel[0.22 ether] = 2;
        priceLevel[0.4 ether] = 3;
        priceLevel[0.44 ether] = 4;
        priceLevel[0.7 ether] = 5;
        priceLevel[0.77 ether] = 6;
        priceLevel[1.2 ether] = 7;
        priceLevel[1.3 ether] = 8;
        priceLevel[2 ether] = 9;
        priceLevel[2.2 ether] = 10;
        priceLevel[3 ether] = 11;
        priceLevel[3.3 ether] = 12;
    }

    function findFreeReferrer(address _user) public view returns(address) {
        if(users[_user].referrals.length < REFERRER_1_LEVEL_LIMIT) 
            return _user;

        address[] memory referrals = new address[](256);
        address[] memory referralsBuf = new address[](256);

        referrals[0] = users[_user].referrals[0];
        referrals[1] = users[_user].referrals[1];

        uint32 j = 2;
        
        while(true) {
            for(uint32 i = 0; i < j; i++) {
                if(users[referrals[i]].referrals.length < 1) {
                    return referrals[i];
                }
            }
            
            for(uint32 i = 0; i < j; i++) {
                if (users[referrals[i]].referrals.length < REFERRER_1_LEVEL_LIMIT) {
                    return referrals[i];
                }
            }

            for(uint32 i = 0; i < j; i++) {
                referralsBuf[i] = users[referrals[i]].referrals[0];
                referralsBuf[j+i] = users[referrals[i]].referrals[1];
            }

            j = j*2;

            for(uint32 i = 0; i < j; i++) {
                referrals[i] = referralsBuf[i];
            }
        }
    }

    function viewUserReferral(address user) public view returns(address payable[] memory) {
        return users[user].referrals;
    }

    function viewUserLevelExpired(address user, uint8 level) public view returns(uint) {
        return users[user].levelExpired[level];
    }

    function bytesToAddress(bytes memory bys) private pure returns (address addr) {
        assembly {
            addr := mload(add(bys, 20))
        }
    }
}
