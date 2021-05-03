/**
 *Submitted for verification at Etherscan.io on 2019-07-16
*/

//pragma solidity >=0.4.23;
pragma solidity >=0.5 <0.7.17;

contract Math {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, "add overflow");
    }
    
    function sub(uint x, uint y) internal pure returns(uint z) {
        require((z = x - y) <= x, "sub underflow");
    }
}

contract Owable {
    
    address private owner;
    
    constructor() public {
        owner = msg.sender;
    }
    
    modifier isOwable() {
        require(owner == msg.sender, "not owner");
        _;
    }
    
    function changeOwner(address _newOwner) public isOwable {
        owner = _newOwner;
    }
}

contract Stop is Owable {
    
    bool public stopped;
    
    modifier isRun() {
        require(!stopped, "stopping");
        _;                                                                                                                                                               
    }
    
    function stop() public isOwable {
        stopped = true;
    }
    
    function start() public isOwable {
        stopped = false;
    }
}

contract SupplyController is Owable {
    
    mapping (address => bool) private controllers;
    address[] private controllerList;
        
    modifier isController() {
        require(controllers[msg.sender], "Not a controller");
        _;
    }
    
    function setSupplyController(address _newController) public isOwable returns (bool) {
        require(!controllers[_newController], "Already is a controller");
        controllers[_newController] = true;
        controllerList.push(_newController);
        return true;
    }
    
    function getControllerList() public view isOwable returns (address[] memory) {
        return controllerList;
    }
    
    function deleteSupplyController(address _controller) public isOwable returns (bool) {
        require(controllers[_controller], "Not a controller");
        controllers[_controller] = false;
        deleteControllerFromList(_controller);
        return true;
    }

    function deleteControllerFromList(address _controller) private {
        uint length = controllerList.length;
        address[] memory newControllerList = new address[](length - 1);
        uint8 j = 0;
        for (uint i = 0; i < length; i++) {
            if (controllerList[i] != _controller) {
                newControllerList[j] = controllerList[i];
                j++;
            }
        }
        controllerList = newControllerList;
    }
}

contract QuickCash is Math, Stop, SupplyController {
    
    uint256 internal supply;
    string public constant name = "QuickCash";
    string public constant symbol = "QC";
    uint8 public constant decimals = 18;
    
    address internal income;
    
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) approvals;
    
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    
    event Loan(address indexed _receive, uint256 _value);
    event Repay(address indexed _from, uint256 _value);
    
    modifier isIncome() {
        require(msg.sender == income, "Invalid income");
        _;
    }

    function getIncome() public view isOwable returns (address) {
        return income;
    }

    function setIncome(address _newIncome) public isRun isOwable returns (bool) {
        income = _newIncome;
        return true;
    }
    
    function totalSupply() public view returns (uint256) {
        return supply;
    }
    
    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }
    
    function transfer(address _to, uint256 _value) public isRun returns (bool) {
        return transferFrom(msg.sender, _to, _value);
    }
    
    function transferFrom(address _from, address _to, uint256 _value) public isRun returns (bool) {
        require(_to != address(0));
        if (_from != msg.sender && approvals[_from][msg.sender] != uint(-1)) {
            approvals[_from][msg.sender] = sub(approvals[_from][msg.sender], _value);
        }
        balances[_from] = sub(balances[_from], _value);
        balances[_to] = add(balances[_to], _value);
        emit Transfer(_from, _to, _value);
        return true;
    }
    
    function approve(address _spender, uint256 _value) public isRun returns (bool) {
        require(_spender != address(0));
        approvals[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    
    function allowance(address _owner, address _spender) public view isRun returns (uint256) {
        return approvals[_owner][_spender];
    }
    
    function loan(address _account, uint256 _value, uint256 _charge) public isRun isController returns (bool) {
        require(_account != address(0));
        uint256 loanNum = _value;
        if (income != address(0)) {
            balances[income] = add(balances[income], _charge);
            loanNum = sub(_value, _charge);
        }
        balances[_account] = add(balances[_account], loanNum);
        supply = add(supply, _value);
        emit Loan(_account, loanNum);
        return true;
    }
    
    function repay(uint256 _value, uint256 _charge) public isRun returns (bool) {
        require(msg.sender != address(0));
        balances[msg.sender] = sub(balances[msg.sender], _value);
        uint256 burnNum = _value;
        if (income != address(0)) {
            balances[income] = add(balances[income], _charge);
            burnNum = sub(_value, _charge);
        }
        supply = sub(supply, burnNum);
        emit Repay(msg.sender, _value);
        return true;
    }
}
