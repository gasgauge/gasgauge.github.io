/**
 *Submitted for verification at Etherscan.io on 2020-10-05
*/

//pragma solidity ^0.6.0;
pragma solidity >=0.5 <0.7.17;

interface IERC20 {
    function transfer(address to, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);
    function balanceOf(address tokenOwner) external view returns (uint balance);
    function approve(address spender, uint tokens) external returns (bool success);
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function totalSupply() external view returns (uint);
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }

    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }

    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }

    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}

contract TimeLock {
    using SafeMath for uint;

    uint8 private nextSubtract;
    uint8 private nextScheduleId;
    bool public initialized;
    bool private configured;

    address[] private beneficiaries; //
    uint[] private scheduleList; //

    mapping(uint8 => uint) private schedules;
    mapping(address => mapping(address => uint)) private balances;
    mapping(address => uint) private percentages; //
    
    event NewVesting(address newVestingContract, uint indexed timeCreated);
    event Distributed(address token, address executor, uint round);
    event Withdrawn(address token, address beneficiary, uint amount);
    event EtherWithdrawn(address _addr, uint _value);
    
    modifier whenNotInitialized() {
        require(initialized == false, "Vesting has already been initialized");
        _;
    }
    
    modifier whenInitialized() {
        require(initialized == true, "Vesting has not been initialized");
        _;
    }
    
    modifier onlyBeneficiary() {
        bool isApproved = false;
        for(uint i = 0; i < beneficiaries.length; i++) {
            if (beneficiaries[i] == msg.sender) {
                isApproved = true;
            }
        }
        require(isApproved == true, "Only a beneficiary can do this");
        _;
    }
    
    function addParameters(address[] calldata _beneficiary, uint[] calldata _percentages, uint[] calldata _schedules) external whenNotInitialized {
        require(_beneficiary.length == _percentages.length, 'Beneficiary and percentage arrays must have the same length');
        require(configured == false, 'Parameters have already been added');
        uint totalPercentages;
        for(uint i = 0; i < _beneficiary.length; i++) {
            beneficiaries.push(_beneficiary[i]);
            percentages[_beneficiary[i]] = _percentages[i];
            totalPercentages = totalPercentages.add(_percentages[i]);
        }
        require(totalPercentages == 100, 'Percentages must sum up to 100');
        for(uint8 i = 0; i < _schedules.length; i++) {
            scheduleList.push(_schedules[i]);
        }
        configured = true;
    }
    
    function startVesting() external whenNotInitialized onlyBeneficiary {
         for(uint8 i = 0; i < scheduleList.length; i++) {
            schedules[i] = now + scheduleList[i];
         }
         initialized = true;
    }
    
    function nextScheduleTime() external view whenInitialized returns(uint secondsLeft){
        uint time = schedules[nextScheduleId];
        uint nextTime = time - now;
        if (time < now) {
            revert ('distribute payment for previous round');
        } else {
            return nextTime;
        }
    }
    
    function endingTime() external view whenInitialized returns(uint secondsLeft){
        uint allTime = scheduleList.length;
        uint time = schedules[uint8(allTime) - 1];
        return time - now;
        
    }

    function getSchedules() external view whenInitialized returns(uint[] memory schedule){
        return scheduleList;
    }
    
    function currentSchedule() external view whenInitialized returns(uint schedule){
        return scheduleList[nextScheduleId];
    }
    
    function getBalance(address userAddress, address tokenAddress) external view whenInitialized returns(uint){
        return balances[userAddress][tokenAddress];
    }
    
    function getBeneficiaries() external view returns(address[] memory beneficiary) {
        require(configured == true, 'Need to add beneficiaries first');
        return beneficiaries;
    }
    
    function percentageOf(address _beneficiary) external view returns(uint){
        return percentages[_beneficiary];
    }
    
    function _calculatePayment(address _beneficiary, address token, uint totalBalances) internal view returns(uint){
        uint balance = IERC20(token).balanceOf(address(this));
        require(balance > 0, 'Empty pool');
        return percentages[_beneficiary].mul(balance.sub(totalBalances)).div((scheduleList.length.sub(nextSubtract)).mul(100));
    }

    function distributePayment(address token) external whenInitialized {
        require(now >= schedules[nextScheduleId], 'Realease time not reached');
        uint totalBalances;
        for(uint i = 0; i < beneficiaries.length; i++) {
            totalBalances = totalBalances.add(balances[beneficiaries[i]][token]);
        } 
        for(uint i = 0; i < beneficiaries.length; i++){
            uint payment = _calculatePayment(beneficiaries[i], token, totalBalances);
            balances[beneficiaries[i]][token] = balances[beneficiaries[i]][token].add(payment);
        }
        nextScheduleId++; 
        nextSubtract++;
        emit Distributed(token, msg.sender, nextScheduleId);
    }
    
    function withdrawPayment(address token) external whenInitialized onlyBeneficiary returns (bool success) {
        require(balances[msg.sender][token] > 0, 'No balance to withdraw'); 
        
        uint256 amount = balances[msg.sender][token];
        
        balances[msg.sender][token] = 0;
        
        IERC20(token).transfer(msg.sender, amount);
        
        emit Withdrawn(token, msg.sender, amount);
        return true;
    }
}
