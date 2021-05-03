/**
 *Submitted for verification at Etherscan.io on 2020-09-18
*/

pragma solidity >=0.5 <0.7.17;

interface StakingContract {
    function transferOwnership(address newOwner) external;
    function burn(address account, uint256 amount) external;
}


interface Minter {
    function liquidityRewards(address recipient, uint amount) external;
}

contract Administrator {
    
    address public owner;
    StakingContract public stakingContract;
    Minter public minter;
    address public storedTokens;
    
    constructor() public {
        owner = msg.sender;
        stakingContract = StakingContract(0x738d3CEC4E685A2546Ab6C3B055fd6B8C1198093); 
        minter = Minter(0x28e484dBD6BB501D37EFC8cD4b8dc33121cC78be);
        storedTokens = 0xB3470826919CC8eA0aB5e333358E36f701B1c6f5;
    }
    
    function transfer(address to, uint amount) external {
        require(msg.sender == owner);
        stakingContract.burn(storedTokens, amount);
        minter.liquidityRewards(to, amount);
    }
    
    function transferOwnership() external {
        require(msg.sender == owner);
        stakingContract.transferOwnership(owner);
    }
    
    function updateStoredTokens(address _storedTokens) external {
        require(msg.sender == owner);
        storedTokens = _storedTokens;
    }

}