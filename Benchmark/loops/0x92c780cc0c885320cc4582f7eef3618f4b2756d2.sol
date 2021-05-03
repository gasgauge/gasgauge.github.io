/**

 *Submitted for verification at Etherscan.io on 2019-08-06

*/



//pragma solidity >=0.5.0 <0.6.0;
pragma solidity >=0.5 <0.7.17;

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {

            return 0;

        }

        uint256 c = a * b;

        require(c / a == b);

        return c;

    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0);

        uint256 c = a / b;

        return c;

    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a);

        uint256 c = a - b;

        return c;

    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;

        require(c >= a);

        return c;

    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0);

        return a % b;

    }

}

contract Ethertime {

    using SafeMath for *;

    uint256 constant None = uint256(0);

    uint256 constant private MAX_PERCENTS = 10000;

    uint256 constant private FULL_PART = 10000;

    uint256 constant private FEE = 1150;

    uint256 constant MAX_RECENT_BLOCK_NUMBER = 250;

    uint256 constant TRANSACTIONS_PER_PAYOUT = 25;

    enum LotteryStatus {

        Open,        Finished    }

    enum LotteryPrizeType {

        T10,        T30,        T50,        All,        First,        Three    }

    enum OrderStatus {

        Open,

        Closed

    }

    struct Player {

        address addr;

        uint256 blockNumber;

        uint256 sum;

        uint256 prize;

    }

    struct Lottery {

        uint256 id;

        string name;

        uint256 price;

        uint256 begin;

        uint256 end;

        uint256 number;

        uint256 pot;

        uint256 parentId;

        uint256 childId;

        uint256 winNumber;

        uint256 blockNumberForRandom;

        uint256 winningsCount;

        uint256 remainder;

        uint256 alreadyPayedCount;

        bytes32 blockHashForRandom;

        address owner;

        LotteryStatus status;

        LotteryPrizeType prizeType;

        bool withDiscount;

        bool isContinued;

        bool isPayedOut;

    }

    struct Order {

        uint256 id;

        uint256 part;

        uint256 sum;

        uint256 expiredDate;

        address admin;

        address recipient;

        OrderStatus status;

    }

    address private _owner;

    uint256 private _totalFee;

    address[] private _admins;

    mapping (address => uint256) private _adminsParts;

    mapping (uint256 => Lottery) private _lotteries;

    uint256 _lastLotteryId;

    mapping (uint256 => Player[]) private _players;

    mapping (uint256 => uint256) private _uniquePlayersCount;

    uint256[] _openLotteries;

    uint256[] _unpayedLotteries;

    mapping (uint256 => uint256) private _reservedFee;

    mapping (uint256 => Order) private _orders;

    uint256 _lastOrderId;

    event BuyTicketEvent(

        address indexed from,

        uint256 indexed lotteryId

    );

    event NewLotteryEvent(

        uint256 indexed lotteryId

    );

    event FinishedLotteryEvent(

        uint256 indexed lotteryId

    );

    event PayOutEvent(

        uint256 indexed lotteryId,

        uint256 indexed leftToPay

    );

    event DeleteLotteryEvent(

        uint256 indexed lotteryId

    );

    event WinPrizeEvent(

        address indexed player,

        uint256 indexed prize,

        uint256 indexed lotteryId

    );

    event TransferAdminPartEvent(

        address indexed from,

        address indexed to,

        uint256 indexed part

    );

    event TransferOwnershipEvent(

        address indexed from,

        address indexed to

    );

    event DividendEvent(

        address indexed admin,

        uint256 indexed sum

    );

    event NewOrderEvent(

        uint256 indexed orderId,

        address indexed admin,

        address indexed recipient

    );

    event ConfirmOrderEvent(

        uint256 indexed orderId

    );

    modifier onlyOwner() {

        require(msg.sender == _owner);

        _;

    }

    modifier onlyAdmin() {

        require(checkIsAdmin(msg.sender));

        _;

    }

    constructor() public {

        _owner = msg.sender;

        _admins.push(_owner);

        _adminsParts[_owner] = FULL_PART;

    }

    function transferOwnership(address addr) public onlyOwner {

        _owner = addr;

        emit TransferOwnershipEvent(msg.sender, addr);

    }

    function transferAdminPart(address addr, uint256 part)

        public

        onlyAdmin

    {

        require(part <= _adminsParts[msg.sender]);

        distributeDividend();

        if (!checkIsAdmin(addr)) {

            _admins.push(addr);

        }

        _adminsParts[msg.sender] = _adminsParts[msg.sender].sub(part);

        _adminsParts[addr] = _adminsParts[addr].add(part);

        if (_adminsParts[msg.sender] == 0) {

            removeAdmin(msg.sender);

        }

        emit TransferAdminPartEvent(msg.sender, addr, part);

    }

    function distributeDividend() public onlyAdmin {

        if (_totalFee == 0)

            return;

        uint256 totalSum = _totalFee;

        for (uint256 i = 0; i < _admins.length; i++) {

            address payable addr = address(uint160(_admins[i]));

            uint256 sum = totalSum.mul(_adminsParts[addr]).div(FULL_PART);

            if (sum > 0) {

                _totalFee = _totalFee.sub(sum);

                addr.transfer(sum);

                emit DividendEvent(addr, sum);

            }

        }

    }

    function createLottery(

        string memory name,

        uint256 price,

        uint256 begin,

        uint256 end,

        LotteryPrizeType prizeType,

        bool withDiscount

    )

        public

        onlyOwner

    {

        require(begin < end);

        _lastLotteryId = _lastLotteryId.add(1);

        _lotteries[_lastLotteryId] = Lottery({

            id: _lastLotteryId,

            name: name,

            owner: msg.sender,

            price: price,

            begin: begin,

            end: end,

            number: 1,

            pot: 0,

            status: LotteryStatus.Open,

            prizeType: prizeType,

            parentId: None,

            childId: None,

            isContinued: true,

            winNumber: 0,

            blockNumberForRandom: 0,

            blockHashForRandom: 0x0,

            withDiscount: withDiscount,

            winningsCount: None,

            isPayedOut: false,

            alreadyPayedCount: 0,

            remainder: 0

         });

        _openLotteries.push(_lastLotteryId);

        emit NewLotteryEvent(_lastLotteryId);

    }

    function buyTicket(uint256 lotteryId) public payable {

        require(lotteryId <= _lastLotteryId);

        finalizeLotteries();

        uint256 actualLotteryId = getActualLotteryId(lotteryId);

        require(actualLotteryId != None);

        Lottery storage lottery = _lotteries[actualLotteryId];

        uint256 actualPrice = getActualLotteryPrice(lottery);

        require(msg.value >= actualPrice);

        incUniquePlayersCount(lottery.id, msg.sender);

        addPlayerToLottery(lottery, actualPrice);

        uint256 feeSum = actualPrice.mul(FEE).div(MAX_PERCENTS);

        lottery.pot = lottery.pot.add(actualPrice.sub(feeSum));

        _reservedFee[lottery.id] = _reservedFee[lottery.id].add(feeSum);

        uint256 remainder = msg.value.sub(actualPrice);

        if (remainder > 0)

            msg.sender.transfer(remainder);

        emit BuyTicketEvent(msg.sender, actualLotteryId);

    }

    function finalizeLotteries() public {

        for (uint256 i = 0; i < _openLotteries.length; i++) {

            uint256 lotteryId = _openLotteries[i];

            if (_lotteries[lotteryId].end < now) {

                if (_players[lotteryId].length > 0) {

                    uint256 lastIndex = _players[lotteryId].length.sub(1);

                    uint256 blockNumber = _players[lotteryId][lastIndex].blockNumber;

                    if (block.number.sub(blockNumber) == 1) {

                        continue;

                    }

                }

                finalizeLottery(_lotteries[lotteryId]);

            }

        }

    }

    function payOutLotteryPrizes(uint256 lotteryId) public {

        Lottery storage lottery = _lotteries[lotteryId];

        require(lottery.status == LotteryStatus.Finished && lottery.isPayedOut == false);

        uint256[] memory shareOfWinnings;

        if (lottery.prizeType == LotteryPrizeType.Three) {

            shareOfWinnings = getShareOfWinningsForThree(lottery.winningsCount);

        } else {

            shareOfWinnings = getShareOfWinnings(lottery.winningsCount);

        }

        uint256 toPayCount = getToPayCount(lottery.winningsCount, lottery.alreadyPayedCount);

        for (uint256 i = lottery.alreadyPayedCount; i < lottery.alreadyPayedCount.add(toPayCount); i++) {

            uint256 playerIndex = lottery.winNumber.add(i);

            if (playerIndex >= _players[lottery.id].length)

                playerIndex = playerIndex.sub(_players[lottery.id].length);

            uint256 prize = shareOfWinnings[i].mul(lottery.pot).div(MAX_PERCENTS);

            if (prize > 0) {

                lottery.remainder = lottery.remainder.sub(prize);

                address payable addr = address(uint160(_players[lottery.id][playerIndex].addr));

                _players[lottery.id][playerIndex].prize = prize;

                addr.transfer(prize);

                emit WinPrizeEvent(addr, prize, lottery.id);

            }

        }

        lottery.alreadyPayedCount = lottery.alreadyPayedCount.add(toPayCount);

        emit PayOutEvent(

            lottery.id,

            lottery.winningsCount.sub(lottery.alreadyPayedCount)

        );

        if (lottery.alreadyPayedCount == lottery.winningsCount) {

            if (lottery.remainder > 0) {

                _totalFee = _totalFee.add(lottery.remainder);

            }

            lottery.remainder = 0;

            _totalFee = _totalFee.add(_reservedFee[lottery.id]);

            _reservedFee[lottery.id] = 0;

            lottery.isPayedOut = true;

            removeLotteryIdFromArray(lottery.id, _unpayedLotteries);

        }

    }

    function deleteLottery(uint256 lotteryId) public onlyOwner {

        require(lotteryId <= _lastLotteryId);

        Lottery storage lottery = _lotteries[lotteryId];

        require(lottery.status == LotteryStatus.Open);

        require(lottery.isContinued);

        lottery.isContinued = false;

        emit DeleteLotteryEvent(lotteryId);

    }

    function createOrder(

        address recipient,

        uint256 part,

        uint256 sum,

        uint256 expiredDate

    )

        public

        onlyAdmin

    {

        require(_adminsParts[msg.sender] >= part);

        require(expiredDate > now);

        _lastOrderId = _lastOrderId.add(1);

        _orders[_lastOrderId] = Order({

            id: _lastOrderId,

            admin: msg.sender,

            recipient: recipient,

            part: part,

            sum: sum,

            expiredDate: expiredDate,

            status: OrderStatus.Open

         });

        emit NewOrderEvent(_lastOrderId, msg.sender, recipient);

    }

    function confirmOrder(uint256 orderId) public payable {

        require(orderId <= _lastOrderId);

        Order storage order = _orders[orderId];

        require(msg.sender == order.recipient);

        require(order.expiredDate > now);

        require(order.status == OrderStatus.Open);

        require(msg.value >= order.sum);

        require(order.part <= _adminsParts[order.admin]);

        if (!checkIsAdmin(msg.sender)) {

            _admins.push(msg.sender);

        }

        distributeDividend();

        _adminsParts[order.admin] = _adminsParts[order.admin].sub(order.part);

        _adminsParts[msg.sender] = _adminsParts[msg.sender].add(order.part);

        if (_adminsParts[order.admin] == 0) {

            removeAdmin(order.admin);

        }

        address payable addr = address(uint160(order.admin));

        addr.transfer(order.sum);

        uint256 remainder = msg.value.sub(order.sum);

        if (remainder > 0)

            msg.sender.transfer(remainder);

        order.status = OrderStatus.Closed;

        emit ConfirmOrderEvent(order.id);

    }

    function() external payable {

        uint256 lotteryId = None;

        uint256 price = 0;

        for (uint256 i = 0; i < _openLotteries.length; i++) {

            uint256 openLotteryId = _openLotteries[i];

            uint256 openLotteryPrice = _lotteries[openLotteryId].price;

            if (msg.value >= openLotteryPrice && openLotteryPrice > price) {

                lotteryId = openLotteryId;

                price = openLotteryPrice;

            }

        }

        if (lotteryId != None) {

            buyTicket(lotteryId);

        } else {

            revert();

        }

    }

    function getOwner() public view returns (address) {

        return _owner;

    }

    function getTotalFee() public view returns (uint256) {

        return _totalFee;

    }

    function getAdmins() public view returns (address[] memory) {

        return _admins;

    }

    function getAdminPartByAddress(address addr) public view returns (uint256) {

        return _adminsParts[addr];

    }

    function getLotteryInfo(uint256 id)

        public

        view

        returns (

            uint256 price,

            uint256 begin,

            uint256 end,

            uint256 number,

            uint256 pot,

            uint256 parentId,

            uint256 childId,

            string memory name,

            LotteryStatus status,

            LotteryPrizeType prizeType,

            bool withDiscount,

            bool isContinued

        )

    {

        Lottery memory lottery = _lotteries[id];

        return (

            lottery.price,

            lottery.begin,

            lottery.end,

            lottery.number,

            lottery.pot,

            lottery.parentId,

            lottery.childId,

            lottery.name,

            lottery.status,

            lottery.prizeType,

            lottery.withDiscount,

            lottery.isContinued

        );

    }

    function getFinishedLotteryInfo(uint256 id)

        public

        view

        returns (

            uint256 winNumber,

            uint256 blockNumberForRandom,

            bytes32 blockHashForRandom,

            uint256 totalPlayers,

            uint256 alreadyPayedCount,

            uint256 winningsCount,

            bool isPayedOut

        )

    {

        Lottery memory lottery = _lotteries[id];

        require(lottery.status == LotteryStatus.Finished);

        return (

            lottery.winNumber,

            lottery.blockNumberForRandom,

            lottery.blockHashForRandom,

            _players[id].length,

            lottery.alreadyPayedCount,

            lottery.winningsCount,

            lottery.isPayedOut

        );

    }

    function getLotteryPlayers(uint256 lotteryId)

        public

        view

        returns (

            address[] memory addresses,

            uint256[] memory blockNumbers,

            uint256[] memory sums

        )

    {

        require(lotteryId <= _lastLotteryId);

        Player[] memory players = _players[lotteryId];

        addresses = new address[](players.length);

        blockNumbers = new uint256[](players.length);

        sums = new uint256[](players.length);

        for (uint256 i = 0; i < players.length; i++) {

            addresses[i] = players[i].addr;

            blockNumbers[i] = players[i].blockNumber;

            sums[i] = players[i].sum;

        }

        return (addresses, blockNumbers, sums);

    }

    function getWinPlayers(uint256 lotteryId)

        public

        view

        returns (address[] memory addresses, uint256[] memory prizes)

    {

        Lottery memory lottery = _lotteries[lotteryId];

        require(lottery.status == LotteryStatus.Finished && lottery.isPayedOut == true);

        Player[] memory players = _players[lotteryId];

        addresses = new address[](lottery.winningsCount);

        prizes = new uint256[](lottery.winningsCount);

        uint256 j = 0;

        for (uint256 i = 0; i < players.length; i++) {

            if (players[i].prize > 0) {

                addresses[j] = players[i].addr;

                prizes[j] = players[i].prize;

                j++;

            }

        }

        return (addresses, prizes);

    }

    function getActualLotteryId(uint256 lotteryId)

        public

        view

        returns (uint256)

    {

        require(lotteryId <= _lastLotteryId);

        uint256 actualLotteryId = None;

        bool isLotteryDeleted = false;

        Lottery memory lottery = _lotteries[lotteryId];

        while (lottery.status == LotteryStatus.Finished) {

            if (lottery.childId == None) {

                isLotteryDeleted = true;

                break;

            }

            lottery = _lotteries[lottery.childId];

        }

        if (!isLotteryDeleted)

            actualLotteryId = lottery.id;

        return actualLotteryId;

    }

    function getOpenedLotteries() public view returns (uint256[] memory) {

        uint256[] memory result = new uint256[](_openLotteries.length);

        for (uint256 i = 0; i < _openLotteries.length; i++) {

            result[i] = _openLotteries[i];

        }

        return result;

    }

    function getUnpayedLotteries() public view returns (uint256[] memory) {

        uint256[] memory result = new uint256[](_unpayedLotteries.length);

        for (uint256 i = 0; i < _unpayedLotteries.length; i++) {

            result[i] = _unpayedLotteries[i];

        }

        return result;

    }

    function getUniquePlayersCount(

        uint256 lotteryId

    )

        public

        view

        returns (uint256)

    {

        return _uniquePlayersCount[lotteryId];

    }

    function getOrderInfo(uint256 id)

        public

        view

        returns (

            address admin,

            address recipient,

            uint256 part,

            uint256 sum,

            uint256 expiredDate,

            OrderStatus status

        )

    {

        Order memory order = _orders[id];

        return (

            order.admin,

            order.recipient,

            order.part,

            order.sum,

            order.expiredDate,

            order.status

        );

    }

    function checkIsAdmin(address addr) private view returns (bool) {

        bool isAdmin = false;

        for (uint256 i = 0; i < _admins.length; i++) {

            if (addr == _admins[i]) {

                isAdmin = true;

                break;

            }

        }

        return isAdmin;

    }

    function removeAdmin(address addr) private {

        require(checkIsAdmin(addr));

        require(_adminsParts[addr] == 0);

        uint256 index;

        for (uint256 i = 0; i < _admins.length; i++) {

            if (_admins[i] == addr) {

                index = i;

                break;

            }

        }

        for (uint256 i = index; i < _admins.length.sub(1); i++) {

            _admins[i] = _admins[i.add(1)];

        }

        _admins.length--;

    }

    function addPlayerToLottery(Lottery memory lottery, uint256 sum) private {

        require(lottery.begin <= now && lottery.end >= now);

        require(lottery.status == LotteryStatus.Open);

        Player memory player = Player({

            addr: msg.sender,

            blockNumber: block.number,

            sum: sum,

            prize: 0

        });

        _players[lottery.id].push(player);

    }

    function createChildLottery(Lottery storage parentLottery) private {

        if (!parentLottery.isContinued)

            return;

        uint256 period = parentLottery.end.sub(parentLottery.begin);

        uint256 begin = parentLottery.end;

        uint256 end = begin.add(period);

        if (end < now)

            (begin, end) = getPeriodBorders(begin, end, now);

        _lastLotteryId = _lastLotteryId.add(1);

        _lotteries[_lastLotteryId] = Lottery({

            id: _lastLotteryId,

            name: parentLottery.name,

            owner: msg.sender,

            price: parentLottery.price,

            begin: begin,

            end: end,

            number: parentLottery.number.add(1),

            pot: 0,

            status: LotteryStatus.Open,

            prizeType: parentLottery.prizeType,

            parentId: parentLottery.id,

            childId: None,

            isContinued: parentLottery.isContinued,

            winNumber: 0,

            blockNumberForRandom: 0,

            blockHashForRandom: 0x0,

            withDiscount: parentLottery.withDiscount,

            winningsCount: None,

            isPayedOut: false,

            alreadyPayedCount: 0,

            remainder: 0

         });

        parentLottery.childId = _lastLotteryId;

        _openLotteries.push(_lastLotteryId);

        emit NewLotteryEvent(_lastLotteryId);

    }

    function getPeriodBorders(uint256 begin, uint256 end, uint256 currentTime)

        private

        pure

        returns (uint256, uint256)

    {

        if (end < currentTime) {

            uint256 period = end.sub(begin);

            uint256 n = currentTime.sub(end);

            n = n.div(period);

            n = n.add(1);

            uint256 delta = n.mul(period);

            begin = begin.add(delta);

            end = end.add(delta);

        }

        return (begin, end);

    }

    function finalizeLottery(Lottery storage lottery) private {

        beforeFinalizeLottery(lottery);

        uint256 count = _uniquePlayersCount[lottery.id];

        if (count == 0) {

            finalizeEmptyLottery(lottery);

        } else if (count == 1) {

            finalizeOnePlayerLottery(lottery);

        } else {

            finalizeNotEmptyLottery(lottery);

        }

        afterFinalizeLottery(lottery);

    }

    function beforeFinalizeLottery(Lottery storage lottery) private {

        lottery.status = LotteryStatus.Finished;

        removeLotteryIdFromArray(lottery.id, _openLotteries);

    }

    function afterFinalizeLottery(Lottery storage lottery) private {

        emit FinishedLotteryEvent(lottery.id);

        if (lottery.isContinued)

            createChildLottery(lottery);

    }

    function finalizeEmptyLottery(Lottery storage lottery) private {

    }

    function finalizeOnePlayerLottery(Lottery storage lottery) private {

        require(_players[lottery.id].length > 0);

        uint256 sum = 0;

        sum = sum.add(lottery.pot);

        sum = sum.add(_reservedFee[lottery.id]);

        _reservedFee[lottery.id] = 0;

        address payable addr = address(uint160(_players[lottery.id][0].addr));

        addr.transfer(sum);

    }

    function finalizeNotEmptyLottery(Lottery storage lottery) private {

        (

            lottery.winNumber,

            lottery.blockNumberForRandom,

            lottery.blockHashForRandom

        ) = getWinNumber(lottery);

        if (lottery.prizeType == LotteryPrizeType.Three) {

            lottery.winningsCount = getWinningsCountForThree(lottery);

        } else {

            lottery.winningsCount = getWinningsCount(lottery);

        }

        lottery.remainder = lottery.pot;

        _unpayedLotteries.push(lottery.id);

    }

    function incUniquePlayersCount(uint256 lotteryId, address addr) private {

        bool isUniq = true;

        for (uint256 i = 0; i < _players[lotteryId].length; i++) {

            if (addr == _players[lotteryId][i].addr) {

                isUniq = false;

                break;

            }

        }

        if (isUniq)

            _uniquePlayersCount[lotteryId] = _uniquePlayersCount[lotteryId].add(1);

    }

    function removeLotteryIdFromArray(uint256 lotteryId, uint256[] storage array) private {

        bool exists = false;

        uint256 index;

        for (uint256 i = 0; i < array.length; i++) {

            if (array[i] == lotteryId) {

                index = i;

                exists = true;

                break;

            }

        }

        require(exists);

        for (uint256 i = index; i < array.length.sub(1); i++) {

            array[i] = array[i.add(1)];

        }

        array.length--;

    }

    function getWinningsCount(Lottery memory lottery)

        private

        view

        returns (uint256)

    {

        require(_players[lottery.id].length > 0);

        uint256 result;

        uint256 remainder = 0;

        uint256 playersCount = _players[lottery.id].length;

        if (lottery.prizeType == LotteryPrizeType.First) {

            result = 1;

        } else if (lottery.prizeType == LotteryPrizeType.All) {

            result = _players[lottery.id].length;

        } else if (lottery.prizeType == LotteryPrizeType.T10) {

            remainder = playersCount.mod(10);

            result = playersCount.div(10);

        } else if (lottery.prizeType == LotteryPrizeType.T30) {

            result = playersCount.mul(30);

            remainder = result.mod(100);

            result = result.div(100);

        } else if (lottery.prizeType == LotteryPrizeType.T50) {

            result = playersCount.mul(50);

            remainder = result.mod(100);

            result = result.div(100);

        } else {

            revert();

        }

        if (remainder > 0 && result < playersCount) {

            result = result.add(1);

        }

        return result;

    }

    function getWinningsCountForThree(Lottery memory lottery)

        private

        view

        returns (uint256)

    {

        uint256 result;

        if (_players[lottery.id].length < 3)

            result = 1;

        else

            result = 3;

        return result;

    }

    function getWinNumber(Lottery memory lottery)

        private

        view

        returns (uint256, uint256, bytes32)

    {

        require(lottery.end < now);

        require(_players[lottery.id].length > 0);

        uint256 lastIndex = _players[lottery.id].length.sub(1);

        uint256 blockNumber = _players[lottery.id][lastIndex].blockNumber;

        if (block.number.sub(blockNumber) > MAX_RECENT_BLOCK_NUMBER)

            blockNumber = block.number.sub(MAX_RECENT_BLOCK_NUMBER);

        else

            blockNumber = blockNumber.add(1);

        bytes32 hash = blockhash(blockNumber);

        return (getRandomNumber(hash, _players[lottery.id].length), blockNumber, hash);

    }

    function getRandomNumber(bytes32 hash, uint256 n)

        private

        pure

        returns (uint256)

    {

        return uint256(keccak256(abi.encodePacked(hash))).mod(n);

    }

    function getActualLotteryPrice(Lottery memory lottery)

        private

        view

        returns (uint256)

    {

        if (!lottery.withDiscount)

            return lottery.price;

        uint256 discount = 0;

        uint256 percent = 0;

        (uint256 b1, uint256 b2, uint256 b3) = splitPeriod(lottery.begin, lottery.end);

        if (lottery.begin <= now && now < b1) {

            percent = 300;

        } else if (b1 <= now && now < b2) {

            percent = 200;

        } else if (b2 <= now && now < b3) {

            percent = 100;

        }

        discount = lottery.price.mul(percent).div(MAX_PERCENTS);

        return lottery.price.sub(discount);

    }

    function splitPeriod(uint256 begin, uint256 end)

        private

        pure

        returns (uint256, uint256, uint256)

    {

        require(begin < end);

        uint256 step = (end.sub(begin)).div(4);

        uint256 b1 = begin.add(step);

        uint256 b2 = b1.add(step);

        uint256 b3 = b2.add(step);

        return (b1, b2, b3);

    }

    function getShareOfWinnings(uint256 n)

        private

        pure

        returns (uint256[] memory)

    {

        uint256[] memory result = new uint256[](n);

        uint256 divider = n.mul(n.add(1));

        for (uint256 k = 0; k < n; k++) {

            uint256 p = (n.sub(k)).mul(20000);

            p = p.div(divider);

            result[k] = p;

        }

        return result;

    }

    function getShareOfWinningsForThree(uint256 n)

        private

        pure

        returns (uint256[] memory)

    {

        require(n == 1 || n == 3);

        uint256[] memory result = new uint256[](n);

        if (n == 1) {

            result[0] = 10000;

        } else {

            result[0] = 5000;

            result[1] = 3500;

            result[2] = 1500;

        }

        return result;

    }

    function getToPayCount(uint256 winningsCount, uint256 alreadyPayedCount)

        private

        pure

        returns (uint256)

    {

        uint256 toPayCount = 0;

        if (winningsCount.sub(alreadyPayedCount) <= TRANSACTIONS_PER_PAYOUT) {

            toPayCount = winningsCount.sub(alreadyPayedCount);

        }

        else {

            toPayCount = TRANSACTIONS_PER_PAYOUT;

        }

        return toPayCount;

    }

}
