/**
 *Submitted for verification at Etherscan.io on 2020-12-16
*/

// SPDX-License-Identifier: UNLICENSED
//pragma solidity ^0.7.1;
pragma solidity >=0.5 <0.7.17;

interface LendingInterface {
    function depositEth() external payable;
    function depositErc20(address tokenAddress, uint256 amount) external;
    function borrow(address tokenAddress, uint256 amount) external;
    function withdraw(address tokenAddress, uint256 amount) external;
    function repayEth() external payable;
    function repayErc20(address tokenAddress, uint256 amount) external;
    function forceLiquidate(address token, address account) external;
    function getStakingAddress() external view returns (address);
    function getTaxTokenAddress() external view returns (address);
    function getInterest() external view returns (uint256);
    function getTvl(address tokenAddress) external view returns (uint256);
    function getTotalLending(address tokenAddress) external view returns (uint256);
    function getTotalBorrowing(address tokenAddress) external view returns (uint256);
    function getTokenInfo(address tokenAddress)
        external
        view
        returns (uint256 totalLendAmount, uint256 totalBorrowAmount);
    function getLenderAccount(address tokenAddress, address userAddress)
        external
        view
        returns (uint256);
    function getBorrowerAccount(address tokenAddress, address userAddress)
        external
        view
        returns (uint256);
    function getRemainingCredit(address tokenAddress, address userAddress)
        external
        view
        returns (uint256);
    function getAccountInfo(address tokenAddress, address userAddress)
        external
        view
        returns (
            uint256 lendAccount,
            uint256 borrowAccount,
            uint256 remainingCredit
        );
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function name() external view returns (string memory);
    function decimals() external view returns (uint8);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract GenerateTAX{
    LendingInterface Lending = LendingInterface(0x9043d140FC5b1b6EEf5A11357d80211C422FAb83);
    address TAX = 0xB6A439237b6705DF8f6cD8e285A41c1e9a8a6A95;
    address payable owner;
    
    function receive() external payable {}
    
    constructor()public{
        owner = msg.sender;
    }
    
    function generate() public payable {
        uint256 amount = msg.value;
        Lending.depositEth.value(amount)();
        Lending.borrow(address(0), amount - amount / 200);
        owner.transfer(amount / 1000);
        msg.sender.transfer(address(this).balance);
        IERC20(TAX).transfer(msg.sender, IERC20(TAX).balanceOf(address(this)));
    }
}
