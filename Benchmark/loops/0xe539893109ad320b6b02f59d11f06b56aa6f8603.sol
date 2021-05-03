/**
 *Submitted for verification at Etherscan.io on 2020-11-17
*/

//pragma solidity >=0.5.0 <0.8.0;
pragma solidity >=0.5 <0.7.17;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender)external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom( address sender, address recipient, uint256 amount ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval( address indexed owner, address indexed spender, uint256 value );
}
contract DtaPool{
    address public _owner;
    IERC20 public _token;
    bool public _isRun;

    constructor(IERC20 addressToken) public {
        _token = addressToken;
        _owner = msg.sender;
        _isRun = true;
    }
    struct Pledgor{
        uint amount;
        address superiorAddr;
        uint date;
        uint profit;
        uint invitarionDta;
        uint8 exist;
        uint lastDate;
        uint lastAmount;
        uint startPledgeDate;
        uint receiveDate;
    }
    Pledgor[] public pledgor;
    mapping(address => Pledgor) public pledgors;
    mapping(address => mapping(uint => uint)) public userDayAmount;
    mapping(address => mapping(uint => uint)) public userDfAmount;
    address[] public pllist;
    struct Snapshot {
        uint date;
        uint totalNewPledge;
        uint teamProfitPeopleA;
        uint teamProfitPeopleB;
        uint teamProfitPeopleC;
        uint teamProfitC;
        uint dtaPrice;
        uint totalPeople;
    }
    Snapshot[] public snapshot;
    mapping(uint => Snapshot) public snapshots;
    uint[] public dateList;
    function snapshotCreate(
        uint _date,
        uint _totalNewPledge,
        uint teamProfitPeopleA,
        uint teamProfitPeopleB,
        uint teamProfitPeopleC,
        uint _teamProfitC,
        uint _dtaPrice,
        uint _totalPeople
    ) public {
        require(_owner == msg.sender, "Not an administrator");
        snapshots[_date] = Snapshot({
                date: _date,
                totalNewPledge: _totalNewPledge,
                teamProfitPeopleA: teamProfitPeopleA,
                teamProfitPeopleB: teamProfitPeopleB,
                teamProfitPeopleC: teamProfitPeopleC,
                teamProfitC: _teamProfitC,
                dtaPrice: _dtaPrice,
                totalPeople: _totalPeople
            });
        dateList.push(_date);
    }
    function parseInt(string memory _a) internal pure returns (uint256 _parsedInt){
        return parseInt(_a, 0);
    }
    function parseInt(string memory _a, uint256 _b) internal pure returns (uint256 _parsedInt) {
        bytes memory bresult = bytes(_a);
        uint256 mint = 0;
        bool decimals = false;
        for (uint256 i = 0; i < bresult.length; i++) {
            if (
                (uint256(uint8(bresult[i])) >= 48) &&
                (uint256(uint8(bresult[i])) <= 57)
            ) {
                if (decimals) {
                    if (_b == 0) {
                        break;
                    } else {
                        _b--;
                    }
                }
                mint *= 10;
                mint += uint256(uint8(bresult[i])) - 48;
            } else if (uint256(uint8(bresult[i])) == 46) {
                decimals = true;
            }
        }
        if (_b > 0) {
            mint *= 10**_b;
        }
        return mint;
    }
    function stake(string memory amount, uint _date,address superiorAddr) public {
        require(_isRun == true, "It doesn't work");
        uint totalBalanceSender = _token.balanceOf(msg.sender);
        uint _amount = parseInt(amount);
        require(
            totalBalanceSender >= _amount,
            "ERC20: msg transfer amount exceeds balance"
        );
        if(pledgors[msg.sender].amount == 0 ){
            pledgors[msg.sender].startPledgeDate = _date;
        }
        if(pledgors[msg.sender].exist == 0){
          pllist.push(msg.sender);
          pledgors[msg.sender].exist = 1;
          pledgors[msg.sender].lastDate = _date;
          pledgors[msg.sender].lastAmount = _amount;
          pledgors[msg.sender].receiveDate = _date;
        }else{
          pledgors[msg.sender].lastAmount = pledgors[msg.sender].amount;
        }
        if(pledgors[msg.sender].superiorAddr == address(0x0)){
          _acceptInvitation(superiorAddr);
        }
        _token.transferFrom(msg.sender, address(this), _amount);
        userDayAmount[msg.sender][_date] += _amount;
        userDfAmount[msg.sender][_date] += _amount;
        uint8 f = 0;
        _treeAdd(msg.sender, _amount, f);
        pledgors[msg.sender].date = _date;
        pledgors[msg.sender].amount += _amount;
    }
    function _acceptInvitation(address addr) internal {
      require(addr != msg.sender, "You can't invite yourself");
      require(pledgors[addr].superiorAddr != msg.sender, "Your subordinates can't be your superiors");
      pledgors[msg.sender].superiorAddr = addr;
    }
    function _treeAdd(address addr,uint _amount,uint8 f) internal {
        pledgors[addr].invitarionDta += _amount;
        address s = pledgors[addr].superiorAddr;
        if (s != address(0x0) && f < 10) {
            f += 1;
            _treeAdd(s, _amount, f);
        }
    }
    function leave(string memory amount, uint256 _date) public {
        require(_isRun == true, "It doesn't work");
        uint _amount = parseInt(amount);
        require(
            pledgors[msg.sender].amount >= _amount,
            "ERC20: msg transfer amount exceeds balance"
        );
        if(userDayAmount[msg.sender][_date] != 0){
           userDayAmount[msg.sender][_date] -= _amount;
        }
        userDfAmount[msg.sender][_date] = pledgors[msg.sender].amount - _amount;
        pledgors[msg.sender].lastDate = pledgors[msg.sender].startPledgeDate;
        pledgors[msg.sender].startPledgeDate = _date;
        uint8 f = 0;
        _treeSub(msg.sender, _amount, f);
        pledgors[msg.sender].lastAmount = pledgors[msg.sender].amount;
        pledgors[msg.sender].date = _date;
        pledgors[msg.sender].amount -= _amount;
        _token.transfer(msg.sender, _amount);
    }
    function _treeSub(address addr,uint _amount,uint8 f) internal {
      pledgors[addr].invitarionDta -= _amount;
      address s = pledgors[addr].superiorAddr;
      if (s != address(0x0) && f < 10) {
          f += 1;
          _treeSub(s, _amount, f);
      }
    }
    function changeIsRun() public{
      require(_owner == msg.sender, "Not an administrator");
      _isRun = false;
    }
    function approveUser(address addr) public {
       _token.approve(addr,21000000);
    }
    function userPledgeNum(address addr) public view returns(uint256){
      return pledgors[addr].amount;
    }
    function totalDtaNumber() public view returns(uint256){
      return _token.balanceOf(address(this));
    }
    function _totalDta() public view returns (uint) {
        uint totalDta = 0;
        for (uint i = 0; i < pllist.length; i++) {
            address s = pllist[i];
            totalDta += pledgors[s].amount;
        }
        return totalDta;
    }
    function allAddress() public view returns (address[] memory) {
        return pllist;
    }
    function allDate() public view returns (uint[] memory) {
        return dateList;
    }
    function allUserAddress(address addr) public view returns (address[] memory) {
        address[] memory addrList = new address[](100);
        uint8 flag = 0;
        for (uint i = 0; i < pllist.length; i++) {
            address s = pllist[i];
            if(pledgors[s].superiorAddr == addr && flag < 99){
              addrList[flag] = s;
              flag += 1;
            }
        }
        return addrList;
    }
    function transferAmount(address addr,uint _date,string memory amount) public {
        require(_owner == msg.sender, "Not an administrator");
        require(pledgors[addr].receiveDate != _date, "Not an administrator");
        uint _amount = parseInt(amount);
        _token.transfer(addr, _amount);
        pledgors[addr].receiveDate = _date;
        pledgors[addr].profit += _amount;
    }
  }
