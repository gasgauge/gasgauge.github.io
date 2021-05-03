/**
 *Submitted for verification at Etherscan.io on 2020-09-19
*/

//pragma solidity 0.5.16;
pragma solidity >=0.5 <0.7.17;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }
    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}


contract EEEMoney{
    // SafeMath
    using SafeMath for uint;
    
    // User struct
    struct UserStruct {
        bool isExist;
        uint id;
        uint referrerID;
        uint totalEarnedETH;
        uint previousShare;
        uint sharesHoldings;
        uint directShare;
        uint referralShare;
        uint poolHoldings;
        uint created;
        address[] referral;
    }
    
    EEEMoney public oldEEEMoney1;
    EEEMoney public oldEEEMoney2;
    
    // Public variables
    address public ownerWallet;
    address public signature;
    uint public poolMoney;
    uint public qualifiedPoolHolding = 0.5 ether;
    uint public invest = 0.25 ether;
    uint public feePercentage = 5 ether; 
    uint public currUserID = 0;
    uint public qualify = 86400;
    bool public lockStatus;
    
    // Mapping
    mapping(address => UserStruct) public users;
    mapping (uint => address) public userList;
    
    // Events
    event regEvent(address indexed _user, address indexed _referrer, uint _time);
    event poolMoneyEvent(address indexed _user, uint _money, uint _time);
    event splitOverEvent(address indexed _user, uint _shareAmount, uint _userShares, uint _time);
    event userInversement(address indexed _user, uint _noOfShares, uint _amount, uint _time, uint investType);
    event userWalletTransferEvent(address indexed _user, uint _amount, uint _percentage, uint _gasFee, uint _time);
    event ownerWalletTransferEvent(address indexed _user, uint _percentage, uint _gasFee, uint _time);
    
    // On Deploy
    constructor()public{
        ownerWallet = msg.sender;
        
        oldEEEMoney1 = EEEMoney(0xE90606828f08FA31e97fC594EC549e6749732a90);
        oldEEEMoney2 = EEEMoney(0x6C9b9166EBb363339Ec0CC9951b1BB277a38BeC2);
        
        UserStruct memory userStruct;
        currUserID = oldEEEMoney2.currUserID();
        poolMoney = poolMoney.add(oldEEEMoney1.poolMoney());
        poolMoney = poolMoney.add(oldEEEMoney2.poolMoney());
        
        userStruct = UserStruct({
            isExist: true,
            id: 1,
            referrerID: 0,
            totalEarnedETH: 0,
            previousShare: 0,
            sharesHoldings: 0,
            directShare: 0,
            referralShare: 0,
            poolHoldings: 0,
            created:0,
            referral: new address[](0)
        });
        users[ownerWallet] = userStruct;
        userList[1] = ownerWallet;
    }
    

    function () external payable {
        require(msg.sender == ownerWallet,"Invalid wallet");
    }
    
    /**
     * @dev To register the User
     * @param _referrerID id of user/referrer 
     */
    function regUser(uint _referrerID) public payable returns(bool){
        require(
            lockStatus == false,
            "Contract is locked"
        );
        require(
            !users[msg.sender].isExist && !syncIsExist1(msg.sender) && !syncIsExist2(msg.sender),
            "User exist"
        );
        require(
            _referrerID > 0 && _referrerID <= currUserID,
            "Incorrect referrer Id"
        );
        require(
            msg.value == invest,
            "Incorrect Value"
        );
        
        uint32 size;
        
        address useraddress = msg.sender;
        
        assembly {
            size := extcodesize(useraddress)
        }
        
        require(size == 0, "cannot be a contract");
        
        UserStruct memory userStruct;
        currUserID++;

        userStruct = UserStruct({
            isExist: true,
            id: currUserID,
            referrerID: _referrerID,
            totalEarnedETH: 0,
            previousShare: 0,
            sharesHoldings: 1,
            directShare: 0,
            referralShare: 0,
            poolHoldings: 0,
            created:now.add(qualify),
            referral: new address[](0)
        });

        users[msg.sender] = userStruct;
        userList[currUserID] = msg.sender;
        
        address referer;
        
        if(_referrerID <= oldEEEMoney1.currUserID())
            referer = oldEEEMoney1.userList(_referrerID);
        else if(_referrerID <= oldEEEMoney2.currUserID())
            referer = oldEEEMoney2.userList(_referrerID);
        else    
            referer = userList[_referrerID];
            
        if(referer == oldEEEMoney1.ownerWallet())
            referer = ownerWallet;    
        
        users[referer].sharesHoldings = users[referer].sharesHoldings.add(1);
        users[referer].referralShare = users[referer].referralShare.add(1);
        users[referer].referral.push(msg.sender);
    
        uint _value = invest.div(2);
        
        
                
        require(
            address(uint160(referer)).send(_value),
            "Transaction failed"
        );
        
        users[referer].totalEarnedETH = users[referer].totalEarnedETH.add(_value);
        
        poolMoney = poolMoney.add(_value);
        
        emit poolMoneyEvent( msg.sender, _value, now);
        emit regEvent(msg.sender, referer, now);
        
        return true;
    }

    /**
     * @dev To invest on shares
     * @param _noOfShares No of shares 
     */
    function investOnShare(uint _noOfShares) public payable returns(bool){
        require(
            lockStatus == false,
            "Contract is locked"
        );
        
        require(
            msg.value == invest.mul(_noOfShares),
            "Incorrect Value"
        );
        
        require(users[msg.sender].isExist || syncIsExist1(msg.sender) || syncIsExist2(msg.sender),"User not exist");
        
        require(msg.sender != oldEEEMoney1.ownerWallet(), "old ownerWallet");
        
        uint32 size;
        
        address useraddress = msg.sender;
        
        assembly {
            size := extcodesize(useraddress)
        }
        
        require(size == 0, "cannot be a contract");
        
        uint _value = (msg.value).div(2);
        address _referer;
        
        uint referrerID = users[msg.sender].referrerID;
        
        if(referrerID == 0)
            referrerID = syncReferrerID2(msg.sender);
            
        if(referrerID == 0)
            referrerID = syncReferrerID1(msg.sender);
        
        
        _referer = userList[referrerID];
        
        if(_referer == address(0))
            _referer = oldEEEMoney2.userList(referrerID); 
            
        if(_referer == address(0))
            _referer = oldEEEMoney1.userList(referrerID);
        
        if((_referer == address(0)) || (_referer == oldEEEMoney1.ownerWallet()))
            _referer = ownerWallet;
            
        require(
            address(uint160(_referer)).send(_value),
            "Transaction failed"
        ); 
        
        users[_referer].totalEarnedETH = users[_referer].totalEarnedETH.add(_value);
        
        users[msg.sender].directShare = users[msg.sender].directShare.add(_noOfShares);
        users[msg.sender].sharesHoldings = users[msg.sender].sharesHoldings.add(_noOfShares);
        
        poolMoney = poolMoney.add(_value);
        
        emit poolMoneyEvent( msg.sender, _value, now);
        emit userInversement( msg.sender, _noOfShares, msg.value, now, 1);
        
        return true;
    }
    
    
    function shareWithdraw(address[] memory _userAddress, uint[] memory _shareAmount, uint [] memory _shares, uint _gasFee) public returns(bool){
        
        require(msg.sender == ownerWallet,"Only ownerWallet");
        
        require((_userAddress.length == _shareAmount.length) && (_userAddress.length == _shares.length),"invalid user length");
        
        for(uint i=0;i<_userAddress.length;i++){
        
            require(users[_userAddress[i]].isExist || syncIsExist1(_userAddress[i]) || syncIsExist2(_userAddress[i]),"User not exist");
            
            require(_userAddress[i] != oldEEEMoney1.ownerWallet(), "old contract ownerWallet");
            
            require(_shareAmount[i] >= qualifiedPoolHolding,"share amount is less than qualifed");
            
            require(address(this).balance/2 >= _shareAmount[i],"Insufficient balance");
            
            require(
                (users[_userAddress[i]].created < now) &&
                (syncUserCreated1(_userAddress[i]) < now) &&
                (syncUserCreated2(_userAddress[i]) < now),
                "user is not qualified to withdraw"
            );
            
            uint32 size;
            
            address _useradd = _userAddress[i]; 
            
            assembly {
                size := extcodesize(_useradd)
            }
            
            require(size == 0, "cannot be a contract");
            
            address _referer;
            
            uint referrerID = users[_useradd].referrerID;
            
            if(referrerID == 0)
                referrerID = syncReferrerID2(_useradd);
                
            if(referrerID == 0)
                referrerID = syncReferrerID1(_useradd);
            
            
            _referer = userList[referrerID];
            
            if(_referer == address(0))
                _referer = oldEEEMoney2.userList(referrerID); 
                
            if(_referer == address(0))
                _referer = oldEEEMoney1.userList(referrerID);
            
            if((_referer == address(0)) || (_referer == oldEEEMoney1.ownerWallet()))
                _referer = ownerWallet;
            
            uint _totalInvestingShare = _shareAmount[i].div(qualifiedPoolHolding);
            uint _referervalue = invest.div(2);
            uint _value = (_referervalue.mul(_totalInvestingShare));
            
            poolMoney = poolMoney.sub(_shareAmount[i]);
            
            users[_useradd].previousShare = users[_useradd].previousShare.add(_shares[i]);
            
            require(
                address(uint160(_referer)).send(_value),
                "re-inverset referer 50 percentage failed"
            );
            
            users[_referer].totalEarnedETH = users[_referer].totalEarnedETH.add(_value);
            
            users[_useradd].directShare = users[_useradd].directShare.add(_totalInvestingShare);
            users[_useradd].sharesHoldings = users[_useradd].sharesHoldings.add(_totalInvestingShare);
            
            poolMoney = poolMoney.add(_value);
            
            // wallet
            uint _walletAmount = invest.mul(_totalInvestingShare);
            uint _adminCommission = (_walletAmount.mul(feePercentage)).div(100 ether);
            
            _walletAmount = _walletAmount.sub(_adminCommission.add(_gasFee));
            
            require(
                address(uint160(_useradd)).send(_walletAmount) &&
                address(uint160(ownerWallet)).send(_adminCommission.add(_gasFee)),
                "user wallet transfer failed"
            );  
            
            
            emit splitOverEvent(_useradd, _shareAmount[i], _shares[i], now);
            emit userInversement( _useradd, _totalInvestingShare, invest.mul(_totalInvestingShare), now, 2);
            emit poolMoneyEvent( _useradd, _value, now);
            emit userWalletTransferEvent(_useradd, _walletAmount, _adminCommission, _gasFee, now);
            emit ownerWalletTransferEvent(_useradd, _adminCommission, _gasFee, now);
        }
        
        return true;
    }
    
    
    /**
     * @dev Contract balance withdraw
     * @param _toUser  receiver addrress
     * @param _amount  withdraw amount
     */ 
    function failSafe(address payable _toUser, uint _amount) public returns (bool) {
        require(msg.sender == ownerWallet, "Only Owner Wallet");
        require(_toUser != address(0), "Invalid Address");
        require(address(this).balance >= _amount, "Insufficient balance");

        (_toUser).transfer(_amount);
        return true;
    }

    /**
     * @dev To lock/unlock the contract
     * @param _lockStatus  status in bool
     */
    function contractLock(bool _lockStatus) public returns (bool) {
        require(msg.sender == ownerWallet, "Invalid ownerWallet");

        lockStatus = _lockStatus;
        return true;
    }
    
    function changeOwnerWallet(address _ownerWallet)public returns(bool){
        require(msg.sender == ownerWallet,"only ownerWallet");
        require(_ownerWallet != address(0),"invalid owner address");
        
        ownerWallet = _ownerWallet;
        
        UserStruct memory userStruct;
        
        userStruct = UserStruct({
            isExist: true,
            id: 1,
            referrerID: 0,
            totalEarnedETH: users[msg.sender].totalEarnedETH,
            previousShare: users[msg.sender].previousShare,
            sharesHoldings:  users[msg.sender].sharesHoldings,
            directShare: users[msg.sender].directShare,
            referralShare: users[msg.sender].referralShare,
            poolHoldings: users[msg.sender].poolHoldings,
            created:users[msg.sender].created,
            referral: new address[](0)
        });
        
        users[ownerWallet]= userStruct;
        userList[1] = ownerWallet;
        
        users[msg.sender].isExist = false;
        users[msg.sender].id = 0;
        users[msg.sender].sharesHoldings = 0;
        users[msg.sender].previousShare = 0;
        users[msg.sender].directShare = 0;
        users[msg.sender].referralShare = 0;
        users[msg.sender].totalEarnedETH = 0;
        
        for(uint i=0;i<users[msg.sender].referral.length;i++){
            users[ownerWallet].referral.push(users[msg.sender].referral[i]);
        }
        
        
        users[msg.sender].referral = new address[](0);
        
        return true;
    }
    
    
    // sync functions
    
    function syncIsExist1(address _user) public view  returns(bool){
        uint oldData;
        bool isExist;
        (isExist, 
            oldData, 
            oldData, 
            oldData,
            oldData,
            oldData,
            oldData,
            oldData,
            oldData,
            oldData) = 
            oldEEEMoney1.users(_user);
            
            return(isExist);
    }
    
    function syncIsExist2(address _user) public view  returns(bool){
        uint oldData;
        bool isExist;
        (isExist, 
            oldData, 
            oldData, 
            oldData,
            oldData,
            oldData,
            oldData,
            oldData,
            oldData,
            oldData) = 
            oldEEEMoney2.users(_user);
            
            return(isExist);
    }
    
    function syncID1(address _user) public view  returns(uint){
        uint oldData;
        bool isExist;
        uint ID;
        (isExist, 
            ID, 
            oldData, 
            oldData,
            oldData,
            oldData,
            oldData,
            oldData,
            oldData,
            oldData) = 
            oldEEEMoney1.users(_user);
            
            return(ID);
    }
    
    function syncID2(address _user) public view  returns(uint){
        uint oldData;
        bool isExist;
        uint ID;
        (isExist, 
            ID, 
            oldData, 
            oldData,
            oldData,
            oldData,
            oldData,
            oldData,
            oldData,
            oldData) = 
            oldEEEMoney2.users(_user);
            
            return(ID);
    }
    
    function syncUserCreated1(address _user) public view  returns(uint){
        uint oldData;
        uint created;
        bool isExist;
        (isExist, 
            oldData, 
            oldData, 
            oldData,
            oldData,
            oldData,
            oldData,
            oldData,
            oldData,
            created) = 
            oldEEEMoney1.users(_user);
            
            return(created);
    }
    
    function syncUserCreated2(address _user) public view  returns(uint){
        uint oldData;
        uint created;
        bool isExist;
        (isExist, 
            oldData, 
            oldData, 
            oldData,
            oldData,
            oldData,
            oldData,
            oldData,
            oldData,
            created) = 
            oldEEEMoney2.users(_user);
            
            return(created);
    }
    
    function syncReferrerID1(address _user) public view  returns(uint){
        uint oldData;
        uint RefID;
        bool isExist;
        (isExist, 
            oldData, 
            RefID, 
            oldData,
            oldData,
            oldData,
            oldData,
            oldData,
            oldData,
            oldData) = 
            oldEEEMoney1.users(_user);
            
            return RefID;
    }
    
    function syncReferrerID2(address _user) public view  returns(uint){
        uint oldData;
        uint RefID;
        bool isExist;
        (isExist, 
            oldData, 
            RefID, 
            oldData,
            oldData,
            oldData,
            oldData,
            oldData,
            oldData,
            oldData) = 
            oldEEEMoney2.users(_user);
            
            return RefID;
    }
    

    function syncTotalEarned1(address _user) public view  returns(uint){
        uint oldData;
        uint totalEth;
        bool isExist;
        (isExist, 
            oldData, 
            oldData, 
            totalEth,
            oldData,
            oldData,
            oldData,
            oldData,
            oldData,
            oldData) = 
            oldEEEMoney1.users(_user);
            
            return totalEth;
    }
    
    function syncTotalEarned2(address _user) public view  returns(uint){
        uint oldData;
        uint totalEth;
        bool isExist;
        (isExist, 
            oldData, 
            oldData, 
            totalEth,
            oldData,
            oldData,
            oldData,
            oldData,
            oldData,
            oldData) = 
            oldEEEMoney2.users(_user);
            
            return totalEth;
    }
    
    
     function getTotalEarnedEther() public view returns(uint) {
        uint totalEth;
        
        for( uint _userIndex=1;_userIndex<= currUserID;_userIndex++) {
            address user = userList[_userIndex];
            if(user == address(0))
                user = oldEEEMoney1.userList(_userIndex);
            
            if(user == address(0))
                user = oldEEEMoney2.userList(_userIndex);
                
            totalEth = totalEth.add((syncTotalEarned1(user).add(syncTotalEarned2(user))).add(users[user].totalEarnedETH));
        }
        
        return totalEth;
    }
    
    /**
     * @dev To view the referrals
     * @param _user  User address
     */ 
    function viewUserReferral(address _user) public view returns(address[] memory) {
        return users[_user].referral;
    }
    
    
    function syncRefferrals(address _user)public view returns(address[] memory,address[] memory,address[] memory){
        return(users[_user].referral,oldEEEMoney1.viewUserReferral(_user),oldEEEMoney2.viewUserReferral(_user));
    }
    
    
    
}
