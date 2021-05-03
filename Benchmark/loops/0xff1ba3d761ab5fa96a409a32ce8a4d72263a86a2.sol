/**
 *Submitted for verification at Etherscan.io on 2020-12-30
*/

/**
 *Submitted for verification at Etherscan.io on 2020-12-19
*/

// File: dxswap-core/contracts/interfaces/IDXswapPair.sol

//pragma solidity >=0.5.0;
pragma solidity >=0.5 <0.7.17;

interface IDXswapPair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);
    function swapFee() external view returns (uint32);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
    function setSwapFee(uint32) external;
}

// File: contracts/libraries/FixedPoint.sol

//pragma solidity >=0.5.0;
pragma solidity >=0.5 <0.7.17;

// a library for handling binary fixed point numbers (https://en.wikipedia.org/wiki/Q_(number_format))
library FixedPoint {
    // range: [0, 2**112 - 1]
    // resolution: 1 / 2**112
    struct uq112x112 {
        uint224 _x;
    }

    // range: [0, 2**144 - 1]
    // resolution: 1 / 2**112
    struct uq144x112 {
        uint256 _x;
    }

    uint8 private constant RESOLUTION = 112;

    // encode a uint112 as a UQ112x112
    function encode(uint112 x) internal pure returns (uq112x112 memory) {
        return uq112x112(uint224(x) << RESOLUTION);
    }

    // encodes a uint144 as a UQ144x112
    function encode144(uint144 x) internal pure returns (uq144x112 memory) {
        return uq144x112(uint256(x) << RESOLUTION);
    }

    // divide a UQ112x112 by a uint112, returning a UQ112x112
    function div(uq112x112 memory self, uint112 x) internal pure returns (uq112x112 memory) {
        require(x != 0, "FixedPoint: DIV_BY_ZERO");
        return uq112x112(self._x / uint224(x));
    }

    // multiply a UQ112x112 by a uint, returning a UQ144x112
    // reverts on overflow
    function mul(uq112x112 memory self, uint256 y) internal pure returns (uq144x112 memory) {
        uint256 z;
        require(y == 0 || (z = uint256(self._x) * y) / y == uint256(self._x), "FixedPoint: MULTIPLICATION_OVERFLOW");
        return uq144x112(z);
    }

    // returns a UQ112x112 which represents the ratio of the numerator to the denominator
    // equivalent to encode(numerator).div(denominator)
    function fraction(uint112 numerator, uint112 denominator) internal pure returns (uq112x112 memory) {
        require(denominator > 0, "FixedPoint: DIV_BY_ZERO");
        return uq112x112((uint224(numerator) << RESOLUTION) / denominator);
    }

    // decode a UQ112x112 into a uint112 by truncating after the radix point
    function decode(uq112x112 memory self) internal pure returns (uint112) {
        return uint112(self._x >> RESOLUTION);
    }

    // decode a UQ144x112 into a uint144 by truncating after the radix point
    function decode144(uq144x112 memory self) internal pure returns (uint144) {
        return uint144(self._x >> RESOLUTION);
    }
}

// File: contracts/libraries/DXswapOracleLibrary.sol

//pragma solidity >=0.5.0;
pragma solidity >=0.5 <0.7.17;



// library with helper methods for oracles that are concerned with computing average prices
library DXswapOracleLibrary {
    using FixedPoint for *;

    // helper function that returns the current block timestamp within the range of uint32, i.e. [0, 2**32 - 1]
    function currentBlockTimestamp() internal view returns (uint32) {
        return uint32(block.timestamp % 2**32);
    }

    // produces the cumulative price using counterfactuals to save gas and avoid a call to sync.
    function currentCumulativePrices(address pair)
        internal
        view
        returns (
            uint256 price0Cumulative,
            uint256 price1Cumulative,
            uint32 blockTimestamp
        )
    {
        blockTimestamp = currentBlockTimestamp();
        price0Cumulative = IDXswapPair(pair).price0CumulativeLast();
        price1Cumulative = IDXswapPair(pair).price1CumulativeLast();

        // if time has elapsed since the last update on the pair, mock the accumulated price values
        (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast) = IDXswapPair(pair).getReserves();
        if (blockTimestampLast != blockTimestamp) {
            // subtraction overflow is desired
            uint32 timeElapsed = blockTimestamp - blockTimestampLast;
            // addition overflow is desired
            // counterfactual
            price0Cumulative += uint256(FixedPoint.fraction(reserve1, reserve0)._x) * timeElapsed;
            // counterfactual
            price1Cumulative += uint256(FixedPoint.fraction(reserve0, reserve1)._x) * timeElapsed;
        }
    }
}

// File: contracts/libraries/SafeMath.sol

//pragma solidity =0.6.6;
pragma solidity >=0.5 <0.7.17;

// a library for performing overflow-safe math, courtesy of DappHub (https://github.com/dapphub/ds-math)

library SafeMath {
    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x + y) >= x, "ds-math-add-overflow");
    }

    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x - y) <= x, "ds-math-sub-underflow");
    }

    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");
    }
}

// File: contracts/libraries/DXswapLibrary.sol

//pragma solidity >=0.5.0;
pragma solidity >=0.5 <0.7.17;



library DXswapLibrary {
    using SafeMath for uint256;

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, "DXswapLibrary: IDENTICAL_ADDRESSES");
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), "DXswapLibrary: ZERO_ADDRESS");
    }

    // calculates the CREATE2 address for a pair without making any external calls
    function pairFor(
        address factory,
        address tokenA,
        address tokenB
    ) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(
            uint256(
                keccak256(
                    abi.encodePacked(
                        hex"ff",
                        factory,
                        keccak256(abi.encodePacked(token0, token1)),
                        hex"2db943b381c6ef706828ea5e89f480bd449d4d3a2b98e6da97b30d0eb41fb6d6" // init code hash
                    )
                )
            )
        );
    }

    // fetches and sorts the reserves for a pair
    function getReserves(
        address factory,
        address tokenA,
        address tokenB
    ) internal view returns (uint256 reserveA, uint256 reserveB) {
        (address token0, ) = sortTokens(tokenA, tokenB);
        (uint256 reserve0, uint256 reserve1, ) = IDXswapPair(pairFor(factory, tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    // fetches and sorts the reserves for a pair
    function getSwapFee(
        address factory,
        address tokenA,
        address tokenB
    ) internal view returns (uint256 swapFee) {
        (address token0, ) = sortTokens(tokenA, tokenB);
        swapFee = IDXswapPair(pairFor(factory, tokenA, tokenB)).swapFee();
    }

    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) internal pure returns (uint256 amountB) {
        require(amountA > 0, "DXswapLibrary: INSUFFICIENT_AMOUNT");
        require(reserveA > 0 && reserveB > 0, "DXswapLibrary: INSUFFICIENT_LIQUIDITY");
        amountB = amountA.mul(reserveB) / reserveA;
    }

    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut,
        uint256 swapFee
    ) internal pure returns (uint256 amountOut) {
        require(amountIn > 0, "DXswapLibrary: INSUFFICIENT_INPUT_AMOUNT");
        require(reserveIn > 0 && reserveOut > 0, "DXswapLibrary: INSUFFICIENT_LIQUIDITY");
        uint256 amountInWithFee = amountIn.mul(uint256(10000).sub(swapFee));
        uint256 numerator = amountInWithFee.mul(reserveOut);
        uint256 denominator = reserveIn.mul(10000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut,
        uint256 swapFee
    ) internal pure returns (uint256 amountIn) {
        require(amountOut > 0, "DXswapLibrary: INSUFFICIENT_OUTPUT_AMOUNT");
        require(reserveIn > 0 && reserveOut > 0, "DXswapLibrary: INSUFFICIENT_LIQUIDITY");
        uint256 numerator = reserveIn.mul(amountOut).mul(10000);
        uint256 denominator = reserveOut.sub(amountOut).mul(uint256(10000).sub(swapFee));
        amountIn = (numerator / denominator).add(1);
    }

    // performs chained getAmountOut calculations on any number of pairs
    function getAmountsOut(
        address factory,
        uint256 amountIn,
        address[] memory path
    ) internal view returns (uint256[] memory amounts) {
        require(path.length >= 2, "DXswapLibrary: INVALID_PATH");
        amounts = new uint256[](path.length);
        amounts[0] = amountIn;
        for (uint256 i; i < path.length - 1; i++) {
            (uint256 reserveIn, uint256 reserveOut) = getReserves(factory, path[i], path[i + 1]);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut, getSwapFee(factory, path[i], path[i + 1]));
        }
    }

    // performs chained getAmountIn calculations on any number of pairs
    function getAmountsIn(
        address factory,
        uint256 amountOut,
        address[] memory path
    ) internal view returns (uint256[] memory amounts) {
        require(path.length >= 2, "DXswapLibrary: INVALID_PATH");
        amounts = new uint256[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint256 i = path.length - 1; i > 0; i--) {
            (uint256 reserveIn, uint256 reserveOut) = getReserves(factory, path[i - 1], path[i]);
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut, getSwapFee(factory, path[i - 1], path[i]));
        }
    }
}

// File: contracts/OracleCreator.sol

//pragma solidity =0.6.6;
pragma solidity >=0.5 <0.7.17;
pragma experimental ABIEncoderV2;




contract OracleCreator {
    using FixedPoint for *;
    using SafeMath for uint256;

    event OracleCreated(
        uint256 indexed _oracleIndex,
        address indexed _pair,
        uint256 _windowTime
    );

    struct Oracle{
        uint256 windowTime;
        address token0;
        address token1;
        IDXswapPair pair;
        uint32 blockTimestampLast;
        uint256 price0CumulativeLast;
        uint256 price1CumulativeLast;
        FixedPoint.uq112x112 price0Average;
        FixedPoint.uq112x112 price1Average;
        uint256 observationsCount;
        address owner;
    }

    mapping(uint256 => Oracle) public oracles;
    uint256 public oraclesIndex;

    function createOracle(
        uint256 windowTime,
        address pair
    ) public returns (uint256 oracleId) {
        IDXswapPair sourcePair = IDXswapPair(pair);
        address token0 = sourcePair.token0();
        address token1 = sourcePair.token1();
        (,, uint32 blockTimestampLast) =  sourcePair.getReserves();

        oracles[oraclesIndex] = Oracle({
            windowTime: windowTime,
            token0: token0,
            token1: token1,
            pair: sourcePair,
            blockTimestampLast: blockTimestampLast,
            price0CumulativeLast: sourcePair.price0CumulativeLast(),
            price1CumulativeLast: sourcePair.price1CumulativeLast(),
            price0Average: FixedPoint.uq112x112(0),
            price1Average: FixedPoint.uq112x112(0),
            observationsCount: 0,
            owner: msg.sender
        });
        oracleId = oraclesIndex;
        oraclesIndex++;
        emit OracleCreated(oracleId, address(sourcePair), windowTime);
    }

    function update(uint256 oracleIndex) public {
        Oracle storage oracle = oracles[oracleIndex];
        require(msg.sender == oracle.owner, 'OracleCreator: CALLER_NOT_OWNER');
        require(oracle.observationsCount < 2, 'OracleCreator: FINISHED_OBERSERVATION');
        (uint price0Cumulative, uint price1Cumulative, uint32 blockTimestamp) =
            DXswapOracleLibrary.currentCumulativePrices(address(oracle.pair));
        uint32 timeElapsed = blockTimestamp - oracle.blockTimestampLast; // overflow is desired

        // first update can be executed immediately. Ensure that at least one full period has passed since the first update 
        require(
          oracle.observationsCount == 0 || timeElapsed >= oracle.windowTime, 
          'OracleCreator: PERIOD_NOT_ELAPSED'
        );

        // overflow is desired, casting never truncates
        // cumulative price is in (uq112x112 price * seconds) units so we simply wrap it after division by time elapsed
        oracle.price0Average = FixedPoint.uq112x112(
          uint224((price0Cumulative - oracle.price0CumulativeLast) / timeElapsed)
        );
        oracle.price1Average = FixedPoint.uq112x112(
          uint224((price1Cumulative - oracle.price1CumulativeLast) / timeElapsed)
        );

        oracle.price0CumulativeLast = price0Cumulative;
        oracle.price1CumulativeLast = price1Cumulative;
        oracle.blockTimestampLast = blockTimestamp;
        oracle.observationsCount++;
    }

    // note this will always return 0 before update has been called successfully for the first time.
    function consult(uint256 oracleIndex, address token, uint256 amountIn) external view returns (uint256 amountOut) {
        Oracle storage oracle = oracles[oracleIndex];
        FixedPoint.uq112x112 memory avg;
        if (token == oracle.token0) { 
          avg = oracle.price0Average;
        } else {
          require(token == oracle.token1, 'OracleCreator: INVALID_TOKEN'); 
          avg = oracle.price1Average;
        }
        amountOut = avg.mul(amountIn).decode144();
    }

    function isOracleFinalized(uint256 oracleIndex) external view returns (bool){
        return oracles[oracleIndex].observationsCount == 2;
    }

    function getOracleDetails(uint256 oracleIndex) external view returns (Oracle memory) {
      return oracles[oracleIndex];
    }

}
