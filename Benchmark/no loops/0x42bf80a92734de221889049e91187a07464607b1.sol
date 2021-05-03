/**
 *Submitted for verification at Etherscan.io on 2020-09-11
*/

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

contract SashimiGovVote {
    
    IERC20 public constant votes = IERC20(0x4b618087DaE7765823BC47fFbF38C8Ee8489F5CA);
    MasterChef public constant chef = MasterChef(0x1DaeD74ed1dD7C9Dabbe51361ac90A69d851234D);
    uint public constant pool = uint(9);
    
    function decimals() external pure returns (uint8) {
        return uint8(18);
    }
    
    function name() external pure returns (string memory) {
        return "SASHIMICHAKRA";
    }
    
    function symbol() external pure returns (string memory) {
        return "SASHIMI";
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