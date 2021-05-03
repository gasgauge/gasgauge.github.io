/**
 *Submitted for verification at Etherscan.io on 2020-12-16
*/

//pragma solidity ^0.5.0;
pragma solidity >=0.5 <0.7.17;

interface UniswapV2PairLike {
    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );
}
contract UniForRewardCheckerBase {
    mapping(address => bool) public tokens;

    function check(address gem) external {
        address t0 = UniswapV2PairLike(gem).token0();
        address t1 = UniswapV2PairLike(gem).token1();

        require(tokens[t0] && tokens[t1], "non-approved-stable");
    }
}

contract UniForRewardCheckerMainnet is UniForRewardCheckerBase {
    constructor(address usdfl, address gov) public {
        tokens[usdfl] = true;
        tokens[gov] = true;
        tokens[0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48] = true; //usdc
        tokens[0xdAC17F958D2ee523a2206206994597C13D831ec7] = true; //usdt
        tokens[0x6B175474E89094C44Da98b954EedeAC495271d0F] = true; //dai
        tokens[0x674C6Ad92Fd080e4004b2312b45f796a192D27a0] = true; //usdn
    }
}
