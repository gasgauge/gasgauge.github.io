/**
 *Submitted for verification at Etherscan.io on 2020-12-21
*/

//pragma solidity >=0.4.24 <0.6.0;
pragma solidity >=0.5 <0.7.17;

interface IERC20 {
    function balanceOf(address) external view returns (uint256);
    function totalSupply() external view returns (uint256);
}

interface IUniswapV2 {
    function balanceOf(address) external view returns (uint256);
    function totalSupply() external view returns (uint256);
    function getReserves() external view returns (uint112, uint112, uint32);
}

interface IGeyser {
    function totalStakedFor(address) external view returns (uint256);
    function token() external view returns (address);
    function getDistributionToken() external view returns (address);
}

contract Voting {
    IERC20 public kMPLContract = IERC20(0xe8D17542dfe79Ff4FBd4b850f2d39DC69c4489a2);
    IERC20 public AMPLContract = IERC20(0xD46bA6D942050d489DBd938a2C909A5d5039A161);
  
    IGeyser public zeusContract = IGeyser(0x0EAdf5c82b50E3D028E0eB10CF76676432A7AD51);
    IGeyser public apolloContract = IGeyser(0x0Abfa8c10A4451Fef74Cf8DB2dEE33DDB048f79D);
    
    function getScore(address account) external view returns (uint256, uint256, uint256) {
        uint256 totalKMPL = kMPLContract.balanceOf(account);
        uint256 totalAMPL = AMPLContract.balanceOf(account);
        
        totalAMPL += getStaked(account, zeusContract);
        totalKMPL += getStaked(account, apolloContract);
        
        return (totalKMPL + totalAMPL / 1000, totalKMPL, totalAMPL);
    }
    
    function getStaked(address account, IGeyser geyser) public view returns (uint256) {
        uint256 lp = geyser.totalStakedFor(account);
        IUniswapV2 lpContract = IUniswapV2(geyser.token());
        lp += lpContract.balanceOf(account);
        
        (,uint112 reserve,) = lpContract.getReserves();
        return lp * reserve / lpContract.totalSupply();
    }
    
}
