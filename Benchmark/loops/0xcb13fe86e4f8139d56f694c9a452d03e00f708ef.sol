/**
 *Submitted for verification at Etherscan.io on 2020-09-10
*/

// File: contracts/lib/IERC20.sol

//pragma solidity^0.7;
pragma solidity >=0.5 <0.7.17;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see `ERC20Detailed`.
 */
interface IERC20 {
  /**
   * @dev Returns the amount of tokens in existence.
   */
  function totalSupply() external view returns (uint256);

  /**
   * @dev Returns the amount of tokens owned by `account`.
   */
  function balanceOf(address account) external view returns (uint256);

  /**
   * @dev Moves `amount` tokens from the caller's account to `recipient`.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a `Transfer` event.
   */
  function transfer(address recipient, uint256 amount) external returns (bool);

  /**
   * @dev Returns the remaining number of tokens that `spender` will be
   * allowed to spend on behalf of `owner` through `transferFrom`. This is
   * zero by default.
   *
   * This value changes when `approve` or `transferFrom` are called.
   */
  function allowance(address owner, address spender) external view returns (uint256);

  /**
   * @dev Returns the number of decimals used to get its user representation.
   * For example, if `decimals` equals `2`, a balance of `505` tokens should
   * be displayed to a user as `5,05` (`505 / 10 ** 2`).
   *
   * Tokens usually opt for a value of 18, imitating the relationship between
   * Ether and Wei.
   *
   * > Note that this information is only used for _display_ purposes: it in
   * no way affects any of the arithmetic of the contract, including
   * `IERC20.balanceOf` and `IERC20.transfer`.
   */
  function decimals() external view returns (uint8);

  /**
   * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * > Beware that changing an allowance with this method brings the risk
   * that someone may use both the old and the new allowance by unfortunate
   * transaction ordering. One possible solution to mitigate this race
   * condition is to first reduce the spender's allowance to 0 and set the
   * desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   *
   * Emits an `Approval` event.
   */
  function approve(address spender, uint256 amount) external returns (bool);

  /**
   * @dev Moves `amount` tokens from `sender` to `recipient` using the
   * allowance mechanism. `amount` is then deducted from the caller's
   * allowance.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a `Transfer` event.
   */
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

  /**
   * @dev Emitted when `value` tokens are moved from one account (`from`) to
   * another (`to`).
   *
   * Note that `value` may be zero.
   */
  event Transfer(address indexed from, address indexed to, uint256 value);

  /**
   * @dev Emitted when the allowance of a `spender` for an `owner` is set by
   * a call to `approve`. `value` is the new allowance.
   */
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: contracts/lib/uniswapV2/IUniswapV2Factory.sol

//pragma solidity 0.5.15;
pragma solidity >=0.5 <0.7.17;

interface IUniswapV2Factory {

  function getPair(address tokenA, address tokenB) external view returns (address pair);

  function allPairs(uint) external view returns (address pair);

  function allPairsLength() external view returns (uint);

}

// File: contracts/lib/uniswapV2/IUniswapV2Pair.sol

//pragma solidity 0.5.15;
pragma solidity >=0.5 <0.7.17;

interface IUniswapV2Pair {

  function token0() external view returns (address);

  function token1() external view returns (address);

  function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

// File: contracts/lib/uniswapV2/UniswapV2.sol

//pragma solidity 0.5.15;
pragma solidity >=0.5 <0.7.17;
pragma experimental ABIEncoderV2;




contract UniswapV2 {

  //0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f
  IUniswapV2Factory factory;
  address weth;

  constructor(address _factory, address _weth) public {
    factory = IUniswapV2Factory(_factory);
    weth = _weth;
  }

  struct Pair {
    address token0;
    address token1;
  }

  function allPairsLength() external view returns (uint) {
    return factory.allPairsLength();
  }

  function getPairs(uint fromIndex, uint toIndex) external view returns (Pair[] memory){
    Pair[] memory pairs = new Pair[](toIndex - fromIndex);

    uint pIndex = 0;

    for (uint i = fromIndex; i < toIndex; i++) {
      address pairAddr = factory.allPairs(i);

      IUniswapV2Pair uniswapPair = IUniswapV2Pair(pairAddr);

      Pair memory pair;

      pair.token0 = uniswapPair.token0();
      pair.token1 = uniswapPair.token1();

      pairs[pIndex++] = pair;
    }

    return pairs;
  }

  function getPairReserves(address token0, address token1) public view returns (uint r0, uint r1, uint r2, uint r3, uint r4, uint r5) {

    address exchange = factory.getPair(token0, token1);

    if (exchange != address(0)) {
      r0 = IERC20(token0).balanceOf(exchange);
      r1 = IERC20(token1).balanceOf(exchange);
    }

    if (address(token0) != address(weth) && address(token1) != address(weth)) {
      exchange = factory.getPair(token0, weth);

      if (exchange != address(0)) {
        r2 = IERC20(token0).balanceOf(exchange);
        r3 = IERC20(weth).balanceOf(exchange);
      }

      exchange = factory.getPair(weth, token1);

      if (exchange != address(0)) {
        r4 = IERC20(weth).balanceOf(exchange);
        r5 = IERC20(token1).balanceOf(exchange);
      }
    }

    return (r0, r1, r2, r3, r4, r5);
  }

}
