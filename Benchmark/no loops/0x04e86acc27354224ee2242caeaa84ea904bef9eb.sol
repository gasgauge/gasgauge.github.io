//pragma solidity >=0.6 <0.7.0;
pragma solidity >=0.5 <0.7.17;

contract MockRateQuoter {

    address constant private WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    function quotePrice(address asset) external returns (uint256 rate, uint256 updatedAt) {
        require(asset == WETH, "WETH supported only");
        rate = 1e18;
        updatedAt = now;
    }
}
