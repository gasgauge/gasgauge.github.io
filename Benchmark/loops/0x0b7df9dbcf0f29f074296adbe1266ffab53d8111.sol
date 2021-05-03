/**

 *Submitted for verification at Etherscan.io on 2020-12-21

*/



//pragma solidity >=0.4.23 <0.7.0;
pragma solidity >=0.5 <0.7.17;



contract Crypto3X {



    struct User {

        uint id;

        address referrer;

        uint partnersCount;



        mapping(uint8 => bool) activeX3Levels;

        mapping(uint8 => bool) activeX4Levels;

        mapping(uint8 => X3) x3Matrix;

        mapping(uint8 => X4) x4Matrix;

    }



    struct X3 {

        address currentReferrer;

        address[] referrals;

        bool blocked;

        uint reinvestCount;

    }



    struct X4 {

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



    uint public lastUserId = 2;

    address public owner;

    address partner;



    mapping(uint8 => uint) public levelPrice;



    event Registration(address indexed user, address indexed referrer, uint indexed userId, uint referrerId);

    event Reinvest(address indexed user, address indexed currentReferrer, address indexed caller, uint8 matrix, uint8 level);

    event Upgrade(address indexed user, address indexed referrer, uint8 matrix, uint8 level);

    event NewUserPlace(address indexed user, address indexed referrer, uint8  matrix, uint8 level, uint8 place);

    event UserActiveLevels(address indexed user, uint8 indexed matrix, uint256 indexed level);

    event MissedEthReceive(address indexed receiver, address indexed from, uint8 matrix, uint8 level);

    event SentExtraEthDividends(address indexed from, address indexed receiver, uint8 matrix, uint8 level);

    event UserIncome(address indexed user,address indexed from,uint256 value,uint8 matrix, uint8 level);



    constructor(address ownerAddress, address partnerAddress) public {

        levelPrice[1] = 0.015 ether;

        for (uint8 i = 2; i <= LAST_LEVEL; i++) {

            levelPrice[i] = levelPrice[i-1] * 2;

        }



        owner = ownerAddress;

        partner = partnerAddress;



        User memory user = User({

            id: 1,

            referrer: address(0),

            partnersCount: uint(0)

        });



        users[ownerAddress] = user;

        idToAddress[1] = ownerAddress;



        for (uint8 j = 1; j <= LAST_LEVEL; j++) {

            users[ownerAddress].activeX3Levels[j] = true;

            emit UserActiveLevels(owner, 1, j);

            users[ownerAddress].activeX4Levels[j] = true;

            emit UserActiveLevels(owner, 2, j);

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

        require(matrix == 1 || matrix == 2 || matrix==3, "invalid matrix");

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

            emit UserActiveLevels(msg.sender, 1, level);

            updateX3Referrer(msg.sender, freeX3Referrer, level);



            emit Upgrade(msg.sender, freeX3Referrer, 1, level);



        } else if (matrix == 2){

            require(!users[msg.sender].activeX4Levels[level], "level already activated");



            if (users[msg.sender].x4Matrix[level-1].blocked) {

                users[msg.sender].x4Matrix[level-1].blocked = false;

            }



            address freeX4Referrer = findFreeX4Referrer(msg.sender, level);



            users[msg.sender].activeX4Levels[level] = true;

            emit UserActiveLevels(msg.sender, 2, level);

            updateX4Referrer(msg.sender, freeX4Referrer, level);



            emit Upgrade(msg.sender, freeX4Referrer, 2, level);

        }

    }



    function registration(address userAddress, address referrerAddress) private {

        require(msg.value == (levelPrice[1] * 2), "registration cost 0.09 ether");

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

        emit UserActiveLevels(msg.sender, 1, 1);

        users[userAddress].activeX4Levels[1] = true;

        emit UserActiveLevels(msg.sender, 2, 1);



        userIds[lastUserId] = userAddress;

        lastUserId++;



        users[referrerAddress].partnersCount++;



        address freeX3Referrer = findFreeX3Referrer(userAddress, 1);

        users[userAddress].x3Matrix[1].currentReferrer = freeX3Referrer;

        updateX3Referrer(userAddress, freeX3Referrer, 1);



        updateX4Referrer(userAddress, findFreeX4Referrer(userAddress, 1), 1);



        emit Registration(userAddress, referrerAddress, users[userAddress].id, users[referrerAddress].id);

    }



    function updateX3Referrer(address userAddress, address referrerAddress, uint8 level) private {

        users[referrerAddress].x3Matrix[level].referrals.push(userAddress);



        if (users[referrerAddress].x3Matrix[level].referrals.length < 3) {

            emit NewUserPlace(userAddress, referrerAddress, 1, level, uint8(users[referrerAddress].x3Matrix[level].referrals.length));

            return sendETHDividends(referrerAddress, userAddress, 1, level);

        }



        emit NewUserPlace(userAddress, referrerAddress, 1, level, 3);



        users[referrerAddress].x3Matrix[level].referrals = new address[](0);

        if (!users[referrerAddress].activeX3Levels[level+1] && level != LAST_LEVEL) {

            users[referrerAddress].x3Matrix[level].blocked = true;

        }



        if (referrerAddress != owner) {

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



    function updateX4Referrer(address userAddress, address referrerAddress, uint8 level) private {

        require(users[referrerAddress].activeX4Levels[level], "500. Referrer level is inactive");



        if (users[referrerAddress].x4Matrix[level].firstLevelReferrals.length < 2) {

            users[referrerAddress].x4Matrix[level].firstLevelReferrals.push(userAddress);

            emit NewUserPlace(userAddress, referrerAddress, 2, level, uint8(users[referrerAddress].x4Matrix[level].firstLevelReferrals.length));



            users[userAddress].x4Matrix[level].currentReferrer = referrerAddress;



            if (referrerAddress == owner) {

                return sendETHDividends(referrerAddress, userAddress, 2, level);

            }



            address ref = users[referrerAddress].x4Matrix[level].currentReferrer;

            users[ref].x4Matrix[level].secondLevelReferrals.push(userAddress);



            uint len = users[ref].x4Matrix[level].firstLevelReferrals.length;



            if ((len == 2) &&

                (users[ref].x4Matrix[level].firstLevelReferrals[0] == referrerAddress) &&

                (users[ref].x4Matrix[level].firstLevelReferrals[1] == referrerAddress)) {

                if (users[referrerAddress].x4Matrix[level].firstLevelReferrals.length == 1) {

                    emit NewUserPlace(userAddress, ref, 2, level, 5);

                } else {

                    emit NewUserPlace(userAddress, ref, 2, level, 6);

                }

            }  else if ((len == 1 || len == 2) &&

                    users[ref].x4Matrix[level].firstLevelReferrals[0] == referrerAddress) {

                if (users[referrerAddress].x4Matrix[level].firstLevelReferrals.length == 1) {

                    emit NewUserPlace(userAddress, ref, 2, level, 3);

                } else {

                    emit NewUserPlace(userAddress, ref, 2, level, 4);

                }

            } else if (len == 2 && users[ref].x4Matrix[level].firstLevelReferrals[1] == referrerAddress) {

                if (users[referrerAddress].x4Matrix[level].firstLevelReferrals.length == 1) {

                    emit NewUserPlace(userAddress, ref, 2, level, 5);

                } else {

                    emit NewUserPlace(userAddress, ref, 2, level, 6);

                }

            }



            return updateX4ReferrerSecondLevel(userAddress, ref, level);

        }



        users[referrerAddress].x4Matrix[level].secondLevelReferrals.push(userAddress);



        if (users[referrerAddress].x4Matrix[level].closedPart != address(0)) {

            if ((users[referrerAddress].x4Matrix[level].firstLevelReferrals[0] ==

                users[referrerAddress].x4Matrix[level].firstLevelReferrals[1]) &&

                (users[referrerAddress].x4Matrix[level].firstLevelReferrals[0] ==

                users[referrerAddress].x4Matrix[level].closedPart)) {



                updateX4(userAddress, referrerAddress, level, true);

                return updateX4ReferrerSecondLevel(userAddress, referrerAddress, level);

            } else if (users[referrerAddress].x4Matrix[level].firstLevelReferrals[0] ==

                users[referrerAddress].x4Matrix[level].closedPart) {

                updateX4(userAddress, referrerAddress, level, true);

                return updateX4ReferrerSecondLevel(userAddress, referrerAddress, level);

            } else {

                updateX4(userAddress, referrerAddress, level, false);

                return updateX4ReferrerSecondLevel(userAddress, referrerAddress, level);

            }

        }



        if (users[referrerAddress].x4Matrix[level].firstLevelReferrals[1] == userAddress) {

            updateX4(userAddress, referrerAddress, level, false);

            return updateX4ReferrerSecondLevel(userAddress, referrerAddress, level);

        } else if (users[referrerAddress].x4Matrix[level].firstLevelReferrals[0] == userAddress) {

            updateX4(userAddress, referrerAddress, level, true);

            return updateX4ReferrerSecondLevel(userAddress, referrerAddress, level);

        }



        if (users[users[referrerAddress].x4Matrix[level].firstLevelReferrals[0]].x4Matrix[level].firstLevelReferrals.length <=

            users[users[referrerAddress].x4Matrix[level].firstLevelReferrals[1]].x4Matrix[level].firstLevelReferrals.length) {

            updateX4(userAddress, referrerAddress, level, false);

        } else {

            updateX4(userAddress, referrerAddress, level, true);

        }



        updateX4ReferrerSecondLevel(userAddress, referrerAddress, level);

    }



    function updateX4(address userAddress, address referrerAddress, uint8 level, bool x2) private {

        if (!x2) {

            users[users[referrerAddress].x4Matrix[level].firstLevelReferrals[0]].x4Matrix[level].firstLevelReferrals.push(userAddress);

            emit NewUserPlace(userAddress, users[referrerAddress].x4Matrix[level].firstLevelReferrals[0], 2, level, uint8(users[users[referrerAddress].x4Matrix[level].firstLevelReferrals[0]].x4Matrix[level].firstLevelReferrals.length));

            emit NewUserPlace(userAddress, referrerAddress, 2, level, 2 + uint8(users[users[referrerAddress].x4Matrix[level].firstLevelReferrals[0]].x4Matrix[level].firstLevelReferrals.length));



            users[userAddress].x4Matrix[level].currentReferrer = users[referrerAddress].x4Matrix[level].firstLevelReferrals[0];

        } else {

            users[users[referrerAddress].x4Matrix[level].firstLevelReferrals[1]].x4Matrix[level].firstLevelReferrals.push(userAddress);

            emit NewUserPlace(userAddress, users[referrerAddress].x4Matrix[level].firstLevelReferrals[1], 2, level, uint8(users[users[referrerAddress].x4Matrix[level].firstLevelReferrals[1]].x4Matrix[level].firstLevelReferrals.length));

            emit NewUserPlace(userAddress, referrerAddress, 2, level, 4 + uint8(users[users[referrerAddress].x4Matrix[level].firstLevelReferrals[1]].x4Matrix[level].firstLevelReferrals.length));



            users[userAddress].x4Matrix[level].currentReferrer = users[referrerAddress].x4Matrix[level].firstLevelReferrals[1];

        }

    }



    function updateX4ReferrerSecondLevel(address userAddress, address referrerAddress, uint8 level) private {

        if (users[referrerAddress].x4Matrix[level].secondLevelReferrals.length < 4) {

            return sendETHDividends(referrerAddress, userAddress, 2, level);

        }



        address[] memory X4First = users[users[referrerAddress].x4Matrix[level].currentReferrer].x4Matrix[level].firstLevelReferrals;



        if (X4First.length == 2) {

            if (X4First[0] == referrerAddress ||

                X4First[1] == referrerAddress) {

                users[users[referrerAddress].x4Matrix[level].currentReferrer].x4Matrix[level].closedPart = referrerAddress;

            } else if (X4First.length == 1) {

                if (X4First[0] == referrerAddress) {

                    users[users[referrerAddress].x4Matrix[level].currentReferrer].x4Matrix[level].closedPart = referrerAddress;

                }

            }

        }



        users[referrerAddress].x4Matrix[level].firstLevelReferrals = new address[](0);

        users[referrerAddress].x4Matrix[level].secondLevelReferrals = new address[](0);

        users[referrerAddress].x4Matrix[level].closedPart = address(0);



        if (!users[referrerAddress].activeX4Levels[level+1] && level != LAST_LEVEL) {

            users[referrerAddress].x4Matrix[level].blocked = true;

        }



        users[referrerAddress].x4Matrix[level].reinvestCount++;



        if (referrerAddress != owner) {

            address freeReferrerAddress = findFreeX4Referrer(referrerAddress, level);



            emit Reinvest(referrerAddress, freeReferrerAddress, userAddress, 2, level);

            updateX4Referrer(referrerAddress, freeReferrerAddress, level);

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



    function findFreeX4Referrer(address userAddress, uint8 level) public view returns(address) {

        while (true) {

            if (users[users[userAddress].referrer].activeX4Levels[level]) {

                return users[userAddress].referrer;

            }



            userAddress = users[userAddress].referrer;

        }

    }



    function usersActiveX3Levels(address userAddress, uint8 level) public view returns(bool) {

        return users[userAddress].activeX3Levels[level];

    }



    function usersActiveX4Levels(address userAddress, uint8 level) public view returns(bool) {

        return users[userAddress].activeX4Levels[level];

    }



    function usersX3Matrix(address userAddress, uint8 level) public view returns(address, address[] memory, bool) {

        return (users[userAddress].x3Matrix[level].currentReferrer,

                users[userAddress].x3Matrix[level].referrals,

                users[userAddress].x3Matrix[level].blocked);

    }



    function usersX4Matrix(address userAddress, uint8 level) public view returns(address, address[] memory, address[] memory, bool, address) {

        return (users[userAddress].x4Matrix[level].currentReferrer,

                users[userAddress].x4Matrix[level].firstLevelReferrals,

                users[userAddress].x4Matrix[level].secondLevelReferrals,

                users[userAddress].x4Matrix[level].blocked,

                users[userAddress].x4Matrix[level].closedPart);

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

        } else if (matrix == 2) {

            while (true) {

                if (users[receiver].x4Matrix[level].blocked) {

                    emit MissedEthReceive(receiver, _from, 2, level);

                    isExtraDividends = true;

                    receiver = users[receiver].x4Matrix[level].currentReferrer;

                } else {

                    return (receiver, isExtraDividends);

                }

            }

        }

    }



    function sendETHDividends(address userAddress, address _from, uint8 matrix, uint8 level) private {

        (address receiver, bool isExtraDividends) = findEthReceiver(userAddress, _from, matrix, level);



        uint256 income = levelPrice[level];



        if (income > address(this).balance) {

            income = address(this).balance;

        }



        if (receiver == owner) {

            address(uint160(receiver)).transfer(income * 90/100);

            address(uint160(partner)).transfer(income * 10/100);

        } else {

            address(uint160(receiver)).transfer(income);

        }





        emit UserIncome(receiver, _from, income, matrix, level);



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
