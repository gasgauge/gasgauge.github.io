/**
 *Submitted for verification at Etherscan.io on 2020-09-12
*/

pragma solidity >=0.5 <0.7.17;

contract PV_Interface_Father {
    function Repurchase() external payable;
    function PayAnotherAccount(uint _sponsorID, address _user) external payable;
}

contract Fund_Interface {
    function Game(uint _turns) external payable;
}

contract Father {

    address public addrPayment;
    address public pv;
    address public fund;
    address owner;
    uint amount = 0.3 ether;
    uint amount_game = 0.05 ether;

    function() external payable {}

    modifier onlyOwner{
        require(owner == msg.sender, "Only the owner");
        _;
    }

    constructor() public {
        owner = msg.sender;
    }

    function changePrice(uint _price) external onlyOwner {
        amount = _price;
    }

    function setAddr(address _addr) external onlyOwner {
        addrPayment = _addr;
    }

    function setAddrpv(address payable _addr) external onlyOwner {
        pv = _addr;
    }

    function setAddrFund(address payable _addr) external onlyOwner {
        fund = _addr;
    }

    function withdrawEth() public {
        address(uint160(addrPayment)).transfer(address(this).balance);
    }

    function Repurchase() external onlyOwner {
        PV_Interface_Father(pv).Repurchase.value(amount)();
    }

    function PayAnotherAccount(uint _sponsorID, address _user) external onlyOwner {
        PV_Interface_Father(pv).PayAnotherAccount.value(amount)(_sponsorID, _user);
    }

    function Game(uint _turns) external onlyOwner {
        uint _amount = _turns * amount_game;
        Fund_Interface(fund).Game.value(_amount)(_turns);
    }

}
