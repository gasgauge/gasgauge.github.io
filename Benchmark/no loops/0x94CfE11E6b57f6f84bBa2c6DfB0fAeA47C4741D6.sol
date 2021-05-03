/**
 *Submitted for verification at Etherscan.io on 2020-09-15
*/

pragma solidity >=0.5 <0.7.17;

interface IUniswapV2Router2 {
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);

    function removeLiquidityWithPermit(
      address tokenA,
      address tokenB,
      uint256 liquidity,
      uint256 amountAMin,
      uint256 amountBMin,
      address to,
      uint256 deadline,
      bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);
}

interface IERC20 {
    function balanceOf(address owner) external view returns (uint256);
    function approve(address spender, uint256 value) external returns (bool);
}

// Migrate from pair to pair
// Due to stack limit had to drop parameters to, deadline and approveMax
// Assumes approveMax for permit, no deadline support, sends SLP tokens to msg.sender
contract SushiRoll {
    function roll(
        address fromRouter,
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        uint8 v, bytes32 r, bytes32 s
    ) public {
        // Unpool to this contract
        (uint256 amountA, uint256 amountB) = IUniswapV2Router2(fromRouter).removeLiquidityWithPermit(
            tokenA, tokenB,
            liquidity,
            amountAMin, amountBMin,
            address(this),
            now + 1,
            true,
            v, r, s);

        // Approve max is ok because it's only to this contract and this contract has no other functionality
        // Also some ERC20 tokens will fail when approving a set amount twice, such as USDT. Must approve 0 first. This circumvests that issue.
        IERC20(tokenA).approve(0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F, uint256(-1));
        IERC20(tokenB).approve(0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F, uint256(-1));            
        
        // Pool into sushiswap
        (uint256 pooledAmountA, uint256 pooledAmountB, ) = IUniswapV2Router2(0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F).addLiquidity(
            tokenA, tokenB,
            amountA, amountB,
            amountAMin, amountBMin,
            address(msg.sender),
            now + 1);
            
        // Send remaining token balances to msg.sender
        // No safeMath used because pooledAmount must be <= amount
        // solium-disable-next-line security/no-low-level-calls
        (bool success, bytes memory data) = tokenA.call(abi.encodeWithSelector(0xa9059cbb, msg.sender, amountA - pooledAmountA));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "SushiRoll: TokenA Transfer failed");
        
        // solium-disable-next-line security/no-low-level-calls
        (success, data) = tokenB.call(abi.encodeWithSelector(0xa9059cbb, msg.sender, amountB - pooledAmountB));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "SushiRoll: TokenB Transfer failed");
    }

}