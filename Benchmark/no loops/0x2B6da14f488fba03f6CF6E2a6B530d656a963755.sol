/**
 *Submitted for verification at Etherscan.io on 2020-09-12
*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.5 <0.7.17;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface MasterChef {
    function userInfo(uint, address) external view returns (uint, uint);
}

contract HUBDAO {

    IERC20 public constant votes = IERC20(0x75B62D9Fb187704AdfC49d3e8aEB5BBE508aB8E1);
    MasterChef public constant chef = MasterChef(0x069aE2af79903198A65b63811c2e053eabAB1C15);
    uint public constant pool = uint(1);

    function decimals() external pure returns (uint8) {
        return uint8(18);
    }

    function name() external pure returns (string memory) {
        return "HUBDAO";
    }

    function symbol() external pure returns (string memory) {
        return "HUB";
    }

    function totalSupply() external view returns (uint) {
        return votes.totalSupply();
    }

    function balanceOf(address _voter) external view returns (uint) {
        (uint _votes,) = chef.userInfo(pool, _voter);
        return _votes;
    }

    constructor() public {}

}