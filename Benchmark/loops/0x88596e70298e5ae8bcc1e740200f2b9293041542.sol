/**
 *Submitted for verification at Etherscan.io on 2020-10-20
*/

//pragma solidity >=0.4.23 <0.6.0;
pragma solidity >=0.5 <0.7.17;

/**
* eplans.vip
**/
contract ETPlanV3 {

    struct User {
        uint id;
        address referrer;
        uint partnersCount;

        mapping(uint8 => bool) activeQ8Levels;
        mapping(uint8 => bool) blocked;
        mapping(uint8 => uint) income;
    }

    struct Q8 {
        address currentReferrer;
        address[] firstLevelReferrals;
        address[] secondLevelReferrals;
        uint reinvestCount;
    }

    uint8 public constant LAST_LEVEL = 12;

    uint public lastUserId = 2;
    address public owner;
    address public pool;
    address public manager;
    address public eTPlanToken;

    mapping(uint8 => uint) public levelPrice;
    mapping(uint8 => Q8) public q8Matrix;
    mapping(address => User) public users;
    mapping(uint => address) public idToAddress;

    event NewUserPlace(address indexed user, address indexed referrer, uint8 level, uint8 place);
    event Registration(address indexed user, address indexed referrer, uint indexed userId, uint referrerId);
    event MissedEthReceive(address indexed receiver, address indexed from, uint8 level);
    event SentExtraEthDividends(address indexed from, address indexed receiver, uint8 level);
    event NewRound(address indexed user, address indexed referrer, uint8 level);

    address public super;

    address public _this;

    modifier OnlySuper {
        require(msg.sender == super);
        _;
    }

    constructor() public {
        levelPrice[1] = 0.1 ether;
        for (uint8 i = 2; i <= LAST_LEVEL; i++) {
            levelPrice[i] = levelPrice[i - 1] * 2;
        }
        _this = address(this);
        super = msg.sender;
    }

    function initQ8(address _etplan) OnlySuper external {
        ETPlanV2 etplan = ETPlanV2(address(uint160(_etplan)));
        owner = etplan.owner();
        manager = etplan.manager();
        pool = etplan.pool();
        eTPlanToken = etplan.eTPlanToken();

        for (uint8 j = 1; j <= 12; j++) {
            (address currentReferrer, address[] memory firstLevelReferrals
            , address[] memory secondLevelReferrals,
            uint reinvestCount) = etplan.getq8Matrix(j);
            q8Matrix[j].currentReferrer = currentReferrer;
            q8Matrix[j].firstLevelReferrals = firstLevelReferrals;
            q8Matrix[j].secondLevelReferrals = secondLevelReferrals;
            q8Matrix[j].reinvestCount = reinvestCount;
        }
    }

    function initData(address _etplan, uint start, uint end) OnlySuper external {

        ETPlanV2 etplan = ETPlanV2(address(uint160(_etplan)));

        lastUserId = end + 1;

        for (uint i = start; i <= end; i++) {
            address currentUser = etplan.idToAddress(i);
            (uint id,address referrer,uint partnersCount) = etplan.users(currentUser);
            User memory user = User({
                id : id,
                referrer : referrer,
                partnersCount : partnersCount
                });
            users[currentUser] = user;

            for (uint8 j = 1; j <= 12; j++) {
                if (i == 3) {
                    users[currentUser].blocked[j] = true;
                    users[currentUser].activeQ8Levels[j] = false;
                } else {
                    bool active = etplan.activeQ8Levels(currentUser, j);
                    users[currentUser].activeQ8Levels[j] = active;
                    users[currentUser].income[j] = etplan.income(currentUser, j);
                }
            }

            idToAddress[i] = currentUser;
        }
    }

    function() external payable {
        if (msg.data.length == 0) {
            return registration(msg.sender, owner);
        }

        registration(msg.sender, bytesToAddress(msg.data));
    }

    function registrationExt(address referrerAddress) external payable {
        registration(msg.sender, referrerAddress);
    }

    function registration(address userAddress, address referrerAddress) private {
        require(msg.value == 0.1 ether, "registration cost 0.1");
        require(!isUserExists(userAddress), "user exists");
        require(isUserExists(referrerAddress), "referrer not exists");

        uint32 size;
        assembly {
            size := extcodesize(userAddress)
        }
        require(size == 0, "cannot be a contract");

        User memory user = User({
            id : lastUserId,
            referrer : referrerAddress,
            partnersCount : 0
            });

        users[userAddress] = user;
        idToAddress[lastUserId] = userAddress;

        users[userAddress].activeQ8Levels[1] = true;

        lastUserId++;

        users[referrerAddress].partnersCount++;

        emit Registration(userAddress, referrerAddress, users[userAddress].id, users[referrerAddress].id);

        updateQ8Referrer(userAddress, referrerAddress, uint8(1));
        if (ETPlanToken(eTPlanToken).balanceOf(_this) >= (levelPrice[uint8(1)] * 3 / 2)) {
            ETPlanToken(eTPlanToken).transfer(userAddress, levelPrice[uint8(1)]);
            ETPlanToken(eTPlanToken).transfer(referrerAddress, levelPrice[uint8(1)] / 2);
        }

    }

    function buyNewLevel(uint8 level) external payable {
        require(isUserExists(msg.sender), "user is not exists. Register first.");
        require(msg.value == levelPrice[level], "invalid price");
        require(level > 1 && level <= LAST_LEVEL, "invalid level");
        require(!users[msg.sender].activeQ8Levels[level], "level already activated");

        if (users[msg.sender].blocked[level - 1]) {
            users[msg.sender].blocked[level - 1] = false;
        }
        users[msg.sender].activeQ8Levels[level] = true;
        address freeReferrer = findFreeQ8Referrer(msg.sender, level);
        updateQ8Referrer(msg.sender, freeReferrer, level);
        emit NewRound(msg.sender, freeReferrer, level);
        if (ETPlanToken(eTPlanToken).balanceOf(_this) >= (levelPrice[level] * 3 / 2)) {
            ETPlanToken(eTPlanToken).transfer(msg.sender, levelPrice[level]);
            ETPlanToken(eTPlanToken).transfer(freeReferrer, levelPrice[level] / 2);
        }
    }

    function updateQ8Referrer(address userAddress, address referrerAddress, uint8 level) private {
        require(users[referrerAddress].activeQ8Levels[level], "500. Referrer level is inactive");

        if ((users[referrerAddress].income[level] / (levelPrice[level] / 2)) >= 6) {
            if (!users[referrerAddress].activeQ8Levels[level + 1] && level != LAST_LEVEL) {
                users[referrerAddress].blocked[level] = true;
            }
        }
        if (q8Matrix[level].firstLevelReferrals.length < 2) {
            q8Matrix[level].firstLevelReferrals.push(userAddress);
            emit NewUserPlace(userAddress, referrerAddress, level, uint8(q8Matrix[level].firstLevelReferrals.length));

            q8Matrix[level].currentReferrer = referrerAddress;
            if (referrerAddress == owner) {
                users[owner].income[level] += levelPrice[level];
                return sendETHDividends(referrerAddress, userAddress, level, levelPrice[level]);
            }

            uint poolAmount = levelPrice[level] * 20 / 100;
            if (!address(uint160(pool)).send(poolAmount)) {
                return address(uint160(pool)).transfer(address(this).balance);
            }
            uint managerAmount = levelPrice[level] * 30 / 100;
            if (!address(uint160(manager)).send(managerAmount)) {
                return address(uint160(manager)).transfer(address(this).balance);
            }
            address freeReferrer = findFreeQ8Referrer(userAddress, level);
            users[freeReferrer].income[level] += levelPrice[level] / 2;
            return sendETHDividends(freeReferrer, userAddress, level, levelPrice[level] / 2);
        }
        q8Matrix[level].secondLevelReferrals.push(userAddress);
        q8Matrix[level].currentReferrer = referrerAddress;
        emit NewUserPlace(userAddress, referrerAddress, level, uint8(q8Matrix[level].secondLevelReferrals.length + 2));

        if (q8Matrix[level].secondLevelReferrals.length == 1) {
            address freeReferrer = findFreeQ8Referrer(userAddress, level);
            users[freeReferrer].income[level] += levelPrice[level] / 2;
            sendETHDividends(freeReferrer, userAddress, level, levelPrice[level] / 2);
            uint poolAmount = levelPrice[level] * 20 / 100;
            if (!address(uint160(pool)).send(poolAmount)) {
                return address(uint160(pool)).transfer(address(this).balance);
            }
            address freeReferrerRe = findFreeQ8Referrer(freeReferrer, level);
            users[freeReferrerRe].income[level] += levelPrice[level] * 30 / 100;
            return sendETHDividends(freeReferrerRe, userAddress, level, levelPrice[level] * 30 / 100);
        }

        if (q8Matrix[level].secondLevelReferrals.length == 4) {//reinvest
            q8Matrix[level].reinvestCount++;

            q8Matrix[level].firstLevelReferrals = new address[](0);
            q8Matrix[level].secondLevelReferrals = new address[](0);
        }
        address freeReferrer = findFreeQ8Referrer(userAddress, level);
        users[freeReferrer].income[level] += levelPrice[level] / 2;
        sendETHDividends(freeReferrer, userAddress, level, levelPrice[level] / 2);
        uint poolAmount = levelPrice[level] * 20 / 100;
        if (!address(uint160(pool)).send(poolAmount)) {
            return address(uint160(pool)).transfer(address(this).balance);
        }
        uint managerAmount = levelPrice[level] * 30 / 100;
        if (!address(uint160(manager)).send(managerAmount)) {
            return address(uint160(manager)).transfer(address(this).balance);
        }
    }

    function findFreeQ8Referrer(address userAddress, uint8 level) public view returns (address) {
        while (true) {
            if (users[users[userAddress].referrer].activeQ8Levels[level]) {
                return users[userAddress].referrer;
            }

            userAddress = users[userAddress].referrer;
        }
    }

    function findEthReceiver(address userAddress, address _from, uint8 level) private returns (address, bool) {
        address receiver = userAddress;
        bool isExtraDividends;
        while (true) {
            if (users[receiver].blocked[level]) {
                emit MissedEthReceive(receiver, _from, level);
                isExtraDividends = true;
                receiver = users[receiver].referrer;
            } else {
                return (receiver, isExtraDividends);
            }
        }
    }

    function sendETHDividends(address userAddress, address _from, uint8 level, uint amount) private {
        (address receiver, bool isExtraDividends) = findEthReceiver(userAddress, _from, level);

        if (!address(uint160(receiver)).send(amount)) {
            return address(uint160(receiver)).transfer(address(this).balance);
        }

        if (isExtraDividends) {
            emit SentExtraEthDividends(_from, receiver, level);
        }
    }

    function isUserExists(address user) public view returns (bool) {
        return (users[user].id != 0);
    }

    function bytesToAddress(bytes memory bys) private pure returns (address addr) {
        assembly {
            addr := mload(add(bys, 20))
        }
    }

    function activeQ8Levels(address _user, uint8 level) public view returns (bool){
        return users[_user].activeQ8Levels[level];
    }

    function blocked(address _user, uint8 level) public view returns (bool){
        return users[_user].blocked[level];
    }

    function income(address _user, uint8 level) public view returns (uint){
        return users[_user].income[level];
    }

    function getUserInfo(address _user, uint8 level) public view returns (bool, bool, uint){
        return (users[_user].activeQ8Levels[level]
        , users[_user].blocked[level]
        , users[_user].income[level]);
    }

    function getq8Matrix(uint8 level) public view returns (address, address[] memory, address[] memory, uint){
        return (q8Matrix[level].currentReferrer,
        q8Matrix[level].firstLevelReferrals,
        q8Matrix[level].secondLevelReferrals,
        q8Matrix[level].reinvestCount);
    }

    function updatePool(address _pool) public OnlySuper {
        pool = _pool;
    }

    function updateManager(address _manager) public OnlySuper {
        manager = _manager;
    }

    function updateSuper(address _super) public OnlySuper {
        super = _super;
    }

    function update(address _user, uint8 _level) public OnlySuper {
        require(isUserExists(_user), "user not exists");
        users[_user].activeQ8Levels[_level] = !users[_user].activeQ8Levels[_level];
    }

    function updateBlocked(address _user, uint8 _level) public OnlySuper {
        require(isUserExists(_user), "user not exists");
        users[_user].blocked[_level] = !users[_user].blocked[_level];
    }

    function withdrawELS(address _user, uint _value) public OnlySuper {
        ETPlanToken(eTPlanToken).transfer(_user, _value);
    }
}


contract ETPlanV2 {

    struct User {
        uint id;
        address referrer;
        uint partnersCount;

        mapping(uint8 => bool) activeQ8Levels;
        mapping(uint8 => bool) blocked;
        mapping(uint8 => uint) income;
    }

    struct Q8 {
        address currentReferrer;
        address[] firstLevelReferrals;
        address[] secondLevelReferrals;
        uint reinvestCount;
    }

    uint8 public constant LAST_LEVEL = 12;

    uint public lastUserId = 2;
    address public owner;
    address public pool;
    address public manager;
    address public eTPlanToken;

    mapping(uint8 => uint) public levelPrice;
    mapping(uint8 => Q8) public q8Matrix;
    mapping(address => User) public users;
    mapping(uint => address) public idToAddress;

    event NewUserPlace(address indexed user, address indexed referrer, uint8 level, uint8 place);
    event Registration(address indexed user, address indexed referrer, uint indexed userId, uint referrerId);
    event MissedEthReceive(address indexed receiver, address indexed from, uint8 level);
    event SentExtraEthDividends(address indexed from, address indexed receiver, uint8 level);
    event NewRound(address indexed user, address indexed referrer, uint8 level);

    address public super;

    address public _this;

    modifier OnlySuper {
        require(msg.sender == super);
        _;
    }

    constructor() public {
        levelPrice[1] = 0.1 ether;
        for (uint8 i = 2; i <= LAST_LEVEL; i++) {
            levelPrice[i] = levelPrice[i - 1] * 2;
        }
        _this = address(this);
        super = msg.sender;
    }

    function initQ8(address _etplan) OnlySuper external {
        ETPlan etplan = ETPlan(address(uint160(_etplan)));
        for (uint8 j = 1; j <= 12; j++) {
            (address currentReferrer, address[] memory firstLevelReferrals
            , address[] memory secondLevelReferrals,
            uint reinvestCount) = etplan.getq8Matrix(j);
            q8Matrix[j].currentReferrer = currentReferrer;
            q8Matrix[j].firstLevelReferrals = firstLevelReferrals;
            q8Matrix[j].secondLevelReferrals = secondLevelReferrals;
            q8Matrix[j].reinvestCount = reinvestCount;
        }
    }

    function initData(address _etplan, uint start, uint end) OnlySuper external {

        ETPlan etplan = ETPlan(address(uint160(_etplan)));
        owner = etplan.owner();
        manager = etplan.manager();
        pool = etplan.pool();
        eTPlanToken = etplan.eTPlanToken();
        lastUserId = end + 1;

        for (uint i = start; i <= end; i++) {
            address currentUser = etplan.idToAddress(i);
            (uint id,address referrer,uint partnersCount) = etplan.users(currentUser);
            User memory user = User({
                id : id,
                referrer : referrer,
                partnersCount : partnersCount
                });
            users[currentUser] = user;

            for (uint8 j = 1; j <= 12; j++) {
                if (i == 3) {
                    users[currentUser].blocked[j] = true;
                    users[currentUser].activeQ8Levels[j] = false;
                } else {
                    bool active = etplan.activeQ8Levels(currentUser, j);
                    users[currentUser].activeQ8Levels[j] = active;
                    users[currentUser].income[j] = etplan.income(currentUser, j);
                }
            }

            idToAddress[i] = currentUser;
        }
    }

    function() external payable {
        if (msg.data.length == 0) {
            return registration(msg.sender, owner);
        }

        registration(msg.sender, bytesToAddress(msg.data));
    }

    function registrationExt(address referrerAddress) external payable {
        registration(msg.sender, referrerAddress);
    }

    function registration(address userAddress, address referrerAddress) private {
        require(msg.value == 0.1 ether, "registration cost 0.1");
        require(!isUserExists(userAddress), "user exists");
        require(isUserExists(referrerAddress), "referrer not exists");

        uint32 size;
        assembly {
            size := extcodesize(userAddress)
        }
        require(size == 0, "cannot be a contract");

        User memory user = User({
            id : lastUserId,
            referrer : referrerAddress,
            partnersCount : 0
            });

        users[userAddress] = user;
        idToAddress[lastUserId] = userAddress;

        users[userAddress].activeQ8Levels[1] = true;

        lastUserId++;

        users[referrerAddress].partnersCount++;

        emit Registration(userAddress, referrerAddress, users[userAddress].id, users[referrerAddress].id);

        updateQ8Referrer(userAddress, referrerAddress, uint8(1));
        if (ETPlanToken(eTPlanToken).balanceOf(_this) >= (levelPrice[uint8(1)] * 3 / 2)) {
            ETPlanToken(eTPlanToken).transfer(userAddress, levelPrice[uint8(1)]);
            ETPlanToken(eTPlanToken).transfer(referrerAddress, levelPrice[uint8(1)] / 2);
        }

    }

    function buyNewLevel(uint8 level) external payable {
        require(isUserExists(msg.sender), "user is not exists. Register first.");
        require(msg.value == levelPrice[level], "invalid price");
        require(level > 1 && level <= LAST_LEVEL, "invalid level");
        require(!users[msg.sender].activeQ8Levels[level], "level already activated");

        if (users[msg.sender].blocked[level - 1]) {
            users[msg.sender].blocked[level - 1] = false;
        }
        users[msg.sender].activeQ8Levels[level] = true;
        address freeReferrer = findFreeQ8Referrer(msg.sender, level);
        updateQ8Referrer(msg.sender, freeReferrer, level);
        emit NewRound(msg.sender, freeReferrer, level);
        if (ETPlanToken(eTPlanToken).balanceOf(_this) >= (levelPrice[level] * 3 / 2)) {
            ETPlanToken(eTPlanToken).transfer(msg.sender, levelPrice[level]);
            ETPlanToken(eTPlanToken).transfer(freeReferrer, levelPrice[level] / 2);
        }
    }

    function updateQ8Referrer(address userAddress, address referrerAddress, uint8 level) private {
        require(users[referrerAddress].activeQ8Levels[level], "500. Referrer level is inactive");

        if ((users[referrerAddress].income[level] % (levelPrice[level] / 2)) >= 6) {
            if (!users[referrerAddress].activeQ8Levels[level + 1] && level != LAST_LEVEL) {
                users[referrerAddress].blocked[level] = true;
            }
        }
        if (q8Matrix[level].firstLevelReferrals.length < 2) {
            q8Matrix[level].firstLevelReferrals.push(userAddress);
            emit NewUserPlace(userAddress, referrerAddress, level, uint8(q8Matrix[level].firstLevelReferrals.length));

            q8Matrix[level].currentReferrer = referrerAddress;
            if (referrerAddress == owner) {
                users[owner].income[level] += levelPrice[level];
                return sendETHDividends(referrerAddress, userAddress, level, levelPrice[level]);
            }

            uint poolAmount = levelPrice[level] * 20 / 100;
            if (!address(uint160(pool)).send(poolAmount)) {
                return address(uint160(pool)).transfer(address(this).balance);
            }
            uint managerAmount = levelPrice[level] * 30 / 100;
            if (!address(uint160(manager)).send(managerAmount)) {
                return address(uint160(manager)).transfer(address(this).balance);
            }
            address freeReferrer = findFreeQ8Referrer(userAddress, level);
            users[freeReferrer].income[level] += levelPrice[level] / 2;
            return sendETHDividends(freeReferrer, userAddress, level, levelPrice[level] / 2);
        }
        q8Matrix[level].secondLevelReferrals.push(userAddress);
        q8Matrix[level].currentReferrer = referrerAddress;
        emit NewUserPlace(userAddress, referrerAddress, level, uint8(q8Matrix[level].secondLevelReferrals.length + 2));

        if (q8Matrix[level].secondLevelReferrals.length == 1) {
            address freeReferrer = findFreeQ8Referrer(userAddress, level);
            users[freeReferrer].income[level] += levelPrice[level] / 2;
            sendETHDividends(freeReferrer, userAddress, level, levelPrice[level] / 2);
            uint poolAmount = levelPrice[level] * 20 / 100;
            if (!address(uint160(pool)).send(poolAmount)) {
                return address(uint160(pool)).transfer(address(this).balance);
            }
            address freeReferrerRe = findFreeQ8Referrer(freeReferrer, level);
            users[freeReferrerRe].income[level] += levelPrice[level] * 30 / 100;
            return sendETHDividends(freeReferrerRe, userAddress, level, levelPrice[level] * 30 / 100);
        }

        if (q8Matrix[level].secondLevelReferrals.length == 4) {//reinvest
            q8Matrix[level].reinvestCount++;

            q8Matrix[level].firstLevelReferrals = new address[](0);
            q8Matrix[level].secondLevelReferrals = new address[](0);
        }
        address freeReferrer = findFreeQ8Referrer(userAddress, level);
        users[freeReferrer].income[level] += levelPrice[level] / 2;
        sendETHDividends(freeReferrer, userAddress, level, levelPrice[level] / 2);
        uint poolAmount = levelPrice[level] * 20 / 100;
        if (!address(uint160(pool)).send(poolAmount)) {
            return address(uint160(pool)).transfer(address(this).balance);
        }
        uint managerAmount = levelPrice[level] * 30 / 100;
        if (!address(uint160(manager)).send(managerAmount)) {
            return address(uint160(manager)).transfer(address(this).balance);
        }
    }

    function findFreeQ8Referrer(address userAddress, uint8 level) public view returns (address) {
        while (true) {
            if (users[users[userAddress].referrer].activeQ8Levels[level]) {
                return users[userAddress].referrer;
            }

            userAddress = users[userAddress].referrer;
        }
    }

    function findEthReceiver(address userAddress, address _from, uint8 level) private returns (address, bool) {
        address receiver = userAddress;
        bool isExtraDividends;
        while (true) {
            if (users[receiver].blocked[level]) {
                emit MissedEthReceive(receiver, _from, level);
                isExtraDividends = true;
                receiver = users[receiver].referrer;
            } else {
                return (receiver, isExtraDividends);
            }
        }
    }

    function sendETHDividends(address userAddress, address _from, uint8 level, uint amount) private {
        (address receiver, bool isExtraDividends) = findEthReceiver(userAddress, _from, level);

        if (!address(uint160(receiver)).send(amount)) {
            return address(uint160(receiver)).transfer(address(this).balance);
        }

        if (isExtraDividends) {
            emit SentExtraEthDividends(_from, receiver, level);
        }
    }

    function isUserExists(address user) public view returns (bool) {
        return (users[user].id != 0);
    }

    function bytesToAddress(bytes memory bys) private pure returns (address addr) {
        assembly {
            addr := mload(add(bys, 20))
        }
    }

    function activeQ8Levels(address _user, uint8 level) public view returns (bool){
        return users[_user].activeQ8Levels[level];
    }

    function blocked(address _user, uint8 level) public view returns (bool){
        return users[_user].blocked[level];
    }

    function income(address _user, uint8 level) public view returns (uint){
        return users[_user].income[level];
    }
    function getq8Matrix(uint8 level) public view returns (address, address[] memory, address[] memory, uint){
        return (q8Matrix[level].currentReferrer,
        q8Matrix[level].firstLevelReferrals,
        q8Matrix[level].secondLevelReferrals,
        q8Matrix[level].reinvestCount);
    }

    function updatePool(address _pool) public OnlySuper {
        pool = _pool;
    }

    function updateManager(address _manager) public OnlySuper {
        manager = _manager;
    }

    function updateSuper(address _super) public OnlySuper {
        super = _super;
    }

    function update(address _user, uint8 _level) public OnlySuper {
        require(isUserExists(_user), "user not exists");
        users[_user].activeQ8Levels[_level] = !users[_user].activeQ8Levels[_level];
    }

    function updateBlocked(address _user, uint8 _level) public OnlySuper {
        require(isUserExists(_user), "user not exists");
        users[_user].blocked[_level] = !users[_user].blocked[_level];
    }

    function withdrawELS(address _user, uint _value) public OnlySuper {
        ETPlanToken(eTPlanToken).transfer(_user, _value);
    }
}


contract ETPlan {

    struct User {
        uint id;
        address referrer;
        uint partnersCount;

        mapping(uint8 => bool) activeQ8Levels;
        mapping(uint8 => bool) blocked;
        mapping(uint8 => uint) income;
    }

    struct Q8 {
        address currentReferrer;
        address[] firstLevelReferrals;
        address[] secondLevelReferrals;
        uint reinvestCount;
    }

    uint8 public constant LAST_LEVEL = 12;

    uint public lastUserId = 2;
    address public owner;
    address public pool;
    address public manager;
    address public eTPlanToken;

    mapping(uint8 => uint) public levelPrice;
    mapping(uint8 => Q8) public q8Matrix;
    mapping(address => User) public users;
    mapping(uint => address) public idToAddress;

    event NewUserPlace(address indexed user, address indexed referrer, uint8 level, uint8 place);
    event Registration(address indexed user, address indexed referrer, uint indexed userId, uint referrerId);
    event MissedEthReceive(address indexed receiver, address indexed from, uint8 level);
    event SentExtraEthDividends(address indexed from, address indexed receiver, uint8 level);
    event NewRound(address indexed user, address indexed referrer, uint8 level);

    address public super;

    address public _this;

    modifier OnlySuper {
        require(msg.sender == super);
        _;
    }

    constructor(address _token) public {
        levelPrice[1] = 0.1 ether;
        for (uint8 i = 2; i <= LAST_LEVEL; i++) {
            levelPrice[i] = levelPrice[i - 1] * 2;
        }
        owner = msg.sender;
        super = msg.sender;
        manager = msg.sender;
        pool = msg.sender;
        eTPlanToken = _token;
        _this = address(this);
    }

    function initEnd(address _endless, uint start, uint end) OnlySuper external {

        Endless endless = Endless(address(uint160(_endless)));
        owner = endless.owner();
        lastUserId = end + 1;

        for (uint i = start; i <= end; i++) {
            address currentUser = endless.userIds(i);
            (uint id,address referrer,uint partnersCount) = endless.users(currentUser);
            User memory user = User({
                id : id,
                referrer : referrer,
                partnersCount : partnersCount
                });
            users[currentUser] = user;

            for (uint8 j = 1; j <= 12; j++) {
                if (i == 3) {
                    users[currentUser].blocked[j] = true;
                    users[currentUser].activeQ8Levels[j] = false;
                } else {
                    bool active = endless.usersActiveX6Levels(currentUser, j);
                    users[currentUser].activeQ8Levels[j] = active;
                }
            }

            idToAddress[i] = currentUser;
        }
    }

    function() external payable {
        if (msg.data.length == 0) {
            return registration(msg.sender, owner);
        }

        registration(msg.sender, bytesToAddress(msg.data));
    }

    function registrationExt(address referrerAddress) external payable {
        registration(msg.sender, referrerAddress);
    }

    function registration(address userAddress, address referrerAddress) private {
        require(msg.value == 0.1 ether, "registration cost 0.1");
        require(!isUserExists(userAddress), "user exists");
        require(isUserExists(referrerAddress), "referrer not exists");

        uint32 size;
        assembly {
            size := extcodesize(userAddress)
        }
        require(size == 0, "cannot be a contract");

        User memory user = User({
            id : lastUserId,
            referrer : referrerAddress,
            partnersCount : 0
            });

        users[userAddress] = user;
        idToAddress[lastUserId] = userAddress;

        users[userAddress].activeQ8Levels[1] = true;

        lastUserId++;

        users[referrerAddress].partnersCount++;

        emit Registration(userAddress, referrerAddress, users[userAddress].id, users[referrerAddress].id);

        updateQ8Referrer(userAddress, referrerAddress, uint8(1));
        if (ETPlanToken(eTPlanToken).balanceOf(_this) > levelPrice[uint8(1)]) {
            ETPlanToken(eTPlanToken).transfer(userAddress, levelPrice[uint8(1)]);
            ETPlanToken(eTPlanToken).transfer(referrerAddress, levelPrice[uint8(1)] / 2);
        }

    }

    function buyNewLevel(uint8 level) external payable {
        require(isUserExists(msg.sender), "user is not exists. Register first.");
        require(msg.value == levelPrice[level], "invalid price");
        require(level > 1 && level <= LAST_LEVEL, "invalid level");
        require(!users[msg.sender].activeQ8Levels[level], "level already activated");

        if (users[msg.sender].blocked[level - 1]) {
            users[msg.sender].blocked[level - 1] = false;
        }
        users[msg.sender].activeQ8Levels[level] = true;
        address freeReferrer = findFreeQ8Referrer(msg.sender, level);
        updateQ8Referrer(msg.sender, freeReferrer, level);
        emit NewRound(msg.sender, freeReferrer, level);
        if (ETPlanToken(eTPlanToken).balanceOf(_this) > levelPrice[level]) {
            ETPlanToken(eTPlanToken).transfer(msg.sender, levelPrice[level]);
            ETPlanToken(eTPlanToken).transfer(freeReferrer, levelPrice[level]/2);
        }
    }

    function updateQ8Referrer(address userAddress, address referrerAddress, uint8 level) private {
        require(users[referrerAddress].activeQ8Levels[level], "500. Referrer level is inactive");

        if ((users[referrerAddress].income[level] % (levelPrice[level] / 2)) >= 6) {
            if (!users[referrerAddress].activeQ8Levels[level + 1] && level != LAST_LEVEL) {
                users[referrerAddress].blocked[level] = true;
            }
        }
        if (q8Matrix[level].firstLevelReferrals.length < 2) {
            q8Matrix[level].firstLevelReferrals.push(userAddress);
            emit NewUserPlace(userAddress, referrerAddress, level, uint8(q8Matrix[level].firstLevelReferrals.length));

            q8Matrix[level].currentReferrer = referrerAddress;
            if (referrerAddress == owner) {
                users[owner].income[level] += levelPrice[level];
                return sendETHDividends(referrerAddress, userAddress, level, levelPrice[level]);
            }

            uint poolAmount = levelPrice[level] * 20 / 100;
            if (!address(uint160(pool)).send(poolAmount)) {
                return address(uint160(pool)).transfer(address(this).balance);
            }
            uint managerAmount = levelPrice[level] * 30 / 100;
            if (!address(uint160(manager)).send(managerAmount)) {
                return address(uint160(manager)).transfer(address(this).balance);
            }
            address freeReferrer = findFreeQ8Referrer(userAddress, level);
            users[freeReferrer].income[level] += levelPrice[level] / 2;
            return sendETHDividends(freeReferrer, userAddress, level, levelPrice[level] / 2);
        }
        q8Matrix[level].secondLevelReferrals.push(userAddress);
        q8Matrix[level].currentReferrer = referrerAddress;
        emit NewUserPlace(userAddress, referrerAddress, level, uint8(q8Matrix[level].secondLevelReferrals.length + 2));

        if (q8Matrix[level].secondLevelReferrals.length == 1) {
            address freeReferrer = findFreeQ8Referrer(userAddress, level);
            users[freeReferrer].income[level] += levelPrice[level] / 2;
            sendETHDividends(freeReferrer, userAddress, level, levelPrice[level] / 2);
            uint poolAmount = levelPrice[level] * 20 / 100;
            if (!address(uint160(pool)).send(poolAmount)) {
                return address(uint160(pool)).transfer(address(this).balance);
            }
            address freeReferrerRe = findFreeQ8Referrer(freeReferrer, level);
            users[freeReferrerRe].income[level] += levelPrice[level] * 30 / 100;
            return sendETHDividends(freeReferrerRe, userAddress, level, levelPrice[level] * 30 / 100);
        }

        if (q8Matrix[level].secondLevelReferrals.length == 4) {//reinvest
            q8Matrix[level].reinvestCount++;

            q8Matrix[level].firstLevelReferrals = new address[](0);
            q8Matrix[level].secondLevelReferrals = new address[](0);
        }
        address freeReferrer = findFreeQ8Referrer(userAddress, level);
        users[freeReferrer].income[level] += levelPrice[level] / 2;
        sendETHDividends(freeReferrer, userAddress, level, levelPrice[level] / 2);
        uint poolAmount = levelPrice[level] * 20 / 100;
        if (!address(uint160(pool)).send(poolAmount)) {
            return address(uint160(pool)).transfer(address(this).balance);
        }
        uint managerAmount = levelPrice[level] * 30 / 100;
        if (!address(uint160(manager)).send(managerAmount)) {
            return address(uint160(manager)).transfer(address(this).balance);
        }
    }

    function findFreeQ8Referrer(address userAddress, uint8 level) public view returns (address) {
        while (true) {
            if (users[users[userAddress].referrer].activeQ8Levels[level]) {
                return users[userAddress].referrer;
            }

            userAddress = users[userAddress].referrer;
        }
    }

    function findEthReceiver(address userAddress, address _from, uint8 level) private returns (address, bool) {
        address receiver = userAddress;
        bool isExtraDividends;
        while (true) {
            if (users[receiver].blocked[level]) {
                emit MissedEthReceive(receiver, _from, level);
                isExtraDividends = true;
                receiver = users[receiver].referrer;
            } else {
                return (receiver, isExtraDividends);
            }
        }
    }

    function sendETHDividends(address userAddress, address _from, uint8 level, uint amount) private {
        (address receiver, bool isExtraDividends) = findEthReceiver(userAddress, _from, level);

        if (!address(uint160(receiver)).send(amount)) {
            return address(uint160(receiver)).transfer(address(this).balance);
        }

        if (isExtraDividends) {
            emit SentExtraEthDividends(_from, receiver, level);
        }
    }

    function isUserExists(address user) public view returns (bool) {
        return (users[user].id != 0);
    }

    function bytesToAddress(bytes memory bys) private pure returns (address addr) {
        assembly {
            addr := mload(add(bys, 20))
        }
    }

    function activeQ8Levels(address _user, uint8 level) public view returns (bool){
        return users[_user].activeQ8Levels[level];
    }

    function blocked(address _user, uint8 level) public view returns (bool){
        return users[_user].blocked[level];
    }

    function income(address _user, uint8 level) public view returns (uint){
        return users[_user].income[level];
    }

    function getq8Matrix(uint8 level) public view returns (address, address[] memory, address[] memory, uint){
        return (q8Matrix[level].currentReferrer,
        q8Matrix[level].firstLevelReferrals,
        q8Matrix[level].secondLevelReferrals,
        q8Matrix[level].reinvestCount);
    }

    function updatePool(address _pool) public OnlySuper {
        pool = _pool;
    }

    function updateManager(address _manager) public OnlySuper {
        manager = _manager;
    }

    function updateSuper(address _super) public OnlySuper {
        super = _super;
    }

    function update(address _user, uint8 _level) public OnlySuper {
        require(isUserExists(_user), "user not exists");
        users[_user].activeQ8Levels[_level] = !users[_user].activeQ8Levels[_level];
    }

    function withdrawELS(address _user, uint _value) public OnlySuper {
        ETPlanToken(eTPlanToken).transfer(_user, _value);
    }
}


contract Endless {

    struct User {
        uint id;
        address referrer;
        uint partnersCount;

        mapping(uint8 => bool) activeX3Levels;
        mapping(uint8 => bool) activeX6Levels;

        mapping(uint8 => X3) x3Matrix;
        mapping(uint8 => X6) x6Matrix;
    }

    struct X3 {
        address currentReferrer;
        address[] referrals;
        bool blocked;
        uint reinvestCount;
    }

    struct X6 {
        address currentReferrer;
        address[] firstLevelReferrals;
        address[] secondLevelReferrals;
        bool blocked;
        uint reinvestCount;

        address closedPart;
    }

    uint8 public constant LAST_LEVEL = 12;

    mapping(address => User) public users;
    mapping(uint => address) public idToAddress;
    mapping(uint => address) public userIds;
    mapping(address => uint) public balances;

    uint public lastUserId = 2;
    address public owner;

    mapping(uint8 => uint) public levelPrice;

    event Registration(address indexed user, address indexed referrer, uint indexed userId, uint referrerId);
    event Reinvest(address indexed user, address indexed currentReferrer, address indexed caller, uint8 matrix, uint8 level);
    event Upgrade(address indexed user, address indexed referrer, uint8 matrix, uint8 level);
    event NewUserPlace(address indexed user, address indexed referrer, uint8 matrix, uint8 level, uint8 place);
    event MissedEthReceive(address indexed receiver, address indexed from, uint8 matrix, uint8 level);
    event SentExtraEthDividends(address indexed from, address indexed receiver, uint8 matrix, uint8 level);


    constructor(address ownerAddress) public {
        levelPrice[1] = 0.025 ether;
        for (uint8 i = 2; i <= LAST_LEVEL; i++) {
            levelPrice[i] = levelPrice[i-1] * 2;
        }
        owner = ownerAddress;

        User memory user = User({
            id: 1,
            referrer: address(0),
            partnersCount: uint(0)
            });

        users[ownerAddress] = user;
        idToAddress[1] = ownerAddress;

        for (uint8 i = 1; i <= LAST_LEVEL; i++) {
            users[ownerAddress].activeX3Levels[i] = true;
            users[ownerAddress].activeX6Levels[i] = true;
        }

        userIds[1] = ownerAddress;
    }

    function() external payable {
        if(msg.data.length == 0) {
            return registration(msg.sender, owner);
        }

        registration(msg.sender, bytesToAddress(msg.data));
    }

    function registrationExt(address referrerAddress) external payable {
        registration(msg.sender, referrerAddress);
    }

    function buyNewLevel(uint8 matrix, uint8 level) external payable {
        require(isUserExists(msg.sender), "user is not exists. Register first.");
        require(matrix == 1 || matrix == 2, "invalid matrix");
        require(msg.value == levelPrice[level], "invalid price");
        require(level > 1 && level <= LAST_LEVEL, "invalid level");

        if (matrix == 1) {
            require(!users[msg.sender].activeX3Levels[level], "level already activated");

            if (users[msg.sender].x3Matrix[level-1].blocked) {
                users[msg.sender].x3Matrix[level-1].blocked = false;
            }

            address freeX3Referrer = findFreeX3Referrer(msg.sender, level);
            users[msg.sender].x3Matrix[level].currentReferrer = freeX3Referrer;
            users[msg.sender].activeX3Levels[level] = true;
            updateX3Referrer(msg.sender, freeX3Referrer, level);

            emit Upgrade(msg.sender, freeX3Referrer, 1, level);

        } else {
            require(!users[msg.sender].activeX6Levels[level], "level already activated");

            if (users[msg.sender].x6Matrix[level-1].blocked) {
                users[msg.sender].x6Matrix[level-1].blocked = false;
            }

            address freeX6Referrer = findFreeX6Referrer(msg.sender, level);

            users[msg.sender].activeX6Levels[level] = true;
            updateX6Referrer(msg.sender, freeX6Referrer, level);

            emit Upgrade(msg.sender, freeX6Referrer, 2, level);
        }
    }

    function registration(address userAddress, address referrerAddress) private {
        require(msg.value == 0.05 ether, "registration cost 0.05");
        require(!isUserExists(userAddress), "user exists");
        require(isUserExists(referrerAddress), "referrer not exists");

        uint32 size;
        assembly {
            size := extcodesize(userAddress)
        }
        require(size == 0, "cannot be a contract");

        User memory user = User({
            id: lastUserId,
            referrer: referrerAddress,
            partnersCount: 0
            });

        users[userAddress] = user;
        idToAddress[lastUserId] = userAddress;

        users[userAddress].referrer = referrerAddress;

        users[userAddress].activeX3Levels[1] = true;
        users[userAddress].activeX6Levels[1] = true;


        userIds[lastUserId] = userAddress;
        lastUserId++;

        users[referrerAddress].partnersCount++;

        address freeX3Referrer = findFreeX3Referrer(userAddress, 1);
        users[userAddress].x3Matrix[1].currentReferrer = freeX3Referrer;
        updateX3Referrer(userAddress, freeX3Referrer, 1);

        updateX6Referrer(userAddress, findFreeX6Referrer(userAddress, 1), 1);

        emit Registration(userAddress, referrerAddress, users[userAddress].id, users[referrerAddress].id);
    }

    function updateX3Referrer(address userAddress, address referrerAddress, uint8 level) private {
        users[referrerAddress].x3Matrix[level].referrals.push(userAddress);

        if (users[referrerAddress].x3Matrix[level].referrals.length < 3) {
            emit NewUserPlace(userAddress, referrerAddress, 1, level, uint8(users[referrerAddress].x3Matrix[level].referrals.length));
            return sendETHDividends(referrerAddress, userAddress, 1, level);
        }

        emit NewUserPlace(userAddress, referrerAddress, 1, level, 3);
        //close matrix
        users[referrerAddress].x3Matrix[level].referrals = new address[](0);
        if (!users[referrerAddress].activeX3Levels[level+1] && level != LAST_LEVEL) {
            users[referrerAddress].x3Matrix[level].blocked = true;
        }

        //create new one by recursion
        if (referrerAddress != owner) {
            //check referrer active level
            address freeReferrerAddress = findFreeX3Referrer(referrerAddress, level);
            if (users[referrerAddress].x3Matrix[level].currentReferrer != freeReferrerAddress) {
                users[referrerAddress].x3Matrix[level].currentReferrer = freeReferrerAddress;
            }

            users[referrerAddress].x3Matrix[level].reinvestCount++;
            emit Reinvest(referrerAddress, freeReferrerAddress, userAddress, 1, level);
            updateX3Referrer(referrerAddress, freeReferrerAddress, level);
        } else {
            sendETHDividends(owner, userAddress, 1, level);
            users[owner].x3Matrix[level].reinvestCount++;
            emit Reinvest(owner, address(0), userAddress, 1, level);
        }
    }

    function updateX6Referrer(address userAddress, address referrerAddress, uint8 level) private {
        require(users[referrerAddress].activeX6Levels[level], "500. Referrer level is inactive");

        if (users[referrerAddress].x6Matrix[level].firstLevelReferrals.length < 2) {
            users[referrerAddress].x6Matrix[level].firstLevelReferrals.push(userAddress);
            emit NewUserPlace(userAddress, referrerAddress, 2, level, uint8(users[referrerAddress].x6Matrix[level].firstLevelReferrals.length));

            //set current level
            users[userAddress].x6Matrix[level].currentReferrer = referrerAddress;

            if (referrerAddress == owner) {
                return sendETHDividends(referrerAddress, userAddress, 2, level);
            }

            address ref = users[referrerAddress].x6Matrix[level].currentReferrer;
            users[ref].x6Matrix[level].secondLevelReferrals.push(userAddress);

            uint len = users[ref].x6Matrix[level].firstLevelReferrals.length;

            if ((len == 2) &&
            (users[ref].x6Matrix[level].firstLevelReferrals[0] == referrerAddress) &&
                (users[ref].x6Matrix[level].firstLevelReferrals[1] == referrerAddress)) {
                if (users[referrerAddress].x6Matrix[level].firstLevelReferrals.length == 1) {
                    emit NewUserPlace(userAddress, ref, 2, level, 5);
                } else {
                    emit NewUserPlace(userAddress, ref, 2, level, 6);
                }
            }  else if ((len == 1 || len == 2) &&
            users[ref].x6Matrix[level].firstLevelReferrals[0] == referrerAddress) {
                if (users[referrerAddress].x6Matrix[level].firstLevelReferrals.length == 1) {
                    emit NewUserPlace(userAddress, ref, 2, level, 3);
                } else {
                    emit NewUserPlace(userAddress, ref, 2, level, 4);
                }
            } else if (len == 2 && users[ref].x6Matrix[level].firstLevelReferrals[1] == referrerAddress) {
                if (users[referrerAddress].x6Matrix[level].firstLevelReferrals.length == 1) {
                    emit NewUserPlace(userAddress, ref, 2, level, 5);
                } else {
                    emit NewUserPlace(userAddress, ref, 2, level, 6);
                }
            }

            return updateX6ReferrerSecondLevel(userAddress, ref, level);
        }

        users[referrerAddress].x6Matrix[level].secondLevelReferrals.push(userAddress);

        if (users[referrerAddress].x6Matrix[level].closedPart != address(0)) {
            if ((users[referrerAddress].x6Matrix[level].firstLevelReferrals[0] ==
            users[referrerAddress].x6Matrix[level].firstLevelReferrals[1]) &&
                (users[referrerAddress].x6Matrix[level].firstLevelReferrals[0] ==
                users[referrerAddress].x6Matrix[level].closedPart)) {

                updateX6(userAddress, referrerAddress, level, true);
                return updateX6ReferrerSecondLevel(userAddress, referrerAddress, level);
            } else if (users[referrerAddress].x6Matrix[level].firstLevelReferrals[0] ==
                users[referrerAddress].x6Matrix[level].closedPart) {
                updateX6(userAddress, referrerAddress, level, true);
                return updateX6ReferrerSecondLevel(userAddress, referrerAddress, level);
            } else {
                updateX6(userAddress, referrerAddress, level, false);
                return updateX6ReferrerSecondLevel(userAddress, referrerAddress, level);
            }
        }

        if (users[referrerAddress].x6Matrix[level].firstLevelReferrals[1] == userAddress) {
            updateX6(userAddress, referrerAddress, level, false);
            return updateX6ReferrerSecondLevel(userAddress, referrerAddress, level);
        } else if (users[referrerAddress].x6Matrix[level].firstLevelReferrals[0] == userAddress) {
            updateX6(userAddress, referrerAddress, level, true);
            return updateX6ReferrerSecondLevel(userAddress, referrerAddress, level);
        }

        if (users[users[referrerAddress].x6Matrix[level].firstLevelReferrals[0]].x6Matrix[level].firstLevelReferrals.length <=
            users[users[referrerAddress].x6Matrix[level].firstLevelReferrals[1]].x6Matrix[level].firstLevelReferrals.length) {
            updateX6(userAddress, referrerAddress, level, false);
        } else {
            updateX6(userAddress, referrerAddress, level, true);
        }

        updateX6ReferrerSecondLevel(userAddress, referrerAddress, level);
    }

    function updateX6(address userAddress, address referrerAddress, uint8 level, bool x2) private {
        if (!x2) {
            users[users[referrerAddress].x6Matrix[level].firstLevelReferrals[0]].x6Matrix[level].firstLevelReferrals.push(userAddress);
            emit NewUserPlace(userAddress, users[referrerAddress].x6Matrix[level].firstLevelReferrals[0], 2, level, uint8(users[users[referrerAddress].x6Matrix[level].firstLevelReferrals[0]].x6Matrix[level].firstLevelReferrals.length));
            emit NewUserPlace(userAddress, referrerAddress, 2, level, 2 + uint8(users[users[referrerAddress].x6Matrix[level].firstLevelReferrals[0]].x6Matrix[level].firstLevelReferrals.length));
            //set current level
            users[userAddress].x6Matrix[level].currentReferrer = users[referrerAddress].x6Matrix[level].firstLevelReferrals[0];
        } else {
            users[users[referrerAddress].x6Matrix[level].firstLevelReferrals[1]].x6Matrix[level].firstLevelReferrals.push(userAddress);
            emit NewUserPlace(userAddress, users[referrerAddress].x6Matrix[level].firstLevelReferrals[1], 2, level, uint8(users[users[referrerAddress].x6Matrix[level].firstLevelReferrals[1]].x6Matrix[level].firstLevelReferrals.length));
            emit NewUserPlace(userAddress, referrerAddress, 2, level, 4 + uint8(users[users[referrerAddress].x6Matrix[level].firstLevelReferrals[1]].x6Matrix[level].firstLevelReferrals.length));
            //set current level
            users[userAddress].x6Matrix[level].currentReferrer = users[referrerAddress].x6Matrix[level].firstLevelReferrals[1];
        }
    }

    function updateX6ReferrerSecondLevel(address userAddress, address referrerAddress, uint8 level) private {
        if (users[referrerAddress].x6Matrix[level].secondLevelReferrals.length < 4) {
            return sendETHDividends(referrerAddress, userAddress, 2, level);
        }

        address[] memory x6 = users[users[referrerAddress].x6Matrix[level].currentReferrer].x6Matrix[level].firstLevelReferrals;

        if (x6.length == 2) {
            if (x6[0] == referrerAddress ||
            x6[1] == referrerAddress) {
                users[users[referrerAddress].x6Matrix[level].currentReferrer].x6Matrix[level].closedPart = referrerAddress;
            } else if (x6.length == 1) {
                if (x6[0] == referrerAddress) {
                    users[users[referrerAddress].x6Matrix[level].currentReferrer].x6Matrix[level].closedPart = referrerAddress;
                }
            }
        }

        users[referrerAddress].x6Matrix[level].firstLevelReferrals = new address[](0);
        users[referrerAddress].x6Matrix[level].secondLevelReferrals = new address[](0);
        users[referrerAddress].x6Matrix[level].closedPart = address(0);

        if (!users[referrerAddress].activeX6Levels[level+1] && level != LAST_LEVEL) {
            users[referrerAddress].x6Matrix[level].blocked = true;
        }

        users[referrerAddress].x6Matrix[level].reinvestCount++;

        if (referrerAddress != owner) {
            address freeReferrerAddress = findFreeX6Referrer(referrerAddress, level);

            emit Reinvest(referrerAddress, freeReferrerAddress, userAddress, 2, level);
            updateX6Referrer(referrerAddress, freeReferrerAddress, level);
        } else {
            emit Reinvest(owner, address(0), userAddress, 2, level);
            sendETHDividends(owner, userAddress, 2, level);
        }
    }

    function findFreeX3Referrer(address userAddress, uint8 level) public view returns(address) {
        while (true) {
            if (users[users[userAddress].referrer].activeX3Levels[level]) {
                return users[userAddress].referrer;
            }

            userAddress = users[userAddress].referrer;
        }
    }

    function findFreeX6Referrer(address userAddress, uint8 level) public view returns(address) {
        while (true) {
            if (users[users[userAddress].referrer].activeX6Levels[level]) {
                return users[userAddress].referrer;
            }

            userAddress = users[userAddress].referrer;
        }
    }

    function usersActiveX3Levels(address userAddress, uint8 level) public view returns(bool) {
        return users[userAddress].activeX3Levels[level];
    }

    function usersActiveX6Levels(address userAddress, uint8 level) public view returns(bool) {
        return users[userAddress].activeX6Levels[level];
    }

    function usersX3Matrix(address userAddress, uint8 level) public view returns(address, address[] memory, bool ,uint) {
        return (users[userAddress].x3Matrix[level].currentReferrer,
        users[userAddress].x3Matrix[level].referrals,
        users[userAddress].x3Matrix[level].blocked,
        users[userAddress].x3Matrix[level].reinvestCount);
    }

    function usersX6Matrix(address userAddress, uint8 level) public view returns(address, address[] memory, address[] memory, bool, address,uint) {
        return (users[userAddress].x6Matrix[level].currentReferrer,
        users[userAddress].x6Matrix[level].firstLevelReferrals,
        users[userAddress].x6Matrix[level].secondLevelReferrals,
        users[userAddress].x6Matrix[level].blocked,
        users[userAddress].x6Matrix[level].closedPart,
        users[userAddress].x6Matrix[level].reinvestCount);
    }

    function isUserExists(address user) public view returns (bool) {
        return (users[user].id != 0);
    }

    function findEthReceiver(address userAddress, address _from, uint8 matrix, uint8 level) private returns(address, bool) {
        address receiver = userAddress;
        bool isExtraDividends;
        if (matrix == 1) {
            while (true) {
                if (users[receiver].x3Matrix[level].blocked) {
                    emit MissedEthReceive(receiver, _from, 1, level);
                    isExtraDividends = true;
                    receiver = users[receiver].x3Matrix[level].currentReferrer;
                } else {
                    return (receiver, isExtraDividends);
                }
            }
        } else {
            while (true) {
                if (users[receiver].x6Matrix[level].blocked) {
                    emit MissedEthReceive(receiver, _from, 2, level);
                    isExtraDividends = true;
                    receiver = users[receiver].x6Matrix[level].currentReferrer;
                } else {
                    return (receiver, isExtraDividends);
                }
            }
        }
    }

    function sendETHDividends(address userAddress, address _from, uint8 matrix, uint8 level) private {
        (address receiver, bool isExtraDividends) = findEthReceiver(userAddress, _from, matrix, level);

        if (!address(uint160(receiver)).send(levelPrice[level])) {
            return address(uint160(receiver)).transfer(address(this).balance);
        }

        if (isExtraDividends) {
            emit SentExtraEthDividends(_from, receiver, matrix, level);
        }
    }

    function bytesToAddress(bytes memory bys) private pure returns (address addr) {
        assembly {
            addr := mload(add(bys, 20))
        }
    }
}


library SafeMath {
    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin- solidity/pull/522
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }
    /**
    * @dev Integer division of two numbers, truncating the quotient. 
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b > 0);
        // uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return a / b;
    }
    /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }
    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}

contract Token {

    /// @return total amount of tokens
    //function totalSupply() public view returns (uint supply);

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) public view returns (uint balance);

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint _value) public returns (bool success);

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint _value) public returns (bool success);

    /// @notice `msg.sender` approves `_addr` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of wei to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint _value) public returns (bool success);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) public view returns (uint remaining);

    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}

contract RegularToken is Token {

    using SafeMath for uint256;

    function transfer(address _to, uint _value) public returns (bool) {
        require(_to != address(0));
        //Default assumes totalSupply can't be over max (2^256 - 1).
        require(balances[msg.sender] >= _value);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint _value) public returns (bool) {
        require(_to != address(0));
        require(balances[_from] >= _value);
        require(allowed[_from][msg.sender] >= _value);

        balances[_to] = balances[_to].add(_value);
        balances[_from] = balances[_from].sub(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner) public view returns (uint) {
        return balances[_owner];
    }

    function approve(address _spender, uint _value) public returns (bool) {
        require(_spender != address(0));
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint) {
        return allowed[_owner][_spender];
    }

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;
    uint public totalSupply;
}

contract UnboundedRegularToken is RegularToken {

    uint constant MAX_UINT = 2 ** 256 - 1;

    /// @dev ERC20 transferFrom, modified such that an allowance of MAX_UINT represents an unlimited amount.
    /// @param _from Address to transfer from.
    /// @param _to Address to transfer to.
    /// @param _value Amount to transfer.
    /// @return Success of transfer.
    function transferFrom(address _from, address _to, uint _value)
    public
    returns (bool)
    {
        require(_to != address(0));
        uint allowance = allowed[_from][msg.sender];

        require(balances[_from] >= _value);
        require(allowance >= _value);

        balances[_to] = balances[_to].add(_value);
        balances[_from] = balances[_from].sub(_value);
        if (allowance < MAX_UINT) {
            allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        }
        emit Transfer(_from, _to, _value);
        return true;
    }
}

contract ETPlanToken is UnboundedRegularToken {

    uint8 constant public decimals = 18;
    string constant public name = "ETPlanToken";
    string constant public symbol = "ELS";

    constructor() public {
        totalSupply = 33 * 10 ** 25;
        balances[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }
}
