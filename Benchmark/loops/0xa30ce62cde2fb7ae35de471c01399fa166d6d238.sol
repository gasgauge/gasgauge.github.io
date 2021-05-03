/**
 *Submitted for verification at Etherscan.io on 2020-09-02
*/

//pragma solidity ^0.5.17;
pragma solidity >=0.5 <0.7.17;

interface IERC20Token {
    function balanceOf(address owner) external returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function decimals() external returns (uint256);
    function approve(address _spender, uint256 _value) external returns (bool);
    function allowance(address _tokenholder, address _spender) external view returns (uint256 remaining);
}

interface IUSDTToken {
    function transferFrom(address from, address to, uint256 value) external;
    function transfer(address to, uint256 amount) external;
    function balanceOf(address owner) external returns (uint);
}

contract WDXStacking {
    IERC20Token public tokenContract;  // the token being sold
    IUSDTToken public usdtTokenContract;
    uint public wdx_price;
    address owner;
    struct Status {
        uint price;
        uint limit;
        uint referal_lines;
    }

    mapping (uint8 => Status) public statuses;

    struct Stake {
        uint256 start_time;
        uint256 amount;

        uint256 week_starts_at;
        uint256 week_withdrawal_amount;
        uint256 last_withdrawal_time;

        uint256 last_compute_time;
        uint256 last_percent;
        uint256 pure_profit;

        uint8 status;
    }

    mapping (address => Stake) public stakes;


    constructor(IERC20Token _tokenContract, IUSDTToken _usdtTokenContract) public {
        owner = msg.sender;
        tokenContract = _tokenContract;
        usdtTokenContract = _usdtTokenContract;

        // status price, status limit in $, referral line limit
        statuses[0] = Status(0, 10000000, 1);
        statuses[1] = Status(100000000, 50000000, 2);
        statuses[2] = Status(300000000, 150000000, 3);
        statuses[3] = Status(1000000000, 500000000, 5);
        statuses[4] = Status(3000000000, 1500000000, 7);
        statuses[5] = Status(10000000000, 5000000000, 10);

        wdx_price = 1000000; // 1$
    }

    // Guards against integer overflows
    function safeMultiply(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        } else {
            uint256 c = a * b;
            assert(c / a == b);
            return c;
        }
    }

    function safeDivision(uint256 a, uint256 b) internal pure returns(uint256) {
        assert(b > 0);
        uint256 c = a / b;
        assert(a == b * c + a % b);
        return c;
    }

    function computeAmount() internal returns(bool) {
        uint256 stake_amount = stakes[address(msg.sender)].amount;
        uint256 stake_start_time = stakes[address(msg.sender)].start_time;
        uint256 stake_last_compute_time = stakes[address(msg.sender)].last_compute_time;
        uint256 profit_percent = 6; //0.6%
        uint256 duration_from_last_compute= safeDivision(now - stake_last_compute_time, 86400); // in days
        if (duration_from_last_compute < 1) {
            return false;
        }

        // Duration additional profit percent
        uint256 stake_duration = safeDivision(now - stake_start_time, 2592000); // devide 30 days
        if (stake_duration >= 1) {
            profit_percent += 1;
        }
        if (stake_duration >= 3) {
            profit_percent += 1;
        }
        if (stake_duration >= 6) {
            profit_percent += 1;
        }
        if (stake_duration >= 12) {
            profit_percent += 1;
        }
        if (stake_duration >= 18) {
            profit_percent += 1;
        }
        // Amount additional profit percent
        if (stake_amount >= 100000000000000000000000) {
            profit_percent += 1;
        }
        if (stake_duration >= 200000000000000000000000) {
            profit_percent += 1;
        }
        if (stake_duration >= 1000000000000000000000000) {
            profit_percent += 1;
        }
        if (stake_duration >= 2000000000000000000000000) {
            profit_percent += 1;
        }

        if (profit_percent > 20) {
            profit_percent = 20;
        }

        //uint256 profit_per_day = safeDivision(safeMultiply(profit_percent, stake_amount), 1000); // in wdx
        //uint256 profit_from_last_compute = safeMultiply(profit_per_day, duration_from_last_compute);
        //stakes[address(msg.sender)].amount = profit_from_last_compute + stake_amount;
        stakes[address(msg.sender)].last_compute_time = now;
        stakes[address(msg.sender)].last_percent = profit_percent;

        // Compound profit
        //stakes[address(msg.sender)].amount = safeMultiply(stake_amount, (1+0)**duration_from_last_compute);
        for (uint i=0; i< duration_from_last_compute; i++) {
            uint256 profit = safeDivision(safeMultiply(profit_percent, stakes[address(msg.sender)].amount), 1000);
            stakes[address(msg.sender)].amount += profit;
            stakes[address(msg.sender)].pure_profit += profit;
        }

    }

    function buyStatus(uint8 status, address[] memory referrals) public returns(bool) {
        require(status > stakes[address(msg.sender)].status, "Status already bought. Or attemption to buy lower status");

        uint delta_amount = statuses[status].price - statuses[stakes[address(msg.sender)].status].price;
        uint256 residue = delta_amount;
        uint[10] memory ref_parts = [uint(200), 100, 50, 30, 20, 20, 20, 20, 20, 20];
        for (uint i=0; i<referrals.length; i++) {
            uint256 amount_to_send = safeDivision(safeMultiply(delta_amount, ref_parts[i]), 1000);
            usdtTokenContract.transferFrom(msg.sender, address(referrals[i]), amount_to_send);
            residue -= amount_to_send;
        }
        if (residue > 0) {
            usdtTokenContract.transferFrom(msg.sender, address(this), residue);
        }
        stakes[address(msg.sender)].status = status;
        return true;
    }

    function sendToStaking(uint256 numberOfTokens) public returns(bool) {
        require(numberOfTokens > 0, "You need to sell at least some tokens");

        uint256 allowance = tokenContract.allowance(msg.sender, address(this));
        require(allowance >= numberOfTokens, "Check the token allowance");


        tokenContract.transferFrom(msg.sender, address(this), numberOfTokens);
        if (stakes[address(msg.sender)].amount > 0) {
            computeAmount();
            stakes[address(msg.sender)].amount = stakes[address(msg.sender)].amount + numberOfTokens;
            return true;
        }
        stakes[address(msg.sender)] = Stake(
            now, //start_time
            numberOfTokens, //amount

            now, //week_starts_at
            0, //week_withdrawal_amount
            now , //last_withdrawal_time

            now, //last_compute_time
            0, //last_percent
            0, //pure_profit
            stakes[address(msg.sender)].status //status
        );
        return true;
    }

    function set_valid_amount_by_status(uint256 numberOfTokens) internal returns(uint256) {
        uint8 status = stakes[address(msg.sender)].status;
        uint usd_amount = safeDivision(safeMultiply(numberOfTokens, wdx_price), 10**18);
        uint week = 604800;

        if (now - stakes[address(msg.sender)].week_starts_at > week) {
            stakes[address(msg.sender)].week_withdrawal_amount = 0;
            uint weeks_count_from_last = safeDivision(now - stakes[address(msg.sender)].week_starts_at, week);
            stakes[address(msg.sender)].week_starts_at += safeMultiply(week, weeks_count_from_last);
        }

        if (stakes[address(msg.sender)].week_withdrawal_amount + usd_amount > statuses[status].limit) {
            usd_amount = statuses[status].limit - stakes[address(msg.sender)].week_withdrawal_amount;
        }
        require(usd_amount > 0, "Limit is exceeded");
        return usd_amount;
    }

    function getFromStaking(uint256 numberOfTokens) public returns(bool) {
        require(numberOfTokens > 0, "You need to get at least some tokens");

        computeAmount();

        uint usd_amount = set_valid_amount_by_status(numberOfTokens);
        numberOfTokens = safeDivision(safeMultiply(usd_amount, 10**18), wdx_price);

        tokenContract.transfer(address(msg.sender), numberOfTokens);

        stakes[address(msg.sender)].last_withdrawal_time = now;
        stakes[address(msg.sender)].amount = stakes[address(msg.sender)].amount - numberOfTokens;
        stakes[address(msg.sender)].week_withdrawal_amount += usd_amount;
        return true;
    }

    function getUSDT() public {
        require(msg.sender == owner);

        // Send unsold tokens to the owner.
        usdtTokenContract.transfer(owner, usdtTokenContract.balanceOf(address(this)));
    }

    function updateWDXPrice(uint price) public {
        require(msg.sender == owner);
        wdx_price = price;
    }

    function setStatusByAdmin(uint8 status, address user) public {
        require(msg.sender == owner);
        stakes[user].status = status;
    }

}
