/**

 *Submitted for verification at Etherscan.io on 2019-08-26

*/



//pragma solidity 0.5.11;
pragma solidity >=0.5 <0.7.17;





/**

 * @title SafeMath

 * @dev Math operations with safety checks that revert on error

 */

library SafeMath {



    /**

    * @dev Multiplies two numbers, reverts on overflow.

    */

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the

        // benefit is lost if 'b' is also tested.

        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522

        if (a == 0) {

            return 0;

        }



        uint256 c = a * b;

        require(c / a == b);



        return c;

    }



    /**

    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.

    */

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0); // Solidity only automatically asserts when dividing by 0

        uint256 c = a / b;

        // assert(a == b * c + a % b); // There is no case in which this doesn't hold



        return c;

    }



    /**

    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).

    */

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a);

        uint256 c = a - b;



        return c;

    }



    /**

    * @dev Adds two numbers, reverts on overflow.

    */

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;

        require(c >= a);



        return c;

    }



    /**

    * @dev Divides two numbers and returns the remainder (unsigned integer modulo),

    * reverts when dividing by zero.

    */

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0);

        return a % b;

    }

}





/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */

contract Ownable {

    address payable public owner;



    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);



    /**

     * @dev The Ownable constructor sets the original `owner` of the contract to the sender

     * account.

     */

    constructor () internal {

        owner = msg.sender;

        emit OwnershipTransferred(address(0), owner);

    }





    /**

     * @dev Throws if called by any account other than the owner.

     */

    modifier onlyOwner() {

        require(isOwner());

        _;

    }



    /**

     * @return true if `msg.sender` is the owner of the contract.

     */

    function isOwner() public view returns (bool) {

        return msg.sender == owner;

    }



    /**

     * @dev Allows the current owner to transfer control of the contract to a newOwner.

     * @param newOwner The address to transfer ownership to.

     */

    function transferOwnership(address payable newOwner) public onlyOwner {

        _transferOwnership(newOwner);

    }



    /**

     * @dev Transfers control of the contract to a newOwner.

     * @param newOwner The address to transfer ownership to.

     */

    function _transferOwnership(address payable newOwner) internal {

        require(newOwner != address(0));

        emit OwnershipTransferred(owner, newOwner);

        owner = newOwner;

    }

}





contract x2jpCredit is Ownable {

    using SafeMath for uint256;



    uint public depositAmount;

    uint public minCreditAmount;

    uint public currentPaymentIndex;



    uint public depPercent;

    uint public ownerPercent;

    uint public jpPercent;

    uint public creditPercent;



    uint public lastWinnerPeriod;

    uint public jackpotAmount;



    uint public amountRaised;



    struct Deposit {

        address payable depositor;

        uint amount;

        uint payout;

        uint paymentTime;

        uint payoutTime;

    }



    // list of all deposites

    Deposit[] public deposits;

    // list of user deposits

    mapping (address => uint[]) public depositors;



    struct Credit {

        address payable creditor;

        uint amount;

        uint payout;

        uint paid;

    }



    struct CreditPayout {

        address creditor;

        uint payout;

        uint paymentTime;

    }



    Credit[] public credits;

    CreditPayout[] public creditPayouts;



    mapping (address => uint[]) public creditors;

    uint public currentCreditIndex;



    mapping(address => address payable) public userReferral;



    bool public paused;

    uint public betPeriod;

    uint public lastPayoutTime;

    uint public lastDepId;



    struct Jack {

        address winner;

        uint amount;

        uint time;

    }



    Jack public lastJack;



    event OnDepositReceived(address investorAddress, uint value);

    event OnPaymentSent(address investorAddress, uint value);

    event OnCreditReceived(address investorAddress, uint value);

    event OnCreditPaid(address investorAddress, uint value);

    event OnJackpotAdd(uint value);



    constructor () public {

        depositAmount = 10000000000000000; // 0.01 eth

        minCreditAmount = 10000000000000000;

        depPercent = 130;

        ownerPercent = 10;

        jpPercent = 10;

        creditPercent = 120;

        lastWinnerPeriod = 1800;

        betPeriod = 1800;

    }





    function () external payable {

        if (msg.value > 0) {

            uint betsCount = msg.value.div(depositAmount);

            uint weiAmount =  depositAmount.mul(betsCount);

            uint _diff = msg.value.sub(weiAmount);



            if (_diff > 0) {

                msg.sender.transfer(_diff);

            }



            payoutJackpot(weiAmount);

            if (!paused) {

                makeDeposit(weiAmount, betsCount);

            } else {

                msg.sender.transfer(weiAmount);

            }

        } else {

            payDeposits(0);

            payoutJackpot(0);

        }

    }





    function makeDeposit(uint weiAmount, uint betsCount) internal {

        require(weiAmount >= depositAmount);

        require(!paused);

        //        payout();



        amountRaised = amountRaised.add(weiAmount);

        owner.transfer(weiAmount.mul(ownerPercent).div(100));



        address payable referrer = bytesToAddress(msg.data);

        if (referrer != msg.sender) userReferral[msg.sender] = referrer;



        if (userReferral[msg.sender] != address(0)) {

            userReferral[msg.sender].transfer(weiAmount.mul(5).div(100));

        }



        if (credits.length > 0 && currentCreditIndex < credits.length) {

            uint val = weiAmount.mul(jpPercent).div(100);



            for (uint i = currentCreditIndex; i < credits.length && val > 0; i++) {

                if (credits[i].payout > credits[i].paid) {



                    uint payout;



                    if (credits[i].paid.add(val) <= credits[i].payout) {

                        payout = val;

                        val = 0;

                        credits[i].creditor.send(payout);

                        credits[i].paid = credits[i].paid.add(payout);

                        CreditPayout memory newCreditPayout = CreditPayout(credits[i].creditor, payout, now);

                        creditPayouts.push(newCreditPayout);



                    } else {

                        payout = credits[i].payout.sub(credits[i].paid);

                        val = val.sub(payout);

                        credits[i].creditor.send(payout);

                        credits[i].paid = credits[i].paid.add(payout);

                        CreditPayout memory newCreditPayout = CreditPayout(credits[i].creditor, payout, now);

                        creditPayouts.push(newCreditPayout);

                    }



                    if (credits[i].paid == credits[i].payout) {

                        currentCreditIndex += 1;

                    }



                    emit OnCreditPaid(credits[i].creditor, payout);

                }



            }



            if (val > 0) {

                jackpotAmount = jackpotAmount.add(val);

                emit OnJackpotAdd(val);

            }



        } else {

            uint jpVal = weiAmount.mul(jpPercent).div(100);

            jackpotAmount = jackpotAmount.add(jpVal);

            emit OnJackpotAdd(jpVal);

        }







        for (uint i = 0; i < betsCount; i++) {

            uint paymentTime = now + i * betPeriod;

            Deposit memory newDeposit = Deposit(msg.sender, depositAmount, depositAmount.mul(depPercent).div(100), paymentTime, 0);

            deposits.push(newDeposit);

            depositors[msg.sender].push(deposits.length - 1);

            emit OnDepositReceived(msg.sender, depositAmount);



            if (paymentTime > lastPayoutTime) {

                lastPayoutTime = paymentTime;

                lastDepId = deposits.length - 1;

            }

        }



        payDeposits(0);

    }





    function payDeposits(uint _iterations) public{

        _iterations = _iterations == 0 ? deposits.length: _iterations;



        bool changePaymentIndex = true;



        for (uint i = currentPaymentIndex;

            i < _iterations && address(this).balance.sub(jackpotAmount) >= deposits[i].payout;

            i++)

        {

            if (deposits[i].paymentTime <= now && deposits[i].payoutTime == 0) {

                deposits[i].payoutTime = now;

                deposits[i].depositor.send(deposits[i].payout);

                emit OnPaymentSent(deposits[i].depositor, deposits[i].payout);

            } else {

                changePaymentIndex = false;

            }



            if (changePaymentIndex) currentPaymentIndex += 1;

        }

    }





    function payoutJackpot(uint weiAmount) internal {

        if (deposits.length > 0 && lastPayoutTime + lastWinnerPeriod < now && jackpotAmount > 0) {

            uint val = jackpotAmount;

            jackpotAmount = 0;



            deposits[lastDepId].payoutTime = now;

            deposits[lastDepId].payout = val;

            deposits[lastDepId].depositor.send(val);

            emit OnPaymentSent(deposits[lastDepId].depositor, val);

            currentPaymentIndex = deposits.length; //if need pay jp + dep set to deposits.length -1

            owner.transfer(address(this).balance - weiAmount);



            lastJack.winner =  deposits[lastDepId].depositor;

            lastJack.amount = val;

            lastJack.time = now;

            lastDepId = 0;

            paused = true;

        }

    }





    function getDepositsCount() public view returns (uint) {

        return deposits.length;

    }



    function lastDepositId() public view returns (uint) {

        return deposits.length - 1;

    }



    function getDeposit(uint _id) public view returns (address, uint, uint, uint, uint){

        return (deposits[_id].depositor, deposits[_id].amount, deposits[_id].payout,

        deposits[_id].paymentTime, deposits[_id].payoutTime);

    }



    function getUserDepositsCount(address depositor) public view returns (uint) {

        return depositors[depositor].length;

    }



    function getUserDeposit(address depositor, uint depositNumber) public view returns(uint, uint, uint, uint, bool) {

        bool nulled;

        if (deposits[depositors[depositor][depositNumber]].payoutTime == 0

        && depositors[depositor][depositNumber] < currentPaymentIndex) nulled = true;



        return (deposits[depositors[depositor][depositNumber]].amount,

        deposits[depositors[depositor][depositNumber]].payout,

        deposits[depositors[depositor][depositNumber]].paymentTime,

        deposits[depositors[depositor][depositNumber]].payoutTime,

        nulled);

    }





    function getUserCreditsCount(address creditor) public view returns (uint) {

        return creditors[creditor].length;

    }



    function getUserCredit(address creditor, uint creditNumber) public view returns(uint, uint, uint) {

        return (credits[creditors[creditor][creditNumber]].amount,

        credits[creditors[creditor][creditNumber]].payout,

        credits[creditors[creditor][creditNumber]].paid);

    }



    // lastIndex from the end of payments lest (0 - last payment), returns: address of depositor, payment time, payment amount

    function getPayment(uint lastIndex) public view returns (address, uint, uint, uint, uint) {

        uint depositIndex = currentPaymentIndex.sub(lastIndex + 1);



        return (deposits[depositIndex].depositor,

        deposits[depositIndex].amount,

        deposits[depositIndex].payout,

        deposits[depositIndex].paymentTime,

        deposits[depositIndex].payoutTime);

    }





    function getLastTenPayments() public view returns (

        address[] memory dprs, uint[] memory paymentTime, uint[] memory payouts, uint )

    {



        dprs = new address[](10);

        paymentTime = new uint[](10);

        payouts = new uint[](10);



        uint counter;

        for (uint i = 0; counter < 10 && currentPaymentIndex - i > 0; i++) {

            uint depositIndex = currentPaymentIndex.sub(i + 1);

            if (deposits[depositIndex].payoutTime != 0) {

                dprs[i] = deposits[depositIndex].depositor;

                paymentTime[i] = deposits[depositIndex].paymentTime;

                payouts[i] = deposits[depositIndex].payout;

                counter++;

            }

        }



        return (dprs, paymentTime, payouts, currentPaymentIndex);

    }



    function getNextTenPayouts() public view returns (address[] memory dprs, uint[] memory payouts, uint[] memory payoutsTime, uint) {

        dprs = new address[](300);

        payouts = new uint[](300);

        payoutsTime = new uint[](300);

        for (uint i = 0; i < 300 && currentPaymentIndex + i < deposits.length; i++) {

            dprs[i] = deposits[currentPaymentIndex + i].depositor;

            payouts[i] = deposits[currentPaymentIndex + i].payout;

            payoutsTime[i] = deposits[currentPaymentIndex + i].paymentTime;

        }



        return (dprs, payouts, payoutsTime, currentPaymentIndex);

    }



    function getLastTenCreditPayments() public view returns (

        address[] memory crds, uint[] memory paymentTime, uint[] memory payouts, uint )

    {



        crds = new address[](10);

        paymentTime = new uint[](10);

        payouts = new uint[](10);





        for (uint i = 0; i < 10 && creditPayouts.length - i > 0 ; i++) {

            uint payoutIndex = creditPayouts.length - (i + 1);

            crds[i] = creditPayouts[payoutIndex].creditor;

            paymentTime[i] = creditPayouts[payoutIndex].paymentTime;

            payouts[i] = creditPayouts[payoutIndex].payout;

        }



        return (crds, paymentTime, payouts, creditPayouts.length);

    }



    function getNextTenCreditPayouts() public view returns (address[] memory crds, uint[] memory crdsAmounts, uint[] memory paid, uint[] memory payouts, uint) {

        crds = new address[](10);

        crdsAmounts = new uint[](10);

        paid = new uint[](10);

        payouts = new uint[](10);

        for (uint i = 0; i < 10 && currentCreditIndex + i < credits.length; i++) {

            crds[i] = credits[currentCreditIndex + i].creditor;

            crdsAmounts[i] = credits[currentCreditIndex + i].amount;

            paid[i] = credits[currentCreditIndex + i].paid;

            payouts[i] = credits[currentCreditIndex + i].payout;

        }



        return (crds, crdsAmounts, paid, payouts, currentCreditIndex);

    }





    function getLastJack() public view returns (address, uint, uint) {

        return (lastJack.winner, lastJack.amount, lastJack.time);

    }



    //_interval in seconds

    function setLastWinnerPeriod(uint _interval) onlyOwner public {

        require(_interval > 0);

        lastWinnerPeriod = _interval;

    }





    function addJP(address payable _creditor) public payable returns (bool) {

        require(msg.value >= minCreditAmount);

        uint op = msg.value.mul(ownerPercent).div(100);

        owner.transfer(op);



        jackpotAmount = jackpotAmount.add(msg.value.sub(op));

        Credit memory newCredit = Credit(_creditor, msg.value, msg.value.mul(creditPercent).div(100), 0);

        credits.push(newCredit);



        creditors[_creditor].push(credits.length - 1);

        emit OnCreditReceived(_creditor, msg.value);



        return true;

    }







    function bytesToAddress(bytes memory bys) private pure returns (address payable addr) {

        assembly {

            addr := mload(add(bys, 20))

        }

    }



    function start() onlyOwner public {

        paused = false;

    }

}





contract addJp {

    x2jpCredit public gameContract;



    constructor(address payable _gameContract) public {

        gameContract = x2jpCredit(_gameContract);

    }



    function() external payable {

        if (msg.value > 0) {

            require(gameContract.addJP.value(msg.value)(msg.sender));

        }

    }

}
