/**
 *Submitted for verification at Etherscan.io on 2020-09-13
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

interface MasterStar {
    function userInfo(uint, address) external view returns (uint, uint);
}

contract MoonVoterProxy {

    IERC20 public constant votes = IERC20(0x8927616110cf23c4e87dc98614eB9FBaAE95216C);
    MasterStar public constant master = MasterStar(0xb60C12D2a4069D339f49943fc45df6785B436096);
    uint public constant pool = uint(2);

    function decimals() external pure returns (uint8) {
        return uint8(18);
    }

    function name() external pure returns (string memory) {
        return "MOONEVD";
    }

    function symbol() external pure returns (string memory) {
        return "MOON";
    }

    function totalSupply() external view returns (uint) {
        return votes.totalSupply();
    }

    function balanceOf(address _voter) external view returns (uint) {
        (uint _votes,) = master.userInfo(pool, _voter);
        return _votes;
    }

    constructor() public {}

}