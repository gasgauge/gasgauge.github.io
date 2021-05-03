/**

 *Submitted for verification at Etherscan.io on 2020-12-21

*/



//pragma solidity ^0.6.6;
pragma solidity >=0.5 <0.7.17;



interface IUniswapV2Router02 {

	function factory() external pure returns (address);

	function WETH() external pure returns (address);



	function addLiquidity(address tokenA, address tokenB, uint amountADesired, uint amountBDesired, uint amountAMin, uint amountBMin, address to, uint deadline) external returns (uint amountA, uint amountB, uint liquidity);

	function addLiquidityETH(address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);

	function removeLiquidity(address tokenA, address tokenB, uint liquidity, uint amountAMin, uint amountBMin, address to, uint deadline) external returns (uint amountA, uint amountB);

	function removeLiquidityETH(address token,uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external returns (uint amountToken, uint amountETH);

	function removeLiquidityWithPermit(address tokenA, address tokenB, uint liquidity, uint amountAMin, uint amountBMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns (uint amountA, uint amountB);

	function removeLiquidityETHWithPermit(address token,uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns (uint amountToken, uint amountETH);

	function swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);

	function swapTokensForExactTokens(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);

	function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);

	function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);

	function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);

	function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);



	function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

	function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

	function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

	function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

	function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);



	function removeLiquidityETHSupportingFeeOnTransferTokens(address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external returns (uint amountETH);

	function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns (uint amountETH);



	function swapExactTokensForTokensSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;

	function swapExactETHForTokensSupportingFeeOnTransferTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable;

	function swapExactTokensForETHSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;

}



interface IERC20 {

	function totalSupply() external view returns (uint256);



	function balanceOf(address account) external view returns (uint256);



	function transfer(address recipient, uint256 amount) external returns (bool);



	function allowance(address owner, address spender) external view returns (uint256);



	function approve(address spender, uint256 amount) external returns (bool);



	function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

	

	function shareOf(address account) external view returns (uint256 share); // hegic

	

	function allInfoFor(address _user) external view returns (uint256 contractBalance, uint256 totalTokenSupply, uint256 truePrice, uint256 buyPrice, uint256 sellPrice, uint256 openingBlock, uint256 currentBlock, uint256 userETH, uint256 userSURF, uint256 userBalance, uint256 userDividends, uint256 userLiquidValue); // surf3d

	

	function name() external view returns (string memory);



    function symbol() external view returns (string memory);



    function decimals() external view returns (uint8);



	event Transfer(address indexed from, address indexed to, uint256 value);



	event Approval(address indexed owner, address indexed spender, uint256 value);

}



contract ScamChecker  {

	address payable public contractOwner;



	constructor() public {

		contractOwner = msg.sender;

	}



	function execute(bytes calldata data) external payable {		

	}

	

	function withdraw(address atoken) public {

		require(msg.sender == contractOwner, "Nope");



		IERC20 token = IERC20(atoken);

		uint256 bal = token.balanceOf(address(this));

		if (bal > 0)

			token.transfer(contractOwner, bal);



		bal = address(this).balance;

		if (bal > 0)

			contractOwner.send(bal);

	}



	function testTokenWeth(address tokenAddr) public {

		testToken(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2, tokenAddr);

	}



	function testToken(address tokenAddr0, address tokenAddr1) public {

		IERC20 token0 = IERC20(tokenAddr0);

		IERC20 token1 = IERC20(tokenAddr1);



		token0.approve(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D, uint(-1));

		token1.approve(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D, uint(-1));



		IUniswapV2Router02 exchange = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

		address[] memory path = new address[](2);

		path[0] = tokenAddr0;

		path[1] = tokenAddr1;

		uint256 bal = token0.balanceOf(address(this));

		exchange.swapExactTokensForTokens(bal, 1, path, address(this), block.timestamp);



		bal = token1.balanceOf(address(this));

		path[0] = tokenAddr1;

		path[1] = tokenAddr0;

		exchange.swapExactTokensForTokens(bal, 1, path, address(this), block.timestamp);

	}

	

	function testFeeTokenWeth(address tokenAddr) public returns (uint256) {

		return testFeeTokenWeth(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D, tokenAddr);

	}

	

	function testFeeTokenWeth(address router, address tokenAddr) public returns (uint256) {

		return testFeeToken(router, 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2, tokenAddr);

	}



	function testFeeToken(address tokenAddr0, address tokenAddr1) public returns (uint256) {

		return testFeeToken(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D, tokenAddr0, tokenAddr1);

	}



	function testFeeToken(address router, address tokenAddr0, address tokenAddr1) public returns (uint256) {

		IERC20 token0 = IERC20(tokenAddr0);

		IERC20 token1 = IERC20(tokenAddr1);



		token0.approve(router, uint(-1));

		token1.approve(router, uint(-1));



		IUniswapV2Router02 exchange = IUniswapV2Router02(router);

		address[] memory path = new address[](2);

		path[0] = tokenAddr0;

		path[1] = tokenAddr1;

		uint256 bal0 = token0.balanceOf(address(this));

		exchange.swapExactTokensForTokensSupportingFeeOnTransferTokens(bal0, 1, path, address(this), block.timestamp);



		uint256 bal1 = token1.balanceOf(address(this));

		path[0] = tokenAddr1;

		path[1] = tokenAddr0;

		exchange.swapExactTokensForTokensSupportingFeeOnTransferTokens(bal1, 1, path, address(this), block.timestamp);



		return (token0.balanceOf(address(this)) * 1000) / bal0;

	}

}
