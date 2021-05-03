/**
 *Submitted for verification at Etherscan.io on 2020-09-18
*/

//pragma solidity^0.7.0;
pragma solidity >=0.5 <0.7.17;

interface IUniswapV2Factory {
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);
}

interface IUniswapV2Pair {
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

contract Pairs {
    
    function allPairs() external view returns (
        address[] memory pairs,
        address[] memory tokens0, 
        address[] memory tokens1, 
        uint112[] memory reserves0, 
        uint112[] memory reserves1) {
     
        IUniswapV2Factory uniswapv2factory = IUniswapV2Factory(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f);
        uint count                         = uniswapv2factory.allPairsLength();
        pairs                              = new address[](count);
        tokens0                            = new address[](count);
        tokens1                            = new address[](count);
        reserves0                          = new uint112[](count);
        reserves1                          = new uint112[](count);
        uint32  dummy;
        
        for (uint i = 0; i < count; i++) {
            IUniswapV2Pair pair                 = IUniswapV2Pair(uniswapv2factory.allPairs(i));
            pairs[i]                            = address(pair);
            tokens0[i]                          = pair.token0();
            tokens1[i]                          = pair.token1();
            (reserves0[i], reserves1[i], dummy) = pair.getReserves();
        }
    }
}
