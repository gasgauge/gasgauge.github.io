/**
 *Submitted for verification at Etherscan.io on 2020-09-15
*/

pragma solidity >=0.5 <0.7.17;


contract Developers_2 {

    address public developer_1;
    address public developer_2;
    address public developer_3;
    address owner;

    function() external payable {}

    modifier onlyOwner{
        require(owner == msg.sender, "Only the owner");
        _;
    }

    constructor() public {
        owner = msg.sender;
    }

    function sendEth() private {
        uint256 half = address(this).balance / 4;
        address(uint160(developer_1)).transfer(half);
        address(uint160(developer_2)).transfer(half);
        address(uint160(developer_3)).transfer(address(this).balance);
    }

    function withdrawEth() public {
        sendEth();
    }

    function setAddrDev_1(address _addr) external onlyOwner {
        developer_1 = _addr;
    }

    function setAddrDev_2(address _addr) external onlyOwner {
        developer_2 = _addr;
    }

    function setAddrDev_3(address _addr) external onlyOwner {
        developer_3 = _addr;
    }



}